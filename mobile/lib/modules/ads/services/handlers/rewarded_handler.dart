import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

import '../../models/ad_config.dart';
import '../ad_cache_service.dart';
import '../ad_stats_service.dart';
import 'full_screen_ad_handler.dart';

@lazySingleton
class RewardedHandler extends FullScreenAdHandler<RewardedAd> {
  RewardedHandler(AdCacheService cache, AdAnalyticsService analytics)
      : super(cache: cache, analytics: analytics);

  @override
  String get type => 'rewarded';

  @override
  int intervalSeconds(AdRules rules) => rules.rewardedInterval;

  @override
  int? maxPerSession(AdRules rules) => rules.maxRewardedPerSession;

  @override
  void loadFromSdk({
    required AdUnit unit,
    required void Function(RewardedAd ad) onLoaded,
    required void Function(LoadAdError err) onFailed,
  }) {
    RewardedAd.load(
      adUnitId: unit.resolvedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  /// ⚠️ Cho rewarded, dùng [showRewarded] thay vì [show] để nhận callback reward.
  @override
  Future<void> showAd(RewardedAd ad) => ad.show(onUserEarnedReward: (_, __) {});

  @override
  void setFullScreenCallback(RewardedAd ad, FullScreenContentCallback<RewardedAd> cb) {
    ad.fullScreenContentCallback = cb;
  }

  /// API riêng để lấy reward.
  Future<bool> showRewarded({
    required AdUnit? unit,
    required String placement,
    required AdConfig cfg,
    void Function(RewardItem reward)? onEarnedReward,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final earned = Completer<bool>();
    final shown = await show(
      unit: unit,
      placement: placement,
      cfg: cfg,
      timeout: timeout,
      onDismissed: () {
        if (!earned.isCompleted) earned.complete(false);
      },
    );

    if (!shown) return false;

    // Override show với onUserEarnedReward
    final ad = cache.get<RewardedAd>(cacheKey(placement));
    if (ad != null) {
      await ad.show(onUserEarnedReward: (_, reward) {
        onEarnedReward?.call(reward);
        if (!earned.isCompleted) earned.complete(true);
      });
    }

    return earned.future;
  }
}
