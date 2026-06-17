import 'package:flutter/foundation.dart';

enum AppFlavor { dev, stg, prod }

/// Singleton holder cho cấu hình theo flavor (dev / stg / prod).
///
/// Cách dùng:
/// ```dart
/// FlavorConfig.setFlavor(AppFlavor.dev);      // gọi 1 lần trong mainCommon
/// FlavorConfig.current.apiBaseUrl;            // truy cập
/// ```
@immutable
class FlavorConfig {
  const FlavorConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.enableAnalytics,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final bool enableCrashlytics;
  final bool enableAnalytics;

  static FlavorConfig? _instance;

  /// Đã được setFlavor() chưa.
  static bool get isInitialized => _instance != null;

  /// Truy cập snapshot config hiện tại. Nếu chưa setFlavor → throw.
  static FlavorConfig get current {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'FlavorConfig has not been initialized. '
        'Call FlavorConfig.setFlavor() in main_<flavor>.dart first.',
      );
    }
    return i;
  }

  /// Alias cũ — giữ để backwards-compat, prefer `current`.
  static FlavorConfig get instance => current;

  static bool get isDev => current.flavor == AppFlavor.dev;
  static bool get isStg => current.flavor == AppFlavor.stg;
  static bool get isProd => current.flavor == AppFlavor.prod;

  static void setFlavor(AppFlavor flavor) {
    _instance = switch (flavor) {
      // ⚠️ DEV backend thật. Base URL đã gồm `/api/v1`, service path là
      // `/auth/login` → request đầy đủ: `<base>/auth/login`.
      //
      // `10.0.2.2` = alias Android emulator trỏ về `localhost` của máy host.
      // 👉 Máy thật / iOS simulator KHÔNG hiểu `10.0.2.2`. Đổi thành LAN IP
      //    của máy chạy backend, ví dụ: 'http://192.168.1.10:3001/api/v1'
      //    (xem IP bằng `ipconfig getifaddr en0` trên macOS).
      AppFlavor.dev => const FlavorConfig._(
        flavor: AppFlavor.dev,
        apiBaseUrl: 'http://192.168.1.101:3001/api/v1',
        appName: 'AppDev',
        enableLogging: true,
        enableCrashlytics: false,
        enableAnalytics: false,
      ),
      AppFlavor.stg => const FlavorConfig._(
        flavor: AppFlavor.stg,
        apiBaseUrl: 'https://api-stg.example.com',
        appName: 'AppStg',
        enableLogging: true,
        enableCrashlytics: true,
        enableAnalytics: true,
      ),
      AppFlavor.prod => const FlavorConfig._(
        flavor: AppFlavor.prod,
        apiBaseUrl: 'https://api.example.com',
        appName: 'App',
        enableLogging: false,
        enableCrashlytics: true,
        enableAnalytics: true,
      ),
    };
  }
}
