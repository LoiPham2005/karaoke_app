// ════════════════════════════════════════════════════════════════
// 📁 lib/extensions/context_extensions.dart (SỬ DỤNG CHÍNH)
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_base/core/services/utils/toast_service.dart';
import 'package:flutter_base/routes/config/app_router.dart';

import '../../base/di/injection.dart';

/// 🌍 Global BuildContext - CHỈ DÙNG KHI KHÔNG CÓ CONTEXT
BuildContext get appContext {
  final ctx =
      getIt<AppRouter>().router.routerDelegate.navigatorKey.currentContext;
  assert(ctx != null, '⛔ appContext is null!');
  return ctx!;
}

BuildContext? get appContextOrNull =>
    getIt<AppRouter>().router.routerDelegate.navigatorKey.currentContext;

extension ContextExtensions on BuildContext {
  // ═══════════════════════════════════════════════════════════════
  // 🎨 THEME ACCESS
  // ═══════════════════════════════════════════════════════════════

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION (⭐ SỬ DỤNG CHÍNH - 95% cases)
  // ═══════════════════════════════════════════════════════════════

  NavigatorState get nav => Navigator.of(this);

  /// Push widget page with MaterialPageRoute
  /// Example: context.navPush(DetailsPage())
  Future<T?> navPush<T>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Push with custom route
  /// Example: context.navPushRoute(customRoute)
  Future<T?> navPushRoute<T>(Route<T> route) {
    return Navigator.of(this).push<T>(route);
  }

  /// Push and replace current
  /// Example: context.navReplace(HomePage())
  Future<T?> navReplace<T, TO>(Widget page, {TO? result}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  /// Push and remove all until predicate
  /// Example: context.navPushAndClear(HomePage(), (route) => false)
  Future<T?> navPushAndClear<T>(
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.of(
      this,
    ).pushAndRemoveUntil<T>(MaterialPageRoute(builder: (_) => page), predicate);
  }

  /// Push and clear all (go to root with new page)
  /// Example: context.navPushAndRemoveAll(LoginPage())
  Future<T?> navPushAndRemoveAll<T>(Widget page) {
    return navPushAndClear<T>(page, (route) => false);
  }

  /// Pop current route (Navigator)
  /// Example: context.navPop()
  void navPop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Pop until predicate
  /// Example: context.navPopUntil((route) => route.isFirst)
  void navPopUntil(bool Function(Route<dynamic>) predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  /// Pop to root (first route)
  /// Example: context.navPopToRoot()
  void navPopToRoot() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }

  /// Check if can pop (Navigator)
  bool get canNavPop => Navigator.of(this).canPop();

  // ═══════════════════════════════════════════════════════════════
  // FOCUS & KEYBOARD
  // ═══════════════════════════════════════════════════════════════

  void unfocus() => FocusScope.of(this).unfocus();
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // ═══════════════════════════════════════════════════════════════
  // AUTH (⭐ NEW)
  // ═══════════════════════════════════════════════════════════════

  /// Access global AppAuthCubit
  // AppAuthCubit get authCubit => read<AppAuthCubit>();

  // /// Watch global AppAuthState
  // AppAuthState get authState => watch<AppAuthCubit>().state;

  /// Get current authenticated user
  // UserModel? get currentUser => authState.user;

  /// Check if user is authenticated
  // bool get isAuthenticated => authState.isAuthenticated;
}

extension ContextToastExtensions on BuildContext {
  ToastService get toast => getIt<ToastService>();
}
