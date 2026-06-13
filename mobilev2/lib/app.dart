import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/di/global_providers.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/common/constants/app_constants.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/core/services/quick_actions/quick_actions_handler.dart';
import 'package:karaoke/design/l10n/providers/locale_notifier.dart';
import 'package:karaoke/design/theme/app_theme.dart';
import 'package:karaoke/design/theme/providers/theme_notifier.dart';
import 'package:karaoke/gen/l10n/app_localizations.dart';
import 'package:karaoke/routes/base/route_logger.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: globalContainer,
      child: ScreenUtilInit(
        designSize: const Size(AppConstants.designWidth, AppConstants.designHeight),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => const _AppContent(),
      ),
    );
  }
}

class _AppContent extends ConsumerStatefulWidget {
  const _AppContent();

  @override
  ConsumerState<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends ConsumerState<_AppContent> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = getIt<AppRouter>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QuickActionsHandler.init(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    // Khi auth state đổi sang unauthenticated → điều hướng về Login
    ref.listen<AppAuthState>(appAuthProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        _router.replaceAll([const LoginRoute()]);
      }
      if (previous?.isAuthenticated != next.isAuthenticated) {
        QuickActionsHandler.updateActions(next.isAuthenticated);
      }
    });

    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.light(themeState),
        darkTheme: AppTheme.dark(themeState),
        themeMode: themeState.materialThemeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router.config(
          navigatorObservers: () => [RouteLogger()],
        ),
        builder: FlutterSmartDialog.init(),
      ),
    );
  }
}
