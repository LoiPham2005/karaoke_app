// ════════════════════════════════════════════════════════════════
// 📁 lib/core/config/app_initializer.dart (OPTIMIZED)
// ════════════════════════════════════════════════════════════════
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_base/modules/app_config/services/app_config_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_base/config/app/flavor_config.dart';
import 'package:flutter_base/config/observers/app_bloc_observer.dart';
import 'package:flutter_base/config/observers/app_observer.dart';
import 'package:flutter_base/config/observers/app_riverpod_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base/config/ui/system_ui_manager.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/core/common/utils/logger_config.dart';
import 'package:flutter_base/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_base/core/services/notification/notification_service.dart';
import 'package:flutter_base/modules/ads/services/ad_config_service.dart';
import 'package:flutter_base/modules/ads/services/ad_manager.dart';
import 'package:flutter_base/modules/ads/observers/ad_lifecycle_observer.dart';
import 'package:flutter_base/modules/iap/iap_service.dart';
import 'package:flutter_base/core/services/quick_actions/quick_actions_service.dart';
import 'package:flutter_base/core/services/app_auth/providers/app_auth_notifier.dart';
import 'package:flutter_base/core/base/di/global_providers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/base/di/injection.dart';
import '../../core/data/cache/cache_service.dart';

/// 🎯 Quản lý toàn bộ quá trình khởi tạo app
class AppInitializer {
  AppInitializer._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // ✅ Ads lifecycle observer
  static AdLifecycleObserver? _adLifecycleObserver;

  /// ✅ Entry point: Khởi tạo app
  static Future<void> initialize() async {
    if (_isInitialized) {
      Logger.warning('App already initialized, skipping...', tag: 'INIT');
      return;
    }

    try {
      final stopwatch = Stopwatch()..start();

      // ─────────────────────────────────────────────────────────────
      // Phase 0: Firebase + Crashlytics (phải là bước đầu tiên)
      // ─────────────────────────────────────────────────────────────
      await Firebase.initializeApp();
      await CrashlyticsService.instance.initialize();
      Logger.success('Firebase & Crashlytics initialized', tag: 'INIT');

      // Phase 1: Config & Setup
      FlavorConfig.printInfo();
      LoggerConfig.configure();
      await initializeDateFormatting('vi_VN', null);
      await SystemUIManager.instance.initialize();
      Logger.success('SystemUIManager initialized', tag: 'INIT');
      AppObserver().initialize();
      _configureBlocObserver();

      // Phase 2: DI (phải trước Ads & Services)
      await configureDependencies(environment: FlavorConfig.flavor.name);
      // await configureDependencies();

      // Phase 4: Remote Configs (Ads & App)
      final adConfigService = getIt<AdConfigService>();
      await adConfigService.initialize();

      final appConfig = getIt<AppConfigService>();
      await appConfig.initialize();
      Logger.success('AppConfig (Firebase Remote Config) initialized', tag: 'INIT');

      final adManager = getIt<AdManager>();
      await adManager.initialize();

      _adLifecycleObserver = getIt<AdLifecycleObserver>();
      _adLifecycleObserver!.init();
      Logger.success('Ads (AdManager & AdLifecycleObserver) initialized', tag: 'INIT');

      await _initializeCacheManager();
      await _initializeServices();
      await _initializeQuickActions();

      stopwatch.stop();
      _isInitialized = true;

      Logger.success('App initialized in ${stopwatch.elapsedMilliseconds}ms', tag: 'INIT');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize app', error: e, stackTrace: stackTrace, tag: 'INIT');
      // _isInitialized đã là false — không cần reset
      await _handleInitializationError();
      rethrow;
    }
  }

  /// 🧹 Xử lý cleanup khi initialization fail
  static Future<void> _handleInitializationError() async {
    try {
      AppObserver().dispose();
      SystemUIManager.instance.dispose(); // ✅ Cleanup SystemUIManager
      _adLifecycleObserver?.dispose(); // ✅ Cleanup observer
      _adLifecycleObserver = null;
      await resetDependencies();
      _isInitialized = false;
      Logger.warning('Cleaned up after init failure', tag: 'INIT');
    } catch (e) {
      Logger.error('Cleanup error', error: e, tag: 'INIT');
    }
  }

  /// Danh sách Riverpod observers — truyền vào ProviderContainer trước runApp.
  /// Phải gọi trước initialize() vì container cần tạo trước DI.
  static List<ProviderObserver> get riverpodObservers => [
    if (!FlavorConfig.isProd) AppRiverpodObserver(),
  ];

  /// 🔍 Setup BLoC observer (chỉ cho Dev/Staging)
  static void _configureBlocObserver() {
    if (!FlavorConfig.isProd) {
      Bloc.observer = AppBlocObserver();
    }
  }

  /// ⚙️ Khởi tạo services (theme, localization)
  static Future<void> _initializeServices() async {
    try {
      await Future.wait([
        getIt<NotificationService>().initialize(),
      ]);

      // Init IAP separately to not block UI if it fails
      try {
        await getIt<IapService>().initialize();
      } catch (e) {
        Logger.error('IAP Init failed (contfinuing app)', error: e, tag: 'INIT');
      }

      Logger.success('Services initialized', tag: 'INIT');
    } catch (e, stackTrace) {
      Logger.error('Failed to init services', error: e, stackTrace: stackTrace, tag: 'INIT');
      rethrow;
    }
  }

  /// ⚡ Init Quick Actions (long-press app icon shortcuts)
  /// + Listen auth state để đổi shortcut theo trạng thái login.
  static Future<void> _initializeQuickActions() async {
    try {
      final service = getIt<AppQuickActionsService>();
      await service.initialize();

      // Set shortcut theo trạng thái auth hiện tại
      // final authState = await globalContainer.read(appAuthProvider.future);
      // if (authState.isAuthenticated) {
      //   await service.setForAuthenticated();
      // } else {
      //   await service.setForUnauthenticated();
      // }

      // // Lắng nghe auth state đổi → cập nhật shortcut
      // globalContainer.listen<AsyncValue>(appAuthProvider, (prev, next) {
      //   final data = next.asData?.value;
      //   if (data == null) return;
      //   if (data.isAuthenticated) {
      //     service.setForAuthenticated();
      //   } else if (data.isUnauthenticated) {
      //     service.setForUnauthenticated();
      //   }
      // });

      Logger.success('QuickActions initialized', tag: 'INIT');
    } catch (e, st) {
      Logger.error('QuickActions init failed (continuing)', error: e, stackTrace: st, tag: 'INIT');
    }
  }

  /// ✅ NEW: Initialize file caches
  static Future<void> _initializeCacheManager() async {
    try {
      final cacheManager = getIt<CacheService>();
      await cacheManager.initialize();
      Logger.success('CacheService initialized', tag: 'INIT');
    } catch (e, stackTrace) {
      Logger.error('Failed to init CacheService', error: e, stackTrace: stackTrace, tag: 'INIT');
      rethrow;
    }
  }
}
