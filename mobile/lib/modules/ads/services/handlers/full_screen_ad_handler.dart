import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/ad_config.dart';
import '../../models/ad_placements.dart';
import '../ad_cache_service.dart';
import '../ad_stats_service.dart';

/// Base class cho ads dạng full-screen (Inter, AppOpen, Rewarded).
abstract class FullScreenAdHandler<T extends AdWithoutView> {
  FullScreenAdHandler({
    required this.cache,
    required this.analytics,
  });

  final AdCacheService cache;
  final AdAnalyticsService analytics;

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

  // ── Per-placement state ──────────────────────────────────────
  final Map<String, DateTime> _lastShownAt = {};
  final Map<String, int> _sessionCount = {};
  final Map<String, Completer<bool>> _loading = {};

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

    if (!_canShow(placement, cfg.rules)) {
      analytics.onAdAborted(adUnitName: sKey, reason: 'frequency cap');
      Logger.warning('[$type/$placement] aborted: frequency cap', tag: 'ADS');
      return false;
    }

    analytics.onAdRequested(adUnitName: sKey, adUnitId: unit!.resolvedId);

    if (!cache.isReady(cacheKey(placement))) {
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

    _wireCallbacks(ad: ad, placement: placement, cfg: cfg, onDismissed: onDismissed, onShown: onShown);
    await showAd(ad);
    return true;
  }

  void resetSession() {
    _sessionCount.clear();
    _lastShownAt.clear();
  }

  // ── Internals ────────────────────────────────────────────────

  void _startLoad(AdUnit unit, String placement) {
    final completer = Completer<bool>();
    _loading[placement] = completer;

    loadFromSdk(
      unit: unit,
      onLoaded: (ad) {
        cache.set(cacheKey(placement), ad);
        Logger.adTable(
          '$type/$placement loaded ✅',
          tag: 'ADS',
          rows: [('Type', type), ('Placement', placement), ('Ad ID', _adId(ad))],
        );
        _attachPaidEvent(ad, placement);
        _completeLoad(placement, true);
      },
      onFailed: (err) {
        analytics.onAdLoadFailed(adUnitName: statsKey(placement), error: err);
        Logger.adTable(
          '$type/$placement load failed ❌',
          tag: 'ADS',
          isError: true,
          rows: [('Type', type), ('Placement', placement), ('Error', '${err.code} ${err.message}')],
        );
        _completeLoad(placement, false);
      },
    );
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
        analytics.onAdImpression(adUnitName: sKey, ad: ad);
        Logger.adTable(
          '$type/$placement showed ✅',
          tag: 'ADS',
          rows: [('Type', type), ('Placement', placement), ('Ad ID', ad.adUnitId)],
        );
        onShown?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        cache.remove(cacheKey(placement));
        _lastShownAt[placement] = DateTime.now();
        _sessionCount[placement] = (_sessionCount[placement] ?? 0) + 1;
        final unit = _lookupUnit(cfg, placement);
        if (unit != null) _startLoad(unit, placement);
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
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

  void _attachPaidEvent(T ad, String placement) {
    try {
      (ad as dynamic).onPaidEvent =
          (Ad _, double valueMicros, PrecisionType _, String currencyCode) {
        analytics.onAdRevenue(
          valueMicros: valueMicros,
          currencyCode: currencyCode,
          adUnitName: statsKey(placement),
          adFormat: type,
        );
      };
    } catch (_) {}
  }

  String _adId(T ad) {
    try {
      return (ad as dynamic).adUnitId as String;
    } catch (_) {
      return 'unknown';
    }
  }

  AdUnit? _lookupUnit(AdConfig cfg, String placement) {
    return switch (type) {
      'inter' => cfg.inter[placement],
      'app_open' => cfg.appOpen[placement] ?? cfg.appOpen[AppOpenPlacement.resume.key],
      'rewarded' => cfg.rewarded[placement],
      _ => null,
    };
  }

  bool _canShow(String placement, AdRules rules) {
    final max = maxPerSession(rules);
    if (max != null && (_sessionCount[placement] ?? 0) >= max) return false;
    final last = _lastShownAt[placement];
    if (last == null) return true;
    return DateTime.now().difference(last).inSeconds >= intervalSeconds(rules);
  }
}
