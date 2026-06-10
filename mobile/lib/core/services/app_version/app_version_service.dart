// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/app_version/app_version_service.dart
// ════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/core/common/constants/app_constants.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/app_update_dialog.dart';

/// 🎯 App Version Service - Logic & Version Management
@LazySingleton()
class AppVersionService {
  static const String _tag = 'VERSION';

  PackageInfo? _cachedPackageInfo;
  FirebaseRemoteConfig? _remoteConfig;

  /// 📦 Lấy thông tin package (cached)
  Future<PackageInfo> getAppInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// 🔄 Initialize Remote Config với defaults
  Future<FirebaseRemoteConfig> _getRemoteConfig() async {
    if (_remoteConfig != null) return _remoteConfig!;

    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig!.setDefaults({
      AppConstants.latestVersionKey: '',
      AppConstants.forceUpdateVersionKey: '',
      AppConstants.updateMessageKey: '',
      AppConstants.updateUrlKey: '',
    });

    await _remoteConfig!.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    return _remoteConfig!;
  }

  /// ✅ Kiểm tra update (Main method)
  Future<void> checkForUpdate(
    BuildContext context, {
    bool showNoUpdateDialog = false,
    bool showLoadingDialog = true,
  }) async {
    BuildContext? dialogContext;

    try {
      if (showLoadingDialog && context.mounted) {
        Logger.info('🔄 Showing loading dialog (non-blocking)', tag: _tag);
        // ⚠️ KHÔNG await — loading dialog cần hiện ngay để code tiếp tục
        // fetch config. Sau khi fetch xong, Navigator.pop(dialogContext) đóng nó.
        // AWAIT sẽ DEADLOCK: dialog chờ pop, pop chờ code thoát await.
        unawaited(
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              dialogContext = ctx;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      }

      Logger.info('📡 Fetching remote config...', tag: _tag);

      final remoteConfig = await _getRemoteConfig();
      await remoteConfig.fetchAndActivate();

      final currentInfo = await getAppInfo();
      final currentVersion = currentInfo.version;
      final latestVersion = remoteConfig.getString(
        AppConstants.latestVersionKey,
      );
      final forceUpdateVersion = remoteConfig.getString(
        AppConstants.forceUpdateVersionKey,
      );
      final updateMessage = remoteConfig.getString(
        AppConstants.updateMessageKey,
      );
      final customUpdateUrl = remoteConfig.getString(AppConstants.updateUrlKey);

      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      if (latestVersion.isEmpty) {
        Logger.warning(
          'Latest version not configured in Remote Config',
          tag: _tag,
        );
        if (showNoUpdateDialog && context.mounted) {
          _showSimpleDialog(
            context,
            'Đã cập nhật',
            'Bạn đang sử dụng phiên bản mới nhất!',
            icon: Icons.check_circle,
            iconColor: Colors.green,
          );
        }
        return;
      }

      final isForceUpdate = _shouldUpdate(currentVersion, forceUpdateVersion);
      final isOptionalUpdate =
          !isForceUpdate && _shouldUpdate(currentVersion, latestVersion);

      Logger.info(
        'Version check: Current=$currentVersion, Latest=$latestVersion, Force=$forceUpdateVersion',
        tag: _tag,
      );

      if ((isForceUpdate || isOptionalUpdate) && context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: !isForceUpdate,
          builder: (context) => AppUpdateDialog(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            isMandatory: isForceUpdate,
            message: updateMessage.isNotEmpty ? updateMessage : null,
            customUrl: customUpdateUrl.isNotEmpty ? customUpdateUrl : null,
            onUpdate: () =>
                _openStore(customUpdateUrl.isNotEmpty ? customUpdateUrl : null),
            onExit: () => _exitApp(),
          ),
        );
      } else if (showNoUpdateDialog && context.mounted) {
        _showSimpleDialog(
          context,
          'Đã cập nhật',
          'Bạn đang sử dụng phiên bản mới nhất!',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        );
      }
    } catch (e, stack) {
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }

      Logger.error(
        'Failed to check for updates',
        error: e,
        stackTrace: stack,
        tag: _tag,
      );

      if (context.mounted) {
        _showSimpleDialog(
          context,
          'Thông báo',
          'Không thể kiểm tra phiên bản mới.\nVui lòng thử lại sau.',
          icon: Icons.error_outline,
          iconColor: Colors.orange,
        );
      }
    }
  }

  bool _shouldUpdate(String current, String target) {
    if (target.isEmpty) return false;
    try {
      final currentVersion = _parseVersion(current);
      final targetVersion = _parseVersion(target);
      for (int i = 0; i < 3; i++) {
        final curr = i < currentVersion.length ? currentVersion[i] : 0;
        final targ = i < targetVersion.length ? targetVersion[i] : 0;
        if (targ > curr) return true;
        if (targ < curr) return false;
      }
      return false;
    } catch (e) {
      Logger.error('Version comparison failed', error: e, tag: _tag);
      return false;
    }
  }

  List<int> _parseVersion(String version) {
    final cleanVersion = version.split('+').first.split('-').first;
    return cleanVersion
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();
  }

  void _showSimpleDialog(
    BuildContext context,
    String title,
    String content, {
    IconData? icon,
    Color? iconColor,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
            ],
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _openStore(String? customUrl) async {
    try {
      final url = customUrl ?? await _getStoreUrl();
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Logger.error('Failed to open store', error: e, tag: _tag);
    }
  }

  Future<String> _getStoreUrl() async {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=${AppConstants.androidPackageName}';
    }
    if (Platform.isIOS) {
      return 'https://apps.apple.com/app/id${AppConstants.appStoreId}';
    }
    throw UnsupportedError('Platform not supported');
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS)
      // ignore: curly_braces_in_flow_control_structures
      exit(0);
  }
}
