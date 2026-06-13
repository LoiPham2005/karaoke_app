import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/data/network/network_info.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/services/ad_cache_service.dart';
import 'package:karaoke/modules/ads/services/ad_stats_service.dart';
import 'package:karaoke/modules/ads/services/handlers/full_screen_ad_handler.dart';

@lazySingleton
class InterHandler extends FullScreenAdHandler<InterstitialAd> {
  InterHandler(
    AdCacheService cache,
    AdAnalyticsService analytics,
    NetworkInfo network,
  ) : super(cache: cache, analytics: analytics, network: network);

  @override
  String get type => 'inter';

  @override
  int intervalSeconds(AdRules rules) => rules.interInterval;

  @override
  int? maxPerSession(AdRules rules) => rules.maxInterPerSession;

  @override
  void loadFromSdk({
    required AdUnit unit,
    required void Function(InterstitialAd ad) onLoaded,
    required void Function(LoadAdError err) onFailed,
  }) {
    InterstitialAd.load(
      adUnitId: unit.resolvedId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  @override
  Future<void> showAd(InterstitialAd ad) => ad.show();

  @override
  void setFullScreenCallback(
    InterstitialAd ad,
    FullScreenContentCallback<InterstitialAd> cb,
  ) {
    ad.fullScreenContentCallback = cb;
  }

  @override
  AdUnit? lookupUnit(AdConfig cfg, String placement) => cfg.adUnits.inter[placement];

  @override
  String adUnitIdOf(InterstitialAd ad) => ad.adUnitId;

  @override
  void attachPaidEvent(
    InterstitialAd ad,
    void Function(double valueMicros, String currencyCode) onPaid,
  ) {
    ad.onPaidEvent = (_, valueMicros, _, currencyCode) =>
        onPaid(valueMicros, currencyCode);
  }
}
