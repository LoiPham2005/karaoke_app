// ════════════════════════════════════════════════════════════════
// 📁 3. App Router (Main Router Config)
// ════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_base/core/base/di/global_providers.dart';
import 'package:flutter_base/core/services/app_auth/providers/app_auth_notifier.dart';
import 'package:flutter_base/core/services/utils/navigation_service.dart';
import 'package:flutter_base/modules/analytics/analytics_service.dart';
import 'package:flutter_base/routes/base/app_routes_observer.dart';
import 'package:flutter_base/routes/base/go_router_refresh_stream.dart';
import 'package:flutter_base/routes/config/app_routes.dart';
import 'package:flutter_base/routes/config/route_guards.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:flutter_base/routes/base/not_found_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AppRouter {
  final RouteGuards routeGuards;
  final NavigationService navigationService;
  final AppRoutesObserver appRoutesObserver;
  final AnalyticsService analyticsService;

  AppRouter(
    this.routeGuards,
    this.navigationService,
    this.appRoutesObserver,
    this.analyticsService,
  );

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    navigatorKey: navigationService.navigatorKey,
    debugLogDiagnostics: kDebugMode,
    restorationScopeId: 'app_router',

    // Auto-refresh when auth state changes
    refreshListenable: GoRouterRefreshStream(_authStream(globalContainer)),

    // Global redirect (auth guard)
    redirect: routeGuards.authGuard,

    observers: [
      appRoutesObserver,
      analyticsService.observer,
      FlutterSmartDialog.observer,
    ],

    routes: [
      ...$appRoutes,
    ],

    errorBuilder: (context, state) => NotFoundPage(error: state.error),
  );
}

Stream<void> _authStream(ProviderContainer container) {
  final ctrl = StreamController<void>.broadcast();
  // container.listen(appAuthProvider, (_, _) => ctrl.add(null));
  return ctrl.stream;
}
