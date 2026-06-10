import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base/core/common/extensions/context_extensions.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

import '../../../core/base/di/injection.dart';
import '../models/ad_config.dart';
import '../models/ad_placements.dart';
import '../widgets/native_ad_full_screen.dart';
import 'ad_cache_service.dart';
import 'ad_config_service.dart';
import 'handlers/app_open_handler.dart';
import 'handlers/inter_handler.dart';
import 'handlers/rewarded_handler.dart';

/// Facade gọn cho ads. Không quản lý logic — uỷ thác cho handlers.
///
/// Cách dùng:
/// ```dart
/// adManager.showInter(InterPlacement.splash);
/// adManager.showRewarded(RewardedPlacement.bonus, onEarnedReward: ...);
/// adManager.nativeUnit(NativePlacement.language);   // → AdUnit cho NativeAdWidget
/// adManager.bannerUnit(BannerPlacement.home);
///
/// // Placement động (A/B test, Remote Config thử nghiệm):
/// adManager.showInter(const RawPlacement('experimental_v2'));
/// ```

AdManager get adManager => getIt<AdManager>();

@lazySingleton
class AdManager {
  AdManager(this._configService, this._cache, this._inter, this._appOpen, this._rewarded);

  final AdConfigService _configService;
  final AdCacheService _cache;
  final InterHandler _inter;
  final AppOpenHandler _appOpen;
  final RewardedHandler _rewarded;

  AdConfig get _cfg => _configService.current;
  AdConfig get config => _cfg;

  static const _kNativeAfterInterCacheKey = 'native_after_inter';
  static const _kNativeFullCacheKey = 'native_full';

  DateTime? _lastNativeFullShownAt;

  // ── INIT ──────────────────────────────────────────────────────

  Future<void> initialize() async {
    await MobileAds.instance.initialize();

    _configService.config.addListener(() {
      Logger.info('Config updated, preloading all placements...', tag: 'ADS');
      _preloadAll();
    });

    _preloadAll();
  }

  /// Swap id→id2 nếu cần, handlers dùng unit.resolvedId mà không cần biết.
  AdUnit? _resolve(AdUnit? unit) {
    if (unit == null) return null;
    final use = unit.useId2 ?? false;
    if (!use || unit.id2.isEmpty) return unit;
    return unit.copyWith(id: unit.id2);
  }

  void _preloadAll() {
    if (!_cfg.showAllAds) return;
    if (_cfg.enableInter) {
      _cfg.inter.forEach((p, u) => _inter.preload(_resolve(u)!, p, _cfg));
    }
    if (_cfg.enableAppOpen) {
      _cfg.appOpen.forEach((p, u) => _appOpen.preload(_resolve(u)!, p, _cfg));
    }
    if (_cfg.enableRewarded) {
      _cfg.rewarded.forEach((p, u) => _rewarded.preload(_resolve(u)!, p, _cfg));
    }
    if (_cfg.enableNativeFull) {
      if (_cfg.nativeFullAfterInter) _preloadNativeAfterInter();
      _preloadNativeFull();
    }
  }

  // ── INTER ─────────────────────────────────────────────────────

  /// [placement] có thể là enum (`InterPlacement.splash`)
  /// hoặc dynamic (`const RawPlacement('experimental_v2')`).
  Future<bool> showInter(
    PlacementKey placement, {
    VoidCallback? onDismissed,
    Duration timeout = const Duration(seconds: 5),
    bool showNativeFull = true,
  }) {
    if (!_cfg.enableInter) return Future.value(false);
    final unit = _resolve(_cfg.inter.byPlacement(placement));
    final wrappedDismiss = (showNativeFull && _cfg.enableNativeFull && _cfg.nativeFullAfterInter)
        ? () => _showNativeAfterInter(onClosed: onDismissed)
        : onDismissed;

    return _inter.show(
      unit: unit,
      placement: placement.key,
      cfg: _cfg,
      onDismissed: wrappedDismiss,
      timeout: timeout,
    );
  }

  // ── APP OPEN ──────────────────────────────────────────────────

