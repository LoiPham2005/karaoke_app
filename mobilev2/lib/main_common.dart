import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karaoke/app.dart';
import 'package:karaoke/config/app/app_initializer.dart';
import 'package:karaoke/config/app/flavor_config.dart';
import 'package:karaoke/config/observers/app_riverpod_observer.dart';
import 'package:karaoke/core/base/di/global_providers.dart';
import 'package:karaoke/core/services/utils/logger.dart';

Future<void> mainCommon(AppFlavor flavor) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlavorConfig.setFlavor(flavor);

      globalContainer = ProviderContainer(
        observers: [const AppRiverpodObserver()],
      );

      await AppInitializer.initialize();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (FlavorConfig.instance.enableCrashlytics && !kDebugMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        Logger.error('Platform error', error: error, stackTrace: stack);
        if (FlavorConfig.instance.enableCrashlytics && !kDebugMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      runApp(const App());
    },
    (error, stack) {
      Logger.error('Zoned error', error: error, stackTrace: stack);
      if (FlavorConfig.instance.enableCrashlytics && !kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    },
  );
}
