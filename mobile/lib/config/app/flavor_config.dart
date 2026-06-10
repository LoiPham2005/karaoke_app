import 'package:flutter_base/core/common/constants/api_constants.dart';
import 'package:flutter_base/core/common/utils/logger.dart';

/// 🌍 Các Flavor (môi trường) hỗ trợ
enum AppFlavor { dev, stg, prod }

/// 🔧 Quản lý cấu hình Flavor (Singleton Pattern)
///
/// Sử dụng:
/// ```dart
/// // Trong main_dev.dart
/// void main() => mainCommon(AppFlavor.dev);
///
/// // Trong app
/// if (FlavorConfig.isDev) { ... }
/// final url = FlavorConfig.apiBaseUrl;
/// ```
class FlavorConfig {
  FlavorConfig._();

  static AppFlavor? _current;

  /// ✅ Thiết lập Flavor (chỉ gọi 1 lần trong main)
  static void setFlavor(AppFlavor flavor) {
    if (_current != null) {
      // Nếu đã set rồi thì không throw lỗi crash app, chỉ warning
      Logger.warning(
        '⛔ Flavor đã được set là ${_current!.name}, không thể đổi sang ${flavor.name}!',
        tag: 'FLAVOR',
      );
      return;
    }
    _current = flavor;
    Logger.info(
      '🚀 App started with flavor: ${flavor.name.toUpperCase()}',
      tag: 'FLAVOR',
    );
  }

  /// 🌍 Lấy Flavor hiện tại (Safe Getter)
  static AppFlavor get flavor {
    assert(
      _current != null,
      '⛔ Chưa gọi FlavorConfig.setFlavor()! Hãy gọi nó trong mainCommon.',
    );
    return _current!;
  }

  // ════════════════════════════════════════════════════════════════
  // FLAVOR CHECKS
  // ════════════════════════════════════════════════════════════════
  static bool get isDev => flavor == AppFlavor.dev;
  static bool get isStg => flavor == AppFlavor.stg;
  static bool get isProd => flavor == AppFlavor.prod;

  // Crash reporting: Chỉ bật trên Production và Staging
  static bool get enableCrashReporting => isProd || isStg;

  // ════════════════════════════════════════════════════════════════
  // API CONFIGURATION
  // ════════════════════════════════════════════════════════════════
  static String get apiBaseUrl => switch (flavor) {
    AppFlavor.dev => ApiConstants.baseUrlDev,
    AppFlavor.stg => ApiConstants.baseUrlStg,
    AppFlavor.prod => ApiConstants.baseUrlProd,
  };

  static String get webSocketUrl => switch (flavor) {
    AppFlavor.dev => ApiConstants.wsUrlDev,
    AppFlavor.stg => ApiConstants.wsUrlStg,
    AppFlavor.prod => ApiConstants.wsUrlProd,
  };

  // ════════════════════════════════════════════════════════════════
  // FEATURE FLAGS & CONFIGS
  // ════════════════════════════════════════════════════════════════
  static bool get enableLogging => switch (flavor) {
    AppFlavor.dev => ApiConstants.enableLoggingDev,
    AppFlavor.stg => ApiConstants.enableLoggingStg,
    AppFlavor.prod => ApiConstants.enableLoggingProd,
  };

  static bool get enableDebugTools => switch (flavor) {
    AppFlavor.dev => ApiConstants.enableDebugToolsDev,
    AppFlavor.stg => ApiConstants.enableDebugToolsStg,
    AppFlavor.prod => ApiConstants.enableDebugToolsProd,
  };

  static bool get enableAnalytics => switch (flavor) {
    AppFlavor.dev => ApiConstants.enableAnalyticsDev,
    AppFlavor.stg => ApiConstants.enableAnalyticsStg,
    AppFlavor.prod => ApiConstants.enableAnalyticsProd,
  };

  // ════════════════════════════════════════════════════════════════
  // TIMEOUTS
  // ════════════════════════════════════════════════════════════════
  static Duration get connectTimeout => switch (flavor) {
    AppFlavor.dev => ApiConstants.connectTimeoutDev,
    AppFlavor.stg => ApiConstants.connectTimeoutStg,
    AppFlavor.prod => ApiConstants.connectTimeoutProd,
  };

  static Duration get receiveTimeout => switch (flavor) {
    AppFlavor.dev => ApiConstants.receiveTimeoutDev,
    AppFlavor.stg => ApiConstants.receiveTimeoutStg,
    AppFlavor.prod => ApiConstants.receiveTimeoutProd,
  };

  // ════════════════════════════════════════════════════════════════
  // API KEYS
  // ════════════════════════════════════════════════════════════════
  static String get googleMapsApiKey => switch (flavor) {
    AppFlavor.dev => ApiConstants.googleMapsKeyDev,
    AppFlavor.stg => ApiConstants.googleMapsKeyStg,
    AppFlavor.prod => ApiConstants.googleMapsKeyProd,
  };

  static String get stripePublicKey => switch (flavor) {
    AppFlavor.dev => ApiConstants.stripeKeyDev,
    AppFlavor.stg => ApiConstants.stripeKeyStg,
    AppFlavor.prod => ApiConstants.stripeKeyProd,
  };

  // ════════════════════════════════════════════════════════════════
  // DEBUG INFO
  // ════════════════════════════════════════════════════════════════
  static void printInfo() {
    if (_current == null) {
      Logger.warning('Flavor chưa được set!', tag: 'FLAVOR');
      return;
    }

    const borderWidth = 55;
    String pad(String text) => text.padRight(borderWidth - 4);

    final info = [
      '🌍 FLAVOR INFO',
      'Flavor: ${flavor.name.toUpperCase()}',
      'API Base URL: $apiBaseUrl',
      'WebSocket URL: $webSocketUrl',
      'Logging: ${enableLogging ? "✅" : "❌"}',
      'Debug Tools: ${enableDebugTools ? "✅" : "❌"}',
      'Analytics: ${enableAnalytics ? "✅" : "❌"}',
      'Crash Reporting: ${enableCrashReporting ? "✅" : "❌"}',
    ];

    final buffer = StringBuffer()..writeln('╔${'═' * (borderWidth - 1)}╗');

    for (int i = 0; i < info.length; i++) {
      final line = info[i];
      buffer.writeln('║ ${pad(line)} ║');
      if (i == 0) {
        buffer.writeln('╠${'═' * (borderWidth - 1)}╣');
      }
    }

    buffer.writeln('╚${'═' * (borderWidth - 1)}╝');

    Logger.info('\n${buffer.toString()}', tag: 'FLAVOR');
  }
}
