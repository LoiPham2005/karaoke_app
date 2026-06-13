import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/models/ad_placements.dart';
import 'package:karaoke/modules/ads/services/ad_manager.dart';
import 'package:karaoke/modules/ads/utils/ad_retry_policy.dart';

/// 3 loại native widget — match factory native (Android XML + iOS XIB):
/// - `small`  → factory `nativeSmall`  (~80dp, in-feed list compact)
/// - `medium` → factory `nativeMedium` (~300dp, in-feed card lớn)
/// - `full`   → factory `nativeFull`   (dùng cho overlay full-screen,
///                                       hiếm khi nhúng inline)
enum NativeAdSize {
  small,
  medium,
  full;

  String get factoryId => switch (this) {
        NativeAdSize.small => 'nativeSmall',
        NativeAdSize.medium => 'nativeMedium',
        NativeAdSize.full => 'nativeFull',
      };

  /// Chiều cao đủ để render hết layout XML (Android) / XIB (iOS).
  /// Thiếu height → widget clip mất CTA button hoặc body.
  ///   small  → 100dp (icon + headline + CTA compact)
  ///   medium → 360dp (media 180 + icon row + body 2 line + CTA 40)
  ///   full   → 600dp (chỉ dùng khi nhúng inline; overlay full-screen
  ///                    tự fill match_parent qua `NativeAdFullScreen`)
  double get defaultHeight => switch (this) {
        NativeAdSize.small => 100,
        NativeAdSize.medium => 360,
        NativeAdSize.full => 600,
      };
}

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({
    required this.placement,
    super.key,
    this.size = NativeAdSize.medium,
    this.height,
  });

  final PlacementKey placement;
  final NativeAdSize size;

  /// Override chiều cao mặc định. Set khi muốn nhúng vào layout có chiều cao
  /// cố định khác (vd: trong list 100, banner header 120).
  final double? height;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  static const _retryPolicy = AdRetryPolicy(maxRetries: 2);
  final _retry = AdRetryTracker(_retryPolicy);
  static const _retryKey = 'native';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (_isLoaded || _isLoading) return;
    final unit = getIt<AdManager>().nativeUnit(widget.placement);
    if (unit == null) return;
    _isLoading = true;

    _nativeAd = NativeAd(
      adUnitId: unit.resolvedId,
      factoryId: widget.size.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          _retry.reset(_retryKey);
          setState(() {
            _isLoaded = true;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
          _isLoading = false;
          Logger.warning(
            'NativeAd[${widget.placement.key}] failed: ${error.message}',
            tag: 'ADS',
          );
          if (!mounted) return;
          _retry.scheduleRetry(_retryKey, () {
            if (mounted) _loadAd();
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _retry.clear();
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: (widget.height ?? widget.size.defaultHeight).h,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
