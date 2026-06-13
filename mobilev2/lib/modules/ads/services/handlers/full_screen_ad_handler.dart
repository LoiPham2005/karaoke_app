import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:karaoke/core/data/network/network_info.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/services/ad_cache_service.dart';
import 'package:karaoke/modules/ads/services/ad_stats_service.dart';
import 'package:karaoke/modules/ads/utils/ad_retry_policy.dart';

/// Base class cho ads dạng full-screen (Inter, AppOpen, Rewarded).
///
/// Frequency cap áp dụng **per-type** (toàn bộ Inter share 1 counter, không
/// phải mỗi placement 1 counter). Match semantic của `AdRules.interInterval`
/// và `AdRules.maxInterPerSession` — 1 giá trị/type.
///
/// Subclass cung cấp:
/// - `type` — tên loại (vd 'inter')
/// - `intervalSeconds`, `maxPerSession` — frequency cap
/// - `loadFromSdk` — gọi SDK load
/// - `showAd` / `setFullScreenCallback` — show + wire callback
/// - `adUnitIdOf(T)` — type-safe đọc adUnitId
/// - `attachPaidEvent(T)` — type-safe wire onPaidEvent
/// - `onAdLoadedHook(T, placement)` — optional, subclass cần map ad↔placement
abstract class FullScreenAdHandler<T extends AdWithoutView> {
  FullScreenAdHandler({
    required this.cache,
    required this.analytics,
    required this.network,
    this.retryPolicy = const AdRetryPolicy(),
  }) : _retry = AdRetryTracker(retryPolicy);

  final AdCacheService cache;
  final AdAnalyticsService analytics;
  final NetworkInfo network;
  final AdRetryPolicy retryPolicy;
  final AdRetryTracker _retry;

  String get type;
  int intervalSeconds(AdRules rules);
  int? maxPerSession(AdRules rules);

  void loadFromSdk({
    required AdUnit unit,
    required void Function(T ad) onLoaded,
    required void Function(LoadAdError err) onFailed,
  });

  Future<void> showAd(T ad);
  void setFullScreenCallback(T ad, FullScreenContentCallback<T> cb);

  /// Type-safe accessor cho adUnitId — subclass override.
  String adUnitIdOf(T ad);

  /// Type-safe paid event wiring — subclass override.
  void attachPaidEvent(
    T ad,
    void Function(double valueMicros, String currencyCode) onPaid,
  );

  /// Hook khi ad load thành công + cache. Default no-op.
  /// `RewardedHandler` override để map ad → placement qua Expando.
  @protected
  void onAdLoadedHook(T ad, String placement) {}

  /// Lookup `AdUnit` từ config cho placement. Subclass implement để base
  /// không phải switch trên `type` string (fragile, thêm type mới hay quên).
  @protected
  AdUnit? lookupUnit(AdConfig cfg, String placement);

  // ── Per-TYPE state (1 instance per handler — Inter/AppOpen/Rewarded) ──
  /// Last show time tính chung cho cả type — Inter splash + Inter after_quiz
  /// share cùng `interInterval` cooldown. Industry standard.
  DateTime? _lastShownAtType;

  /// Tổng số ad show trong session — share cho mọi placement của type.
  int _sessionCountType = 0;

  // ── Per-PLACEMENT state ──────────────────────────────────────────────
  final Map<String, Completer<bool>> _loading = {};
  final Map<String, AdUnit> _knownUnits = {};

  /// Set placement đang trong quá trình show. Clear ở callback
  /// `onAdDismissedFullScreenContent` / `onAdFailedToShowFullScreenContent`
  /// (chứ KHÔNG ở `finally` block của `show()` — vì `showAd(ad)` resolve
  /// ngay khi SDK present, ad vẫn còn trên màn → tránh double-show).
  final Set<String> _showing = <String>{};

  String cacheKey(String placement) => '${type}_$placement';
  String statsKey(String placement) => '$type.$placement';

  // ── Public API ───────────────────────────────────────────────

  void preload(AdUnit? unit, String placement, AdConfig cfg) {
    if (!cfg.unitEnabled(unit)) return;
    if (cache.isReady(cacheKey(placement))) return;
    if (_loading.containsKey(placement)) return;
    _startLoad(unit!, placement);
  }

