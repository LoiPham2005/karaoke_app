// ════════════════════════════════════════════════════════════════
// 📁 lib/config/app_startup.dart
// ════════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/base/di/injection.dart';
import '../../core/common/utils/logger.dart';
import '../../core/data/network/network_info.dart';
import '../../core/data/storage/local/local_storage_service.dart';
import '../../core/services/app_version/app_version_service.dart';
import '../../core/services/network/network_monitor.dart';

/// AppStartup: xử lý logic sau khi AppInitializer xong
/// Chạy từ SplashScreen sau khi widget tree đã sẵn sàng
class AppStartup {
  static Future<bool> launch(BuildContext context) async {
    try {
      final networkInfo = getIt<NetworkInfo>();
      final hasInternet = await networkInfo.isConnected;

      if (!hasInternet) {
        Logger.warning('Không có kết nối internet. Đang chờ kết nối lại...', tag: 'STARTUP');

        // Dùng Completer để THỰC SỰ chờ cho đến khi có kết nối
        final completer = Completer<void>();
        await NetworkMonitor().startMonitoring(
          showBanner: true,
          onConnected: () async {
            if (!completer.isCompleted) {
              Logger.info('Đã có kết nối internet. Tiếp tục...', tag: 'STARTUP');
              completer.complete();
              NetworkMonitor().stopMonitoring();
            }
          },
        );

        // Chờ thực sự cho đến khi có kết nối
        await completer.future;
      }

      return await _continue(context);
    } catch (e, s) {
      Logger.error('Lỗi startup', error: e, stackTrace: s, tag: 'STARTUP');
      // Tiếp tục dù lỗi - trả về isFirstRun từ storage
      return await _continue(context);
    }
  }

  static Future<bool> _continue(BuildContext context) async {
    final storageService = getIt<LocalStorageService>();
    final appVersionService = getIt<AppVersionService>();

    // Kiểm tra cập nhật version (non-blocking)
    await appVersionService.checkForUpdate(context);

    // Kiểm tra firstRun
    final firstRun = storageService.isFirstRun();
    if (firstRun) await storageService.setFirstRun(false);

    return firstRun;
  }
}
