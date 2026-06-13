import 'package:flutter/services.dart';
import 'package:karaoke/core/common/utils/device_info.dart';

abstract class SystemUIManager {
  static Future<void> setup() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    await applyUiMode();
  }

  /// Giữ status bar, ẩn navigation bar dưới.
  ///
  /// - **Android**: `SystemUiMode.manual` + chỉ overlay `top`. Đây là mode DUY
  ///   NHẤT tôn trọng tham số `overlays` (các mode immersive/edgeToEdge đều bỏ
  ///   qua nó), nên status bar luôn hiện còn nav bar ẩn vĩnh viễn — đúng ý muốn.
  /// - **iOS/khác**: `edgeToEdge` → hiện đủ status bar + home indicator, nội
  ///   dung vẽ tràn ra sau (iOS không có nav bar kiểu Android để ẩn).
  static Future<void> applyUiMode() async {
    if (DeviceInfo.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: const [SystemUiOverlay.top],
      );
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
