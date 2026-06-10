// ═══════════════════════════════════════════════════════════════
// SVG & IMAGE HELPERS
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

extension ImageExtensions on String {
  /// Detect if path is SVG
  bool get isSvg => toLowerCase().endsWith('.svg');

  /// Detect if path is image (PNG, JPG, etc)
  bool get isImage =>
      toLowerCase().endsWith('.png') ||
      toLowerCase().endsWith('.jpg') ||
      toLowerCase().endsWith('.jpeg') ||
      toLowerCase().endsWith('.gif') ||
      toLowerCase().endsWith('.webp');

  /// Load as SVG with optional styling
  Widget toSvg({
    double? height,
    double? width,
    Color? color,
    BoxFit fit = BoxFit.contain,
    BlendMode? blendMode,
  }) {
    return SvgPicture.asset(
      this,
      height: height,
      width: width,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color, blendMode ?? BlendMode.srcIn)
          : null,
    );
  }

  /// Load as Image Asset
  Widget toImage({
    double? height,
    double? width,
    Color? color,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      this,
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }

  /// Smart load - auto detect SVG or Image
  Widget toWidget({
    double? height,
    double? width,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return isSvg
        ? toSvg(height: height, width: width, color: color, fit: fit)
        : toImage(height: height, width: width, color: color, fit: fit);
  }
}

extension LottieAssetX on String {
  /// Load Lottie animation from asset path
  Widget lottie({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool animate = true,
    bool repeat = true,
    bool reverse = false,
    VoidCallback? onLoaded,
  }) {
    return Lottie.asset(
      this,
      width: width,
      height: height,
      fit: fit,
      animate: animate,
      repeat: repeat,
      reverse: reverse,
      onLoaded: (composition) {
        onLoaded?.call();
      },
    );
  }
}
