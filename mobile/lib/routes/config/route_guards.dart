import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base/core/base/di/global_providers.dart';
import 'package:flutter_base/core/services/app_auth/providers/app_auth_notifier.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

/// Auth Route Guard.
/// - Unauthenticated + protected page → redirect login
/// - Authenticated + auth page → redirect main
@LazySingleton()
class RouteGuards {
  RouteGuards();

  static const _publicRoutes = {
    RouteNames.splash,
  
    RouteNames.login,
    RouteNames.register,

    RouteNames.premium,
    RouteNames.main,
    RouteNames.settings,
    RouteNames.home,

    RouteNames.appConfigDebug,
  };

  static const _authOnlyRoutes = {RouteNames.login, RouteNames.register,};

  FutureOr<String?> authGuard(BuildContext context, GoRouterState state) {
    // final isLoggedIn = globalContainer.read(appAuthProvider).value?.isAuthenticated ?? false;
    // final location = state.matchedLocation;

    // if (!isLoggedIn && !_publicRoutes.contains(location)) return RouteNames.login;
    // if (isLoggedIn && _authOnlyRoutes.contains(location)) return RouteNames.main;
    // return null;
  }
}
