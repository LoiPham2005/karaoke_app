// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/navigation_service.dart
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

/// ⚠️ CHỈ DÙNG KHI KHÔNG CÓ CONTEXT
///
/// Use cases:
/// - Background notifications (FCM)
/// - Business logic callbacks
/// - Static utility methods
///
/// Example:
/// ```dart
/// // In FCM handler (no context available)
/// getIt<NavigationService>().goTo('/notification-detail');
/// ```
@LazySingleton()
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;
  NavigatorState? get navigator => navigatorKey.currentState;

  // ═══════════════════════════════════════════════════════════════
  // 🚀 GO_ROUTER METHODS (Recommended)
  // ═══════════════════════════════════════════════════════════════

  /// Navigate to route (replace current stack context)
  void goTo(String path, {Object? extra}) {
    if (context != null) context!.go(path, extra: extra);
  }

  /// Push new route onto the stack
  Future<T?>? pushTo<T>(String path, {Object? extra}) {
    return context?.push<T>(path, extra: extra);
  }

  /// Replace current route
  void replaceTo(String path, {Object? extra}) {
    if (context != null) context!.replace(path, extra: extra);
  }

  /// Pop current route
  void popRoute<T>([T? result]) {
    if (context != null && context!.canPop()) {
      context!.pop(result);
    }
  }

  /// Pop until root
  void popToRoot() {
    if (context != null) {
      while (context!.canPop()) {
        context!.pop();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 TRADITIONAL NAVIGATOR METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Push widget page
  /// Example: service.navPush(DetailsPage())
  Future<T?>? navPush<T>(Widget page) {
    return navigator?.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Push custom route
  /// Example: service.navPushRoute(customRoute)
  Future<T?>? navPushRoute<T>(Route<T> route) {
    return navigator?.push<T>(route);
  }

  /// Push and replace current
  /// Example: service.navReplace(HomePage())
  Future<T?>? navReplace<T, TO>(Widget page, {TO? result}) {
    return navigator?.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  /// Push and remove until
  /// Example: service.navPushAndClear(HomePage(), (route) => false)
  Future<T?>? navPushAndClear<T>(
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return navigator?.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }

  /// Push and remove all
  /// Example: service.navPushAndRemoveAll(LoginPage())
  Future<T?>? navPushAndRemoveAll<T>(Widget page) {
    return navPushAndClear<T>(page, (route) => false);
  }

  /// Pop current route (Navigator)
  /// Example: service.navPop()
  void navPop<T>([T? result]) {
    navigator?.pop<T>(result);
  }

  /// Pop until predicate
  /// Example: service.navPopUntil((route) => route.isFirst)
  void navPopUntil(bool Function(Route<dynamic>) predicate) {
    navigator?.popUntil(predicate);
  }

  /// Pop to first route (Navigator)
  /// Example: service.navPopToRoot()
  void navPopToRoot() {
    navigator?.popUntil((route) => route.isFirst);
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Check if context is available
  bool get hasContext => context != null;

  /// Check if can pop
  bool get canPop => context?.canPop() ?? false;

  /// Unfocus keyboard globally
  void unfocus() {
    if (context != null) FocusScope.of(context!).unfocus();
  }

  /// Request focus globally
  void requestFocus(FocusNode node) {
    if (context != null) FocusScope.of(context!).requestFocus(node);
  }
}
