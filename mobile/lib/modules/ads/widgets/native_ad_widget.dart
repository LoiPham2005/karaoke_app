import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/base/di/injection.dart';
import '../models/ad_config.dart';
import '../models/ad_placements.dart';
import '../services/ad_manager.dart';

enum NativeAdSize { small, medium }

class NativeAdWidget extends StatefulWidget {
  final PlacementKey placement;
  final NativeAdSize size;

  const NativeAdWidget({super.key, required this.placement, this.size = NativeAdSize.medium});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final unit = getIt<AdManager>().nativeUnit(widget.placement);
    if (unit == null) return;

    final factoryId = widget.size == NativeAdSize.small ? 'nativeSmall' : 'nativeMedium';

    _nativeAd = NativeAd(
      adUnitId: unit.resolvedId,
      // nativeTemplateStyle: NativeTemplateStyle(
      //   templateType: widget.size == NativeAdSize.small ? TemplateType.small : TemplateType.medium,
      // ),
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) return const SizedBox.shrink();
    final height = widget.size == NativeAdSize.small ? 80.h : 300.h;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
