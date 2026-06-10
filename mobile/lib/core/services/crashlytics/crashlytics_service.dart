// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/crashlytics/crashlytics_service.dart
//
// Mục đích: Wrapper toàn bộ tương tác với Firebase Crashlytics.
// - Dễ mock trong test
// - Dễ swap sang Sentry hoặc provider khác nếu cần
// - Bật/tắt theo môi trường (Dev vs Production)
// ════════════════════════════════════════════════════════════════

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/core/common/utils/logger.dart';

class CrashlyticsService {
  CrashlyticsService._();

  static final CrashlyticsService instance = CrashlyticsService._();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  // ════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════════════

  /// Gọi NGAY SAU Firebase.initializeApp()
  /// Chỉ bật Crashlytics trên Production và Staging
  Future<void> initialize() async {
    // Dev: tắt crash reporting để không "ô nhiễm" dữ liệu thực
    // Prod/Stg: bật hoàn toàn
    final shouldEnable = !FlavorConfig.isDev && kReleaseMode;

    await _crashlytics.setCrashlyticsCollectionEnabled(shouldEnable);

    if (shouldEnable) {
      Logger.success('Crashlytics ENABLED (${FlavorConfig.flavor.name})', tag: 'CRASHLYTICS');
    } else {
      Logger.warning('Crashlytics DISABLED (Dev/Debug mode)', tag: 'CRASHLYTICS');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // USER IDENTITY
  // Giúp biết crash xảy ra trên user nào (không lưu thông tin nhạy cảm)
  // ════════════════════════════════════════════════════════════════

  /// Set user ID (dùng user ID, không dùng email/tên)
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      Logger.warning('Failed to set Crashlytics user ID', tag: 'CRASHLYTICS');
    }
  }

  /// Xóa user ID khi logout
  Future<void> clearUserId() async {
    try {
      await _crashlytics.setUserIdentifier('');
    } catch (e) {
      Logger.warning('Failed to clear Crashlytics user ID', tag: 'CRASHLYTICS');
    }
  }

  /// Set custom key-value để filter crash trong dashboard
  /// Ví dụ: ('screen', 'HomeScreen'), ('api_version', 'v2')
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      Logger.warning('Failed to set Crashlytics custom key: $key', tag: 'CRASHLYTICS');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ERROR RECORDING
  // ════════════════════════════════════════════════════════════════

  /// Ghi lại lỗi NON-FATAL (app vẫn chạy nhưng có lỗi)
  /// Dùng cho: API errors, try-catch blocks, lỗi logic
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, String>? context,
  }) async {
    try {
      // Thêm context keys trước khi record
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
        printDetails: kDebugMode,
      );
    } catch (e) {
      Logger.warning('Failed to record error to Crashlytics', tag: 'CRASHLYTICS');
    }
  }

  /// Ghi lại Flutter Framework errors (Fatal)
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterFatalError(details);
    } catch (e) {
      Logger.warning('Failed to record Flutter error to Crashlytics', tag: 'CRASHLYTICS');
    }
  }

  /// Ghi breadcrumb log (dấu vết hoạt động của user trước khi crash)
  /// Ví dụ: "User opened HomeScreen", "User tapped Login button"
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      // Ignore
    }
  }
}
