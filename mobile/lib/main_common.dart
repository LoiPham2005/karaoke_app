import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/app.dart';
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/core/base/di/global_providers.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/core/common/utils/error_utils.dart';
import 'package:flutter_base/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app/app_initializer.dart';

void mainCommon(AppFlavor flavor) {
  // Bắt lỗi Async (Dart Zone)
  runZonedGuarded(
    () async {
      // ✅ Đảm bảo Binding được khởi tạo TRONG Zone này để tránh lỗi "Zone mismatch"
      WidgetsFlutterBinding.ensureInitialized();

      // ⚠️ setFlavor PHẢI gọi trước khi đọc AppInitializer.riverpodObservers
      // (observers list dùng FlavorConfig.isProd để quyết định bật).
      FlavorConfig.setFlavor(flavor);

      // Khởi tạo globalContainer trước runApp để có thể dùng ngoài widget tree
      // (AppRouter, DioClient interceptor, push notification handler...)
      globalContainer = ProviderContainer(
        observers: AppInitializer.riverpodObservers,
      );

      await AppInitializer.initialize();

      // ─────────────────────────────────────────────────────────────
      // ✅ BẮT LỖI FLUTTER FRAMEWORK (UI thread errors)
      // Ví dụ: lỗi trong build(), initState(), setState()...
      // Đặt SAU initialize() để Crashlytics đã được khởi tạo
      // ─────────────────────────────────────────────────────────────
      FlutterError.onError = (details) {
        final location = ErrorUtils.extractLocation(details);
        Logger.error(
          'Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
          location: location,
        );
        // recordFlutterFatalError = đánh dấu là Fatal crash
        CrashlyticsService.instance.recordFlutterError(details);
      };

      // ─────────────────────────────────────────────────────────────
      // ✅ BẮT LỖI PLATFORM / NATIVE ISOLATE
      // Ví dụ: lỗi plugin, platform channel errors
      // ─────────────────────────────────────────────────────────────
      PlatformDispatcher.instance.onError = (error, stack) {
        Logger.error('Platform error', error: error, stackTrace: stack);
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(const App());
    },
    // ─────────────────────────────────────────────────────────────
    // ✅ BẮT LỖI ASYNC ZONE (không được catch bởi try-catch thông thường)
    // Ví dụ: Future bị lỗi không await, stream không lắng nghe error
    // ─────────────────────────────────────────────────────────────
    (error, stack) {
      Logger.error('Uncaught async error', error: error, stackTrace: stack);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

