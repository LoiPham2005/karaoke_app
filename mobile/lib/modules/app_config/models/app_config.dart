import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

/// Cấu hình app — fetch từ Web Admin API khi khởi động.
///
/// JSON response (GET /api/app/config):
/// ```json
/// {
///   "latest_version": "2.1.0",
///   "min_version": "1.5.0",
///   "store_url": "https://play.google.com/store/apps/details?id=com.example.app",
///   "notice_enabled": true,
///   "notice_title": "Tính năng mới",
///   "notice_body": "Chúng tôi vừa ra mắt tính năng X!",
///   "notice_url": "app://feature_x",
///   "maintenance": false,
///   "maintenance_message": "Hệ thống đang bảo trì, vui lòng quay lại sau.",
///   "policy_url": "https://example.com/privacy",
///   "terms_url": "https://example.com/terms"
/// }
/// ```
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    // ── Update ────────────────────────────────────────────────
    @Default('') String latestVersion,
    @Default('') String minVersion,
    @Default('') String storeUrl,

    // ── Notice (announcement / promotion) ────────────────────
    @Default(false) bool noticeEnabled,
    @Default('') String noticeTitle,
    @Default('') String noticeBody,
    @Default('') String noticeUrl,

    // ── Maintenance ───────────────────────────────────────────
    @Default(false) bool maintenance,
    @Default('') String maintenanceMessage,

    // ── Legal ─────────────────────────────────────────────────
    @Default('') String policyUrl,
    @Default('') String termsUrl,
  }) = _AppConfig;

  const AppConfig._();

  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);
}

extension AppConfigX on AppConfig {
  /// App hiện tại cần force update (version thấp hơn min hỗ trợ).
  bool needsForceUpdate(String currentVersion) {
    if (minVersion.isEmpty) return false;
    return _compareVersion(currentVersion, minVersion) < 0;
  }

  /// Có bản mới nhưng không bắt buộc.
  bool hasSoftUpdate(String currentVersion) {
    if (latestVersion.isEmpty) return false;
    return _compareVersion(currentVersion, latestVersion) < 0;
  }

  bool get hasAnnouncement => noticeEnabled && noticeTitle.isNotEmpty;

  bool get hasAnnouncementAction => noticeUrl.isNotEmpty;

  /// So sánh semantic version "1.2.3". Trả về âm nếu a < b.
  int _compareVersion(String a, String b) {
    final partsA = a.split('.').map(int.tryParse).toList();
    final partsB = b.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final diff = (partsA.elementAtOrNull(i) ?? 0) - (partsB.elementAtOrNull(i) ?? 0);
      if (diff != 0) return diff;
    }
    return 0;
  }
}
