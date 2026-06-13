import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdFullScreen extends StatelessWidget {
  const NativeAdFullScreen({
    required this.ad,
    required this.onClosed,
    super.key,
  });

  final NativeAd ad;
  final VoidCallback onClosed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      // ⚡ KHÔNG bọc SafeArea ở body — để MediaView fill toàn màn (bleed
      // qua statusbar). Nút X tự padding khỏi notch qua `MediaQuery.padding`.
      body: Stack(
        children: [
          Positioned.fill(child: AdWidget(ad: ad)),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClosed,
                tooltip: 'Close',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
