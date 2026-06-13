// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/app_version/app_version_service.dart
// ════════════════════════════════════════════════════════════════
//
// Force / optional update — nguồn dữ liệu: BACKEND REST API.
//
// Admin quản lý version per-platform ở trang web admin; backend tính quyết định
// (`up_to_date` | `optional` | `force`); mobile gọi `GET /app-version/check`
// ở splash rồi show dialog force/optional.
//
// KIẾN TRÚC: service là LOGIC THUẦN — trả [UpdateStatus] + snapshot [VersionInfo],
// KHÔNG giữ BuildContext, KHÔNG show dialog. Caller (SplashPage) tự orchestrate
// + show [UpdateDialog]. Dễ test, đúng layer.
//
//   final v = getIt<AppVersionService>();
//   final status = await v.checkForUpdate();
//   // switch(status) → UpdateDialog.showForce/showOptional(onUpdate: v.openStore)

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/services/app_version/data/app_version_api.dart';
import 'package:karaoke/core/services/app_version/data/app_version_check_response.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Kết quả check update.
enum UpdateStatus {
  /// Đang ở version mới nhất (hoặc cao hơn).
  upToDate,

  /// Có version mới — tuỳ chọn, bỏ qua được.
  optional,

  /// Bắt buộc update — backend trả status `force`.
  force,

  /// Không check được (network/parse lỗi, status lạ) — KHÔNG chặn user (fail-open).
  error,
}

/// Snapshot info lần check gần nhất — cho [UpdateDialog] đọc.
class VersionInfo {
  const VersionInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.message,
    required this.storeUrl,
  });

  final String currentVersion;
  final String latestVersion;
  final String message;
  final String storeUrl;
}

@LazySingleton()
class AppVersionService {
  AppVersionService(this._api);

  static const _tag = 'APP-VERSION';

  final AppVersionApi _api;

  PackageInfo? _pkg;

  VersionInfo? _last;
  VersionInfo? get last => _last;

  /// Gọi 1 lần ở AppInitializer. Chỉ preload PackageInfo (không còn Remote
  /// Config). Best-effort — nuốt lỗi để không block app.
  Future<void> initialize() async {
    try {
      _pkg = await PackageInfo.fromPlatform();
    } catch (e, s) {
      Logger.error(
        'AppVersion init failed',
        error: e,
        stackTrace: s,
        tag: _tag,
      );
    }
  }

  /// Gọi backend `/app-version/check` → [UpdateStatus].
  /// Bất kỳ exception / status lạ nào → [UpdateStatus.error] (fail-open).
  Future<UpdateStatus> checkForUpdate() async {
    try {
      final pkg = _pkg ??= await PackageInfo.fromPlatform();
      final current = pkg.version;
      final build = pkg.buildNumber;
      final packageName = pkg.packageName;
      final platform = Platform.isAndroid ? 'android' : 'ios';

      final res = await _api.checkVersion(platform, current, build);

      final status = _mapStatus(res.status);
      if (status == UpdateStatus.error) {
        Logger.warning('Unknown status "${res.status}" → error', tag: _tag);
        return UpdateStatus.error;
      }

      _last = VersionInfo(
        currentVersion: res.currentVersion.isEmpty
            ? current
            : res.currentVersion,
        latestVersion: res.latestVersion,
        message: res.message ?? '',
        storeUrl: _resolveStoreUrl(res, packageName),
      );
      Logger.info(
        'platform=$platform | current=$current | status=${res.status} '
        '| latest=${res.latestVersion}',
        tag: _tag,
      );
      return status;
    } catch (e, s) {
      Logger.error('checkForUpdate failed', error: e, stackTrace: s, tag: _tag);
      return UpdateStatus.error;
    }
  }

  /// Mở store để update. Gọi từ UpdateDialog (onUpdate). Guard URL rỗng.
  Future<void> openStore() async {
    final url = _last?.storeUrl ?? '';
    if (url.isEmpty) {
      Logger.warning('storeUrl rỗng — không mở được store', tag: _tag);
      return;
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e, s) {
      Logger.error('openStore failed', error: e, stackTrace: s, tag: _tag);
    }
  }

  /// Map status string của backend → [UpdateStatus].
  /// `up_to_date`/`optional`/`force` → tương ứng; còn lại → `error` (fail-open).
  static UpdateStatus _mapStatus(String status) {
    switch (status) {
      case 'up_to_date':
        return UpdateStatus.upToDate;
      case 'optional':
        return UpdateStatus.optional;
      case 'force':
        return UpdateStatus.force;
      default:
        return UpdateStatus.error;
    }
  }

  /// URL store: ưu tiên `storeUrl` từ backend; fallback Android tự build từ
  /// packageName. iOS không có fallback → trả rỗng (cần admin set storeUrl).
  static String _resolveStoreUrl(
    AppVersionCheckResponse res,
    String packageName,
  ) {
    final remote = res.storeUrl ?? '';
    if (remote.isNotEmpty) return remote;
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=$packageName';
    }
    return '';
  }
}

/// @module cung cấp [AppVersionApi] cho DI để dựng [AppVersionService].
@module
abstract class AppVersionModule {
  @lazySingleton
  AppVersionApi appVersionApi(Dio dio) => AppVersionApi(dio);
}
