import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/config/app/flavor_config.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/common/extensions/context_extensions.dart';
import 'package:karaoke/core/data/network/network_info.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/models/ad_placements.dart';
import 'package:karaoke/modules/ads/observers/ad_lifecycle_observer.dart';
import 'package:karaoke/modules/ads/services/ad_cache_service.dart';
import 'package:karaoke/modules/ads/services/ad_config_service.dart';
import 'package:karaoke/modules/ads/services/ad_consent_service.dart';
import 'package:karaoke/modules/ads/services/handlers/app_open_handler.dart';
import 'package:karaoke/modules/ads/services/handlers/inter_handler.dart';
import 'package:karaoke/modules/ads/services/handlers/rewarded_handler.dart';
import 'package:karaoke/modules/ads/widgets/native_ad_full_screen.dart';

/// Facade gọn cho ads. Không quản lý logic — uỷ thác cho handlers.
///
/// Cách dùng:
/// ```dart
/// adManager.showInter(InterstitialPlacement.splash);
/// adManager.showRewarded(RewardedPlacement.bonus, onEarnedReward: ...);
/// adManager.nativeUnit(NativePlacement.language);
/// adManager.bannerUnit(BannerPlacement.home);
///
/// // Placement động (A/B test):
/// adManager.showInter(const RawPlacement('experimental_v2'));
/// ```
AdManager get adManager => getIt<AdManager>();

@lazySingleton
class AdManager {
  AdManager(
    this._configService,
    this._consentService,
    this._cache,
    this._network,
    this._inter,
    this._appOpen,
    this._rewarded,
  );

  final AdConfigService _configService;
  final AdConsentService _consentService;
  final AdCacheService _cache;
  final NetworkInfo _network;
  final InterHandler _inter;
  final AppOpenHandler _appOpen;
  final RewardedHandler _rewarded;

  /// Subscription cho network change — re-preload khi network restore.
  StreamSubscription<bool>? _networkSub;

  /// Track first launch để không tự fire AppOpen splash 2 lần (initialize vs
  /// observer resume). Caller có thể gọi `showAppOpenOnLaunch()` từ Splash page.
  bool _appOpenLaunchShown = false;

  /// Test device IDs — chỉ dùng cho dev/stg flavor. PROD flavor sẽ assert
  /// list rỗng để tránh gửi test traffic vào real account.
  static const _testDeviceIds = <String>[
    // Thêm hashedDeviceId của máy test khi cần — log ra console khi load ad đầu tiên.
  ];

  AdConfig get _cfg => _configService.current;
  AdConfig get config => _cfg;

  static const _kNativeAfterInterCacheKey = 'native_after_inter';
  static const _kNativeFullCacheKey = 'native_full';

  /// Guard tránh duplicate native preload — nếu config update fire 2 lần
  /// nhanh, `_preloadAll()` có thể gọi 2 lần → 2 SDK request in-flight cho
  /// cùng cache key → 1 thắng, 1 phí. Set này chặn entry thứ 2.
  final Set<String> _nativeLoading = <String>{};

  DateTime? _lastNativeFullShownAt;

  /// ⚡ Cross-handler cooldown — Inter/Rewarded vừa show → block AppOpen.
  /// UX: tránh user dismiss inter → app resume → app-open chồng lên = double ad.
  DateTime? _lastAnyAdShownAt;
  static const _interAppOpenCooldown = Duration(seconds: 10);

  void _markAdShown() => _lastAnyAdShownAt = DateTime.now();

  bool _isInCooldown() {
    final last = _lastAnyAdShownAt;
    if (last == null) return false;
    return DateTime.now().difference(last) < _interAppOpenCooldown;
  }

  // ── INIT ──────────────────────────────────────────────────────