  Future<bool> showAppOpen(PlacementKey placement, {VoidCallback? onDismissed}) {
    if (!_cfg.enableAppOpen) return Future.value(false);

    var unit = _resolve(_cfg.appOpen.byPlacement(placement));
    if (unit == null && placement != AppOpenPlacement.resume) {
      Logger.warning(
        'AppOpen placement "${placement.key}" not found, falling back to resume',
        tag: 'ADS',
      );
      unit = _resolve(_cfg.appOpen.byPlacement(AppOpenPlacement.resume));
    }

    return _appOpen.show(unit: unit, placement: placement.key, cfg: _cfg, onDismissed: onDismissed);
  }

  // ── REWARDED ──────────────────────────────────────────────────

  Future<bool> showRewarded(
    PlacementKey placement, {
    void Function(RewardItem reward)? onEarnedReward,
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (!_cfg.enableRewarded) return Future.value(false);
    final unit = _resolve(_cfg.rewarded.byPlacement(placement));
    return _rewarded.showRewarded(
      unit: unit,
      placement: placement.key,
      cfg: _cfg,
      onEarnedReward: onEarnedReward,
      timeout: timeout,
    );
  }

  // ── NATIVE / BANNER (widget-based) ────────────────────────────

  AdUnit? nativeUnit(PlacementKey placement) {
    if (!_cfg.enableNative) return null;
    final unit = _resolve(_cfg.native.byPlacement(placement));
    if (!_cfg.unitEnabled(unit)) return null;
    return unit;
  }

  AdUnit? bannerUnit(PlacementKey placement) {
    if (!_cfg.enableBanner) return null;
    final unit = _resolve(_cfg.banner.byPlacement(placement));
    if (!_cfg.unitEnabled(unit)) return null;
    return unit;
  }

  // ── NATIVE AFTER INTER (special) ──────────────────────────────

  void _preloadNativeAfterInter() =>
      _preloadNativeAd(placement: NativePlacement.afterInter, cacheKey: _kNativeAfterInterCacheKey);

  void _preloadNativeFull() =>
      _preloadNativeAd(placement: NativePlacement.nativeFull, cacheKey: _kNativeFullCacheKey);

  void _preloadNativeAd({required NativePlacement placement, required String cacheKey}) {
    final unit = _resolve(_cfg.native.byPlacement(placement));
    if (!_cfg.unitEnabled(unit)) return;
    if (_cache.isReady(cacheKey)) return;

    NativeAd(
      adUnitId: unit!.resolvedId,
      factoryId: 'nativeMedium',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _cache.set(cacheKey, ad);
          Logger.info('Native [${placement.key}] loaded', tag: 'ADS');
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          Logger.warning('Native [${placement.key}] load failed: ${err.message}', tag: 'ADS');
        },
      ),
    ).load();
  }

  bool _nativeFullIntervalPassed() {
    final last = _lastNativeFullShownAt;
    if (last == null) return true;
    return DateTime.now().difference(last).inSeconds >= _cfg.rules.nativeFullInterval;
  }

  /// Gọi thủ công bất kỳ chỗ nào — check enableNativeFull.
  void showNativeFull({VoidCallback? onClosed}) {
    if (!_cfg.enableNativeFull || !_nativeFullIntervalPassed()) {
      onClosed?.call();
      return;
    }
    _showNativeAd(cacheKey: _kNativeFullCacheKey, onMiss: _preloadNativeFull, onClosed: onClosed);
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
    if (!_cache.isReady(cacheKey)) {
      onMiss();
      onClosed?.call();
      return;
    }

    final ad = _cache.get<NativeAd>(cacheKey)!;

    // SmartDialog.show(
    //   useSystem: true,
    //   builder: (context) => NativeAdFullScreen(
    //     ad: ad,
    //     onClosed: () {
    //       SmartDialog.dismiss();
    //       _cache.remove(cacheKey);
    //       onMiss();
    //       onClosed?.call();
    //     },
    //   ),
    // );

    _lastNativeFullShownAt = DateTime.now();
    appContext.navPush(NativeAdFullScreen(
      ad: ad,
      onClosed: () {
        appContext.navPop();
        _cache.remove(cacheKey);
        onMiss();
        onClosed?.call();
      },
    ));
  }

  // ── SESSION ───────────────────────────────────────────────────

  void resetSession() {
    _inter.resetSession();
    _appOpen.resetSession();
    _rewarded.resetSession();
  }
}
