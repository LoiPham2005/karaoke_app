import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/data/network/network_info.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/services/ad_cache_service.dart';
import 'package:karaoke/modules/ads/services/ad_stats_service.dart';
import 'package:karaoke/modules/ads/services/handlers/full_screen_ad_handler.dart';

@lazySingleton
class RewardedHandler extends FullScreenAdHandler<RewardedAd> {
  RewardedHandler(
    AdCacheService cache,
    AdAnalyticsService analytics,
    NetworkInfo network,
  ) : super(cache: cache, analytics: analytics, network: network);

  /// Map placement → reward callback. `showAd()` consume sau khi `ad.show()`
  /// trigger `onUserEarnedReward`.
  final Map<String, void Function(RewardItem reward)?> _rewardCallbacks = {};

  /// ⚡ Expando = weak association ad → placement. Race-free vì mỗi `RewardedAd`
  /// object có tag riêng (gắn ở `onAdLoadedHook`). Khi ad GC → tag tự dọn,
  /// không leak. Thay cho `_pendingPlacement` field (race khi user trigger 2
  /// placement khác nhau gần nhau).
  final Expando<String> _adPlacementTag = Expando<String>('rewarded_placement');

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

  @override
  void onAdLoadedHook(RewardedAd ad, String placement) {
    _adPlacementTag[ad] = placement;
  }

  @override
  Future<void> showAd(RewardedAd ad) async {
    // Đọc tag từ Expando → 100% match đúng ad đang show, không phụ thuộc
    // thứ tự gọi `showRewarded()` của caller.
    final placement = _adPlacementTag[ad];
    final cb = placement != null ? _rewardCallbacks.remove(placement) : null;
    await ad.show(onUserEarnedReward: (_, reward) {
      cb?.call(reward);
    });
  }

  @override
  void setFullScreenCallback(
    RewardedAd ad,
    FullScreenContentCallback<RewardedAd> cb,
  ) {
    ad.fullScreenContentCallback = cb;
  }

  @override
  AdUnit? lookupUnit(AdConfig cfg, String placement) => cfg.adUnits.rewarded[placement];

  @override
  String adUnitIdOf(RewardedAd ad) => ad.adUnitId;

  @override
  void attachPaidEvent(
    RewardedAd ad,
    void Function(double valueMicros, String currencyCode) onPaid,
  ) {
    ad.onPaidEvent = (_, valueMicros, _, currencyCode) =>
        onPaid(valueMicros, currencyCode);
  }

  /// API riêng để gọi reward — set callback rồi gọi base `show()`.
  /// Race-free: không còn `_pendingPlacement`; ad → placement đã được map
  /// ở `onAdLoadedHook` lúc load xong.
  Future<bool> showRewarded({
    required AdUnit? unit,
    required String placement,
    required AdConfig cfg,
    void Function(RewardItem reward)? onEarnedReward,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _rewardCallbacks[placement] = onEarnedReward;

    final shown = await show(
      unit: unit,
      placement: placement,
      cfg: cfg,
      timeout: timeout,
      onDismissed: () => _rewardCallbacks.remove(placement),
    );

    if (!shown) _rewardCallbacks.remove(placement);

    return shown;
  }
}
