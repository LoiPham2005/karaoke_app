import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:karaoke/config/app/flavor_config.dart';
import 'package:karaoke/config/ui/system_ui_manager.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/services/app_version/app_version_service.dart';
import 'package:karaoke/core/services/fcm/fcm_service.dart';
import 'package:karaoke/core/services/notification/notification_service.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:karaoke/modules/ads/observers/ad_lifecycle_observer.dart';
import 'package:karaoke/modules/ads/services/ad_config_service.dart';
import 'package:karaoke/modules/ads/services/ad_consent_service.dart';
import 'package:karaoke/modules/ads/services/ad_manager.dart';
import 'package:karaoke/modules/iap/iap_service.dart';

abstract class AppInitializer {
  static Future<void> initialize() async {
    Logger.info('🚀 Initializing app (${FlavorConfig.current.flavor.name})...');

    await initializeDateFormatting('vi_VN');
    await _initFirebase();
    await _initLocalNotification();
    await _initFcm();
    await SystemUIManager.setup();
    await configureDependencies(environment: FlavorConfig.current.flavor.name);

    // Modules — mỗi module tự catch để không block app boot.
    await _initIap();
    await _initAds();
    await _initAppVersion();
    // QuickActions — gọi từ Splash/App sau khi router build xong (cần BuildContext).

    Logger.info('✅ App initialized.');
  }

  /// Khởi tạo AppVersionService — fetch Remote Config keys cho update flow.
  /// Service được dùng manually trong Splash hoặc Settings page qua
  /// `getIt<AppVersionService>().checkForUpdate(...)`.
  static Future<void> _initAppVersion() async {
    try {
      await getIt<AppVersionService>().initialize();
    } catch (e, s) {
      Logger.error('AppVersion init failed', error: e, stackTrace: s);
    }
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
      if (FlavorConfig.instance.enableCrashlytics) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          !kDebugMode,
        );
      }
    } catch (e, s) {
      Logger.error('Firebase init failed', error: e, stackTrace: s);
    }
  }

  static Future<void> _initLocalNotification() async {
    Logger.info('🔧 Init Local Notification...');
    try {
      await getIt<NotificationService>().initialize();
      Logger.info('✅ Local Notification ready');
    } catch (e, st) {
      Logger.error(
        '❌ Local Notification init failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> _initFcm() async {
    Logger.info('🔧 Init FCM...');
    try {
      await getIt<FcmService>().init();
      Logger.info('✅ FCM ready');
    } catch (e, st) {
      Logger.error('❌ FCM init failed', error: e, stackTrace: st);
    }
  }

  /// Khởi tạo IAP (RevenueCat ở prod/stg, mock ở dev).
  static Future<void> _initIap() async {
    try {
      await getIt<IapService>().initialize();
    } catch (e, s) {
      Logger.error('IAP init failed', error: e, stackTrace: s);
    }
  }

  /// Khởi tạo Ads — flow BẮT BUỘC theo Google policy:
  ///
  ///   1. AdConfigService  ── fetch Remote Config (placement IDs, rules)
  ///   2. AdConsentService ── ATT (iOS) + UMP (GDPR/CCPA) — TRƯỚC MobileAds.init
  ///   3. AdManager        ── MobileAds.initialize + preload placements
  ///   4. Lifecycle observer ── AppOpen on resume
  ///
  /// Mỗi bước catch riêng — fail bước này không block bước sau.
  static Future<void> _initAds() async {
    try {
      await getIt<AdConfigService>().initialize();
    } catch (e, s) {
      Logger.error('AdConfig init failed', error: e, stackTrace: s);
    }

    // ⚡ Consent PHẢI chạy trước MobileAds.initialize. Timeout 8s để
    // không block app boot quá lâu nếu UMP server chậm — ads vẫn load
    // được, chỉ là non-personalized cho user EU/UK.
    try {
      await getIt<AdConsentService>().ensureConsent().timeout(
        const Duration(seconds: 8),
        onTimeout: () => Logger.warning(
          'Consent flow timed out — proceeding with non-personalized ads',
          tag: 'ADS',
        ),
      );
    } catch (e, s) {
      Logger.error('AdConsent init failed', error: e, stackTrace: s);
    }

    try {
      await getIt<AdManager>().initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () => Logger.warning('MobileAds init timed out', tag: 'ADS'),
      );
    } catch (e, s) {
      Logger.error('AdManager init failed', error: e, stackTrace: s);
    }

    try {
      getIt<AdLifecycleObserver>().init();
    } catch (e, s) {
      Logger.error('AdLifecycleObserver init failed', error: e, stackTrace: s);
    }
  }
}