  Future<void> initialize() async {
    // ⚡ RequestConfiguration PHẢI set trước initialize() để áp cho mọi ad sau đó.
    // - tagForChildDirectedTreatment / tagForUnderAgeOfConsent: COPPA/GDPR.
    // - maxAdContentRating: chặn mature content (G | PG | T | MA).
    // - testDeviceIds: chỉ áp dev/stg — assert prod rỗng để tránh invalid traffic.
    final isProd = !FlavorConfig.isDev && FlavorConfig.current.flavor.name == 'prod';
    if (isProd) {
      assert(
        _testDeviceIds.isEmpty,
        '⛔ testDeviceIds PHẢI rỗng ở prod — sẽ gửi test traffic vào real account',
      );
    }

    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.t,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: isProd ? const <String>[] : _testDeviceIds,
      ),
    );

    await MobileAds.instance.initialize();

    _configService.config.addListener(() {
      Logger.info('Config updated, preloading all placements...', tag: 'ADS');
      _preloadAll();
    });

    // ⚡ Network restore listener — khi user offline → online lại, tự
    // re-preload mọi placement. Trước đây retry quota giãn xong thì giã,
    // user vào page không có ad. Giờ recover được.
    // ignore: unawaited_futures
    _networkSub?.cancel();
    _networkSub = _network.onStatusChange.where((on) => on).listen((_) {
      Logger.info('Network restored → re-preload all', tag: 'ADS');
      _preloadAll();
    });

    _preloadAll();
  }

  /// Re-preload tất cả khi consent thay đổi — gọi sau `showPrivacyOptionsForm`.
  void onConsentChanged() {
    if (!_consentService.canRequestAds) {
      Logger.warning('Consent revoked — skipping preload', tag: 'ADS');
      return;
    }
    _preloadAll();
  }

  /// ⚡ Gọi từ Splash page **sau khi router/UI ready** (vd: trong `initState`
  /// hoặc sau frame đầu) để show AppOpen splash trên cold start.
  ///
  /// `AdLifecycleObserver` chỉ fire trên RESUME (background → foreground),
  /// KHÔNG fire khi app vừa launch — phải gọi helper này.
  ///
  /// Idempotent: chỉ fire 1 lần per app session, gọi lại = no-op.
  ///
  /// Nếu ad chưa preload xong → `show()` tự load (timeout 5s mặc định).
  /// Trên slow network ad có thể không kịp → return false → splash chuyển
  /// trang bình thường.
  Future<bool> showAppOpenOnLaunch({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_appOpenLaunchShown) return false;
    _appOpenLaunchShown = true;
    if (!_cfg.enableAppOpen) return false;
    if (!_consentService.canRequestAds) return false;
    return showAppOpen(AppOpenPlacement.splash);
  }

  /// Cleanup — gọi khi app shutdown (rất hiếm dùng vì lazySingleton sống mãi).
  void dispose() {
    _networkSub?.cancel();
    _networkSub = null;
  }

  /// Swap id→id2 nếu cần, handlers dùng `unit.resolvedId` mà không cần biết.
  AdUnit? _resolve(AdUnit? unit) {
    if (unit == null) return null;
    final use = unit.useId2 ?? false;
    if (!use || unit.id2.isEmpty) return unit;
    return unit.copyWith(id: unit.id2);
  }

  void _preloadAll() {
    if (!_cfg.showAllAds) return;
    // ⚡ Skip preload nếu user reject UMP — load sẽ fail liên tục, tốn retry.
    // Khi user mở `showPrivacyOptionsForm` → đổi ý → caller gọi `onConsentChanged()`.
    if (!_consentService.canRequestAds) {
      Logger.info('Skip preload — consent not granted', tag: 'ADS');
      return;
    }
    if (_cfg.enableInter) {
      _cfg.adUnits.inter.forEach((p, u) {
        final r = _resolve(u);
        if (r != null) _inter.preload(r, p, _cfg);
      });
    }
    if (_cfg.enableAppOpen) {
      _cfg.adUnits.appOpen.forEach((p, u) {
        final r = _resolve(u);
        if (r != null) _appOpen.preload(r, p, _cfg);
      });
    }
    if (_cfg.enableRewarded) {
      _cfg.adUnits.rewarded.forEach((p, u) {
        final r = _resolve(u);
        if (r != null) _rewarded.preload(r, p, _cfg);
      });
    }
    if (_cfg.enableNativeFull) {
      if (_cfg.nativeFullAfterInter) _preloadNativeAfterInter();
      _preloadNativeFull();
    }
  }

  // ── INTER ─────────────────────────────────────────────────────

  Future<bool> showInter(
    PlacementKey placement, {
    VoidCallback? onDismissed,
    Duration timeout = const Duration(seconds: 5),
    bool showNativeFull = true,
  }) async {
    if (!_cfg.enableInter) return false;
    final unit = _resolve(_cfg.adUnits.inter.byPlacement(placement));
    final wrappedDismiss =
        (showNativeFull && _cfg.enableNativeFull && _cfg.nativeFullAfterInter)
            ? () => _showNativeAfterInter(onClosed: onDismissed)
            : onDismissed;

    final shown = await _inter.show(
      unit: unit,
      placement: placement.key,
      cfg: _cfg,
      onDismissed: wrappedDismiss,
      timeout: timeout,
    );
    if (shown) _markAdShown();
    return shown;
  }

  // ── APP OPEN ──────────────────────────────────────────────────

  Future<bool> showAppOpen(PlacementKey placement, {VoidCallback? onDismissed}) async {
    if (!_cfg.enableAppOpen) return false;

    // ⚡ Block AppOpen nếu vừa show Inter/Rewarded trong cooldown.
    if (_isInCooldown()) {
      Logger.warning(
        'AppOpen[${placement.key}] blocked: cooldown after recent ad',
        tag: 'ADS',
      );
      return false;
    }

    var unit = _resolve(_cfg.adUnits.appOpen.byPlacement(placement));
    if (unit == null && placement != AppOpenPlacement.resume) {
      Logger.warning(
        'AppOpen placement "${placement.key}" not found, falling back to resume',
        tag: 'ADS',
      );
      unit = _resolve(_cfg.adUnits.appOpen.byPlacement(AppOpenPlacement.resume));
    }

    final shown = await _appOpen.show(
      unit: unit,
      placement: placement.key,
      cfg: _cfg,
      onDismissed: onDismissed,
    );
    if (shown) _markAdShown();
    return shown;
  }

  // ── REWARDED ──────────────────────────────────────────────────

  Future<bool> showRewarded(
    PlacementKey placement, {
    void Function(RewardItem reward)? onEarnedReward,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!_cfg.enableRewarded) return false;
    final unit = _resolve(_cfg.adUnits.rewarded.byPlacement(placement));
    final shown = await _rewarded.showRewarded(
      unit: unit,
      placement: placement.key,
      cfg: _cfg,
      onEarnedReward: onEarnedReward,
      timeout: timeout,
    );
    if (shown) _markAdShown();
    return shown;
  }

  // ── NATIVE / BANNER (widget-based) ────────────────────────────

  AdUnit? nativeUnit(PlacementKey placement) {
    if (!_cfg.enableNative) return null;
    final unit = _resolve(_cfg.adUnits.native.byPlacement(placement));
    if (!_cfg.unitEnabled(unit)) return null;
    return unit;
  }

  AdUnit? bannerUnit(PlacementKey placement) {
    if (!_cfg.enableBanner) return null;
    final unit = _resolve(_cfg.adUnits.banner.byPlacement(placement));
    if (!_cfg.unitEnabled(unit)) return null;
    return unit;
  }

  // ── NATIVE FULL-SCREEN ────────────────────────────────────────

  void _preloadNativeAfterInter() => _preloadNativeAd(
        placement: NativePlacement.afterInter,
        cacheKey: _kNativeAfterInterCacheKey,
      );

  void _preloadNativeFull() => _preloadNativeAd(
        placement: NativePlacement.nativeFull,
        cacheKey: _kNativeFullCacheKey,
      );

  void _preloadNativeAd({
    required NativePlacement placement,
    required String cacheKey,
  }) {
    final unit = _resolve(_cfg.adUnits.native.byPlacement(placement));
    if (!_cfg.unitEnabled(unit)) return;
    if (_cache.isReady(cacheKey)) return;
    // ⚡ Guard duplicate in-flight load — config update kép có thể fire
    // `_preloadAll()` 2 lần → tránh 2 SDK request trùng key.
    if (_nativeLoading.contains(cacheKey)) return;
    _nativeLoading.add(cacheKey);

    NativeAd(
      adUnitId: unit!.resolvedId,
      // ⚡ Full-screen native dùng factory riêng `nativeFull` — MediaView fill
      // toàn space, text+CTA dồn đáy. In-feed `NativeAdWidget` chọn
      // `nativeSmall` / `nativeMedium` qua prop `size`.
      factoryId: 'nativeFull',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _nativeLoading.remove(cacheKey);
          _cache.set(cacheKey, ad);
          Logger.info('Native [${placement.key}] loaded', tag: 'ADS');
        },
        onAdFailedToLoad: (ad, err) {
          _nativeLoading.remove(cacheKey);
          ad.dispose();
          Logger.warning(
            'Native [${placement.key}] load failed: ${err.message}',
            tag: 'ADS',
          );
        },
      ),
    ).load();
  }

  bool _nativeFullIntervalPassed() {
    final last = _lastNativeFullShownAt;
    if (last == null) return true;
    return DateTime.now().difference(last).inSeconds >=
        _cfg.rules.nativeFullInterval;
  }

  /// Gọi thủ công bất kỳ chỗ nào — check enableNativeFull.
  void showNativeFull({VoidCallback? onClosed}) {
    if (!_cfg.enableNativeFull || !_nativeFullIntervalPassed()) {
      onClosed?.call();
      return;
    }
    _showNativeAd(
      cacheKey: _kNativeFullCacheKey,
      onMiss: _preloadNativeFull,
      onClosed: onClosed,
    );
  }

  /// Gọi tự động sau inter — check nativeFullAfterInter.
  void _showNativeAfterInter({VoidCallback? onClosed}) {
    if (!_cfg.nativeFullAfterInter || !_nativeFullIntervalPassed()) {
      onClosed?.call();
      return;
    }
    _showNativeAd(
      cacheKey: _kNativeAfterInterCacheKey,
      onMiss: _preloadNativeAfterInter,
      onClosed: onClosed,
    );
  }

  void _showNativeAd({
    required String cacheKey,
    required VoidCallback onMiss,
    VoidCallback? onClosed,
  }) {
    // ⚡ Block native full nếu vừa show Inter/Rewarded — UX tránh chồng ad.
    // Exception: _showNativeAfterInter cố tình chain ngay sau inter dismiss
    // (đã ra ngoài cooldown 10s thì OK; nếu chưa thì skip — UX > revenue).
    if (_isInCooldown()) {
      Logger.warning(
        'Native full blocked by cross-handler cooldown',
        tag: 'ADS',
      );
      onClosed?.call();
      return;
    }

    if (!_cache.isReady(cacheKey)) {
      onMiss();
      onClosed?.call();
      return;
    }

    final ad = _cache.get<NativeAd>(cacheKey);
    if (ad == null) {
      onMiss();
      onClosed?.call();
      return;
    }

    _lastNativeFullShownAt = DateTime.now();
    _markAdShown();

    // ⚡ Dùng showDialog (overlay route — không thay đổi GoRouter stack)
    // thay vì Navigator.push trực tiếp → không break deep-linking.
    showDialog<void>(
      context: appContext,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (dialogContext) => NativeAdFullScreen(
        ad: ad,
        onClosed: () {
          Navigator.of(dialogContext).pop();
          _cache.remove(cacheKey);
          onMiss();
          onClosed?.call();
        },
      ),
    );
  }

  // ── SESSION ───────────────────────────────────────────────────

  /// Reset toàn bộ frequency cap + lifecycle sentinels.
  /// Dùng khi: user re-subscribe premium → cancel, login mới, IAP refund.
  /// SAU reset có thể gọi lại `showAppOpenOnLaunch()` và observer hoạt động
  /// như app vừa cold start.
  void resetSession() {
    _inter.resetSession();
    _appOpen.resetSession();
    _rewarded.resetSession();
    _lastAnyAdShownAt = null;
    _lastNativeFullShownAt = null;
    _appOpenLaunchShown = false; // ← cho phép showAppOpenOnLaunch chạy lại
    try {
      getIt<AdLifecycleObserver>().resetSession();
    } catch (_) {
      // Observer chưa đăng ký DI hoặc chưa init — skip.
    }
  }
}
