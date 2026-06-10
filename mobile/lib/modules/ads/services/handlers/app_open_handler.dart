import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

import '../../models/ad_config.dart';
import '../ad_cache_service.dart';
import '../ad_stats_service.dart';
import 'full_screen_ad_handler.dart';

@lazySingleton
class AppOpenHandler extends FullScreenAdHandler<AppOpenAd> {
  AppOpenHandler(AdCacheService cache, AdAnalyticsService analytics)
      : super(cache: cache, analytics: analytics);

  @override
  String get type => 'app_open';

  @override
  int intervalSeconds(AdRules rules) => rules.appOpenInterval;

  @override
  int? maxPerSession(AdRules rules) => null; // unlimited

  @override
  void loadFromSdk({
    required AdUnit unit,
    required void Function(AppOpenAd ad) onLoaded,
    required void Function(LoadAdError err) onFailed,
  }) {
    AppOpenAd.load(
      adUnitId: unit.resolvedId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  @override
  Future<void> showAd(AppOpenAd ad) => ad.show();

  @override
  void setFullScreenCallback(AppOpenAd ad, FullScreenContentCallback<AppOpenAd> cb) {
    ad.fullScreenContentCallback = cb;
  }
}
