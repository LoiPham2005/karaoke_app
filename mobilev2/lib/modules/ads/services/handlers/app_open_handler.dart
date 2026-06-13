import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/data/network/network_info.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/models/ad_placements.dart';
import 'package:karaoke/modules/ads/services/ad_cache_service.dart';
import 'package:karaoke/modules/ads/services/ad_stats_service.dart';
import 'package:karaoke/modules/ads/services/handlers/full_screen_ad_handler.dart';

@lazySingleton
class AppOpenHandler extends FullScreenAdHandler<AppOpenAd> {
  AppOpenHandler(
    AdCacheService cache,
    AdAnalyticsService analytics,
    NetworkInfo network,
  ) : super(cache: cache, analytics: analytics, network: network);

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
  void setFullScreenCallback(
    AppOpenAd ad,
    FullScreenContentCallback<AppOpenAd> cb,
  ) {
    ad.fullScreenContentCallback = cb;
  }

  /// AppOpen có fallback đặc biệt: nếu placement cụ thể không có config,
  /// dùng `resume` làm fallback (resume là placement chung mặc định).
  @override
  AdUnit? lookupUnit(AdConfig cfg, String placement) =>
      cfg.adUnits.appOpen[placement] ??
      cfg.adUnits.appOpen[AppOpenPlacement.resume.key];

  @override
  String adUnitIdOf(AppOpenAd ad) => ad.adUnitId;

  @override
  void attachPaidEvent(
    AppOpenAd ad,
    void Function(double valueMicros, String currencyCode) onPaid,
  ) {
    ad.onPaidEvent = (_, valueMicros, _, currencyCode) =>
        onPaid(valueMicros, currencyCode);
  }
}
