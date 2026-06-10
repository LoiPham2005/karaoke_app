import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/core/common/utils/device_info.dart';
import 'package:flutter_base/core/common/utils/logger.dart';

/// Singleton class quản lý System UI cho toàn bộ ứng dụng
/// Xử lý ẩn/hiện bottom navigation bar và status bar
class SystemUIManager {
  SystemUIManager._();

  static final SystemUIManager instance = SystemUIManager._();

  Timer? _hideTimer;
  bool _isInitialized = false;
  int? _androidSdkVersion;

  /// Khởi tạo System UI khi app khởi động
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Lấy thông tin Android SDK version
    if (Platform.isAndroid) {
      _androidSdkVersion = await DeviceInfo.getAndroidSdkVersion(); // ✅ CHANGED
    }

    // Khóa orientation chỉ cho phép portrait
    await _setOrientation();

    // Cấu hình System UI theo platform
    if (Platform.isAndroid) {
      await _initializeAndroid();
    } else if (Platform.isIOS) {
      await _initializeIOS();
    }

    _isInitialized = true;
  }

  /// Khóa orientation portrait
  Future<void> _setOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Khởi tạo cho Android
  Future<void> _initializeAndroid() async {
    // Set màu transparent cho status bar và navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Ẩn navigation bar ngay lập tức
    await hideNavigationBar();

    // Đăng ký callback khi user vuốt hiện navigation bar
    await SystemChrome.setSystemUIChangeCallback(_handleSystemUIChange);
  }

  /// Khởi tạo cho iOS
  Future<void> _initializeIOS() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Xử lý khi System UI thay đổi (user vuốt để hiện navigation bar)
  Future<void> _handleSystemUIChange(bool systemOverlaysAreVisible) async {
    if (!Platform.isAndroid) return;

    // Khi navigation bar được hiện lên bởi user
    if (systemOverlaysAreVisible) {
      // Hủy timer cũ nếu có
      _hideTimer?.cancel();

      // Tự động ẩn lại sau 3 giây
      _hideTimer = Timer(const Duration(seconds: 3), () {
        hideNavigationBar();
      });
    }
  }

  /// Ẩn navigation bar
  Future<void> hideNavigationBar() async {
    if (!Platform.isAndroid) return;

    try {
      final SystemUiMode mode = _getSystemUiMode();

      await SystemChrome.setEnabledSystemUIMode(
        mode,
        overlays: [SystemUiOverlay.top], // Chỉ hiện status bar
      );
    } catch (e) {
      Logger.warning('Error hiding navigation bar: $e', tag: 'SYSTEM_UI');
    }
  }

  /// Hiện lại navigation bar
  Future<void> showNavigationBar() async {
    if (!Platform.isAndroid) return;

    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    } catch (e) {
      Logger.warning('Error showing navigation bar: $e', tag: 'SYSTEM_UI');
    }
  }

  /// Lấy SystemUiMode phù hợp theo SDK version
  SystemUiMode _getSystemUiMode() {
    // Android 11 (API 30) trở lên sử dụng manual mode
    // Android 10 trở xuống sử dụng immersive mode
    if (_androidSdkVersion != null && _androidSdkVersion! > 30) {
      return SystemUiMode.manual;
    } else {
      return SystemUiMode.immersive;
    }
  }

  /// Ẩn hoàn toàn cả status bar và navigation bar
  Future<void> enterFullscreen() async {
    if (!Platform.isAndroid) return;

    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    } catch (e) {
      Logger.warning('Error entering fullscreen: $e', tag: 'SYSTEM_UI');
    }
  }

  /// Thoát chế độ fullscreen
  Future<void> exitFullscreen() async {
    if (!Platform.isAndroid) return;

    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    } catch (e) {
      Logger.warning('Error exiting fullscreen: $e', tag: 'SYSTEM_UI');
    }
  }

  /// Cập nhật theme cho System UI (dark/light mode)
  void updateSystemUITheme({
    required Brightness brightness,
    Color? statusBarColor,
    Color? navigationBarColor,
  }) {
    if (!Platform.isAndroid) return;

    final isDark = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: navigationBarColor ?? Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  /// Cleanup khi dispose
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setSystemUIChangeCallback(null);
  }
}
