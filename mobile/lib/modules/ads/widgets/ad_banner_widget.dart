import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/base/di/injection.dart';
import '../models/ad_config.dart';
import '../models/ad_placements.dart';
import '../services/ad_manager.dart';
import '../utils/ad_sizes.dart';

class AdBannerWidget extends StatefulWidget {
  /// Placement type trong `AdConfig.banner` (vd: `BannerPlacement.home`).
  final BannerPlacement placement;

  const AdBannerWidget({super.key, required this.placement});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isLoaded) return;

    final size = await AdSizes.adaptiveBanner(context);
    final unit = getIt<AdManager>().bannerUnit(widget.placement);
    if (unit == null) return;

    _bannerAd = BannerAd(
      adUnitId: unit.resolvedId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('BannerAd[${widget.placement}] failed to load: $err');
        },
      ),
    // ignore: unawaited_futures
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null || _adSize == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _adSize!.width.toDouble(),
      height: _adSize!.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