  Future<bool> show({
    required AdUnit? unit,
    required String placement,
    required AdConfig cfg,
    VoidCallback? onDismissed,
    VoidCallback? onShown,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final sKey = statsKey(placement);

    if (!cfg.unitEnabled(unit)) {
      analytics.onAdAborted(adUnitName: sKey, reason: 'unit disabled');
      Logger.warning('[$type/$placement] aborted: unit disabled', tag: 'ADS');
      return false;
    }

    if (_showing.contains(placement)) {
      analytics.onAdAborted(adUnitName: sKey, reason: 'already showing');
      Logger.warning('[$type/$placement] aborted: already showing', tag: 'ADS');
      return false;
    }

    if (!_canShow(cfg.rules)) {
      analytics.onAdAborted(adUnitName: sKey, reason: 'frequency cap');
      Logger.warning('[$type/$placement] aborted: frequency cap', tag: 'ADS');
      return false;
    }

    _showing.add(placement);
    // Sentinel: nếu ad present thành công (await showAd returns), callback
    // dismiss/failed sẽ clear `_showing`. Ngược lại finally clear ở đây.
    var presented = false;

    try {
      analytics.onAdRequested(adUnitName: sKey, adUnitId: unit!.resolvedId);

      if (!cache.isReady(cacheKey(placement))) {
        if (!await network.isConnected) {
          analytics.onAdAborted(adUnitName: sKey, reason: 'offline');
          Logger.warning('[$type/$placement] aborted: offline', tag: 'ADS');
          return false;
        }
        Logger.info('[$type/$placement] not ready, loading...', tag: 'ADS');
        _startLoad(unit, placement);
        final loaded = await _loading[placement]!.future.timeout(
          timeout,
          onTimeout: () => false,
        );
        if (!loaded) {
          Logger.warning('[$type/$placement] load timeout', tag: 'ADS');
          return false;
        }
      }

      final ad = cache.get<T>(cacheKey(placement));
      if (ad == null) return false;

      _wireCallbacks(
        ad: ad,
        placement: placement,
        cfg: cfg,
        onDismissed: onDismissed,
        onShown: onShown,
      );

      try {
        await showAd(ad);
        presented = true; // callback sẽ clear `_showing` khi user dismiss
        return true;
      } catch (e, s) {
        analytics.onAdShowFailed(
          adUnitName: sKey,
          error: AdError(0, 'showAd exception', e.toString()),
        );
        Logger.error(
          '[$type/$placement] showAd threw',
          error: e,
          stackTrace: s,
          tag: 'ADS',
        );
        cache.remove(cacheKey(placement));
        return false;
      }
    } finally {
      if (!presented) _showing.remove(placement);
    }
  }

  void resetSession() {
    _sessionCountType = 0;
    _lastShownAtType = null;
    _retry.clear();
  }

  /// Hủy mọi pending retry timer — gọi khi app shutdown / consent withdrawn.
  void dispose() {
    _retry.clear();
    _knownUnits.clear();
  }

  // ── Internals ────────────────────────────────────────────────

  void _startLoad(AdUnit unit, String placement) {
    _knownUnits[placement] = unit;
    final completer = Completer<bool>();
    _loading[placement] = completer;

    loadFromSdk(
      unit: unit,
      onLoaded: (ad) {
        cache.set(cacheKey(placement), ad);
        _retry.reset(placement);
        onAdLoadedHook(ad, placement);
        Logger.adTable(
          '$type/$placement loaded ✅',
          tag: 'ADS',
          rows: [
            ('Type', type),
            ('Placement', placement),
            ('Ad ID', adUnitIdOf(ad)),
          ],
        );
        attachPaidEvent(ad, (valueMicros, currencyCode) {
          analytics.onAdRevenue(
            valueMicros: valueMicros,
            currencyCode: currencyCode,
            adUnitName: statsKey(placement),
            adFormat: type,
          );
        });
        _completeLoad(placement, true);
      },
      onFailed: (err) {
        analytics.onAdLoadFailed(adUnitName: statsKey(placement), error: err);
        Logger.adTable(
          '$type/$placement load failed ❌',
          tag: 'ADS',
          isError: true,
          rows: [
            ('Type', type),
            ('Placement', placement),
            ('Error', '${err.code} ${err.message}'),
          ],
        );
        _completeLoad(placement, false);
        _scheduleRetry(placement);
      },
    );
  }

  void _scheduleRetry(String placement) {
    final unit = _knownUnits[placement];
    if (unit == null) return;
    final scheduled = _retry.scheduleRetry(placement, () async {
      if (cache.isReady(cacheKey(placement))) return;
      if (_loading.containsKey(placement)) return;
      if (!await network.isConnected) {
        _retry.reset(placement);
        return;
      }
      Logger.info(
        '[$type/$placement] retry attempt ${_retry.attemptsFor(placement)}',
        tag: 'ADS',
      );
      _startLoad(unit, placement);
    });
    if (!scheduled) {
      Logger.warning(
        '[$type/$placement] retries exhausted (${retryPolicy.maxRetries})',
        tag: 'ADS',
      );
    }
  }

  void _completeLoad(String placement, bool success) {
    final c = _loading.remove(placement);
    if (c != null && !c.isCompleted) c.complete(success);
  }

  void _wireCallbacks({
    required T ad,
    required String placement,
    required AdConfig cfg,
    VoidCallback? onDismissed,
    VoidCallback? onShown,
  }) {
    final sKey = statsKey(placement);

    final cb = FullScreenContentCallback<T>(
      onAdShowedFullScreenContent: (ad) {
        // Frequency cap counter — per-TYPE, không per-placement.
        _lastShownAtType = DateTime.now();
        _sessionCountType += 1;
        analytics.onAdImpression(adUnitName: sKey, ad: ad);
        Logger.adTable(
          '$type/$placement showed ✅',
          tag: 'ADS',
          rows: [
            ('Type', type),
            ('Placement', placement),
            ('Ad ID', adUnitIdOf(ad)),
          ],
        );
        onShown?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        // ⚡ Clear `_showing` Ở ĐÂY (sau khi user dismiss), không phải finally
        // của `show()` — tránh double-show khi user spam button.
        _showing.remove(placement);
        cache.remove(cacheKey(placement));
        final unit = lookupUnit(cfg, placement);
        if (unit != null) _startLoad(unit, placement);
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _showing.remove(placement);
        analytics.onAdShowFailed(adUnitName: sKey, error: err);
        cache.remove(cacheKey(placement));
        Logger.adTable(
          '$type/$placement show failed ❌',
          tag: 'ADS',
          isError: true,
          rows: [('Error', '${err.code} ${err.message}')],
        );
      },
      onAdClicked: (ad) => analytics.onAdClicked(adUnitName: sKey),
    );

    setFullScreenCallback(ad, cb);
  }

  /// Frequency cap — áp dụng per-TYPE (toàn handler).
  bool _canShow(AdRules rules) {
    final max = maxPerSession(rules);
    if (max != null && _sessionCountType >= max) return false;
    final last = _lastShownAtType;
    if (last == null) return true;
    return DateTime.now().difference(last).inSeconds >= intervalSeconds(rules);
  }
}
