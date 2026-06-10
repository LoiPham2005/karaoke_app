import '../models/app_config.dart';

/// BẬT/TẮT lấy cấu hình app từ Firebase Remote Config.
const kUseAppRemoteConfig = true;

/// Fallback khi parse Remote Config fail — tắt hết feature flags.
const kAppConfigDisabled = AppConfig();

/// Cấu hình dev — bật announcement để test UI.
const kAppConfigDev = AppConfig(
  latestVersion: '1.2.0',
  minVersion: '2.0.0',
  storeUrl: '',
  noticeEnabled: true,
  noticeTitle: '[DEV] Thông báo test',
  noticeBody: 'Đây là thông báo test trong môi trường development.',
  noticeUrl: '',
  maintenance: false,
  maintenanceMessage: '',
);
