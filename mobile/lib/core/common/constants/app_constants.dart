// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────
  static const String androidPackageName = 'com.example.dat_san_247_mobile';
  static const String iosBundleId = 'com.example.dat_san_247_mobile';
  static const String appStoreId = '123456789';
  static const String appName = 'Đặt Sân 247';
  static const String appNameDev = 'Đặt Sân 247 (Dev)';
  static const String appNameStg = 'Đặt Sân 247 (Stg)';
  static const String appVersion = '1.0.0';

  // ── Pagination ────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── Cache ─────────────────────────────────────────────────────
  static const Duration cacheExpiration = Duration(hours: 24);

  // ── Animation ─────────────────────────────────────────────────
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // ── Retry ─────────────────────────────────────────────────────
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const List<int> retryStatusCodes = [408, 500, 502, 503, 504];

  // ── Remote Config Keys ────────────────────────────────────────
  static const String adConfigKey = 'ad_config';
  static const String latestVersionKey = 'latest_version';
  static const String forceUpdateVersionKey = 'force_update_version';
  static const String updateUrlKey = 'update_url';
  static const String updateMessageKey = 'update_message';

  // ── IAP (RevenueCat) ──────────────────────────────────────────
  static const String revenueCatAppleKey = 'appl_api_key_placeholder';
  static const String revenueCatGoogleKey = 'goog_api_key_placeholder';
  static const String premiumEntitlement = 'premium_access';
}
