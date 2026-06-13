import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:karaoke/modules/ads/models/ad_config.dart';
import 'package:karaoke/modules/ads/models/ad_placements.dart';
import 'package:karaoke/modules/ads/services/ad_manager.dart';
import 'package:karaoke/modules/ads/utils/ad_retry_policy.dart';
import 'package:karaoke/modules/ads/utils/ad_sizes.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({required this.placement, super.key});

  /// Placement type trong `AdConfig.banner` (vd: `BannerPlacement.home`).
  final BannerPlacement placement;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  AdSize? _adSize;

  /// Width đã LOAD xong — set ở `onAdLoaded`.
  int? _loadedWidth;

  /// Width đang MUỐN load (latest từ MediaQuery). Khi load completes mà
  /// width hiện tại đã khác → reload ngay với size đúng (tránh banner
  /// portrait dính trên landscape).
  int? _desiredWidth;

  /// Retry policy riêng cho banner — tránh hammer SDK khi network kém.
  static const _retryPolicy = AdRetryPolicy(maxRetries: 2);
  final _retry = AdRetryTracker(_retryPolicy);
  static const _retryKey = 'banner';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width.truncate();
    _desiredWidth = width;

    if (_isLoading) return; // đang load → onAdLoaded sẽ tự check mismatch
    if (_isLoaded && _loadedWidth == width) return;
    if (_isLoaded && _loadedWidth != width) {
      // Width đổi (rotate) → dispose ad cũ + load size mới.
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      _adSize = null;
    }
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;

    final size = await AdSizes.adaptiveBanner(context);
    if (!mounted) {
      _isLoading = false;
      return;
    }

    final unit = getIt<AdManager>().bannerUnit(widget.placement);
    if (unit == null) {
      _isLoading = false;
      return;
    }

    final width = MediaQuery.of(context).size.width.truncate();
    _desiredWidth = width;

    _bannerAd = BannerAd(
      adUnitId: unit.resolvedId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          // ⚡ Mid-load rotation guard: nếu user xoay trong lúc load → width
          // hiện tại khác width đã request → dispose ad lệch size, load lại.
          final currentWidth = _desiredWidth ??
              MediaQuery.of(context).size.width.truncate();
          if (currentWidth != width) {
            Logger.warning(
              'BannerAd[${widget.placement.key}] width mismatch '
              '(loaded=$width, current=$currentWidth) → reload',
              tag: 'ADS',
            );
            ad.dispose();
            _bannerAd = null;
            _isLoading = false;
            _loadAd();
            return;
          }
          _retry.reset(_retryKey);
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _isLoading = false;
            _adSize = size;
            _loadedWidth = width;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
          _isLoading = false;
          Logger.warning(
            'BannerAd[${widget.placement.key}] failed: ${err.message}',
            tag: 'ADS',
          );
          if (!mounted) return;
          _retry.scheduleRetry(_retryKey, () {
            if (mounted) _loadAd();
          });
        },
      ),
    );
    // ignore: unawaited_futures
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _retry.clear();
    _bannerAd?.dispose();
    _bannerAd = null;
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
