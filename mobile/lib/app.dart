import 'package:flutter/material.dart';
import 'package:flutter_base/core/common/constants/app_constants.dart';
import 'package:flutter_base/core/base/di/global_providers.dart';
import 'package:flutter_base/core/base/di/injection.dart';
import 'package:flutter_base/design/l10n/providers/locale_notifier.dart';
import 'package:flutter_base/design/theme/app_theme.dart';
import 'package:flutter_base/design/theme/providers/theme_notifier.dart';
import 'package:flutter_base/gen/l10n/app_localizations.dart';
import 'package:flutter_base/routes/config/app_router.dart';
import 'package:flutter_base/core/common/utils/error_utils.dart';
import 'package:flutter_base/core/common/widgets/app_error_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:toastification/toastification.dart';

/// 🏠 Root Widget của ứng dụng
///
/// File này đặt ở `lib/app.dart` vì:
/// - App là root, không phải feature
/// - Dễ tìm, dễ maintain
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng UncontrolledProviderScope để chia sẻ globalContainer với widget tree.
    // Mọi ref.watch/read trong widget đều trỏ về cùng một container này.
    return UncontrolledProviderScope(
      container: globalContainer,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => _AppContent(),
      ),
    );
  }
}

/// 🎨 Nội dung chính của App (tách ra để code gọn hơn)
class _AppContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      // App Info
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light(themeState),
      darkTheme: AppTheme.dark(themeState),
      themeMode: themeState.materialThemeMode,

      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Navigation
      routerConfig: getIt<AppRouter>().router,
      builder: (context, child) {
        ErrorWidget.builder = (details) {
          final location = ErrorUtils.extractLocation(details);
          return AppErrorScreen(details: details, location: location);
        };
        // Wrap thứ tự: Toastification (ngoài cùng) → SmartDialog → app.
        // Cả 2 đều cần 1 widget wrapper riêng để hiển thị overlay.
        return ToastificationWrapper(
          child: FlutterSmartDialog.init()(context, child),
        );
      },
    );
  }
}
