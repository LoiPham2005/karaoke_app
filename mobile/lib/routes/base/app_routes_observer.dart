import 'package:flutter/widgets.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/modules/analytics/analytics_service.dart';
import 'package:injectable/injectable.dart';

/// Navigation observer — log route changes + track screen trên Firebase Analytics.
@singleton
class AppRoutesObserver extends NavigatorObserver {
  AppRoutesObserver(this._analytics);

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final name = _routeName(route);
    Logger.info('📱 Push: ${_routeName(previousRoute)} → $name', tag: 'NAV');
    _trackScreen(name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final prevName = _routeName(previousRoute);
    Logger.info('🔙 Pop: $prevName ← ${_routeName(route)}', tag: 'NAV');
    if (previousRoute != null) _trackScreen(prevName);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final name = _routeName(newRoute);
    Logger.info('🔁 Replace: ${_routeName(oldRoute)} → $name', tag: 'NAV');
    _trackScreen(name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    Logger.info(
      '🗑️ Remove: ${_routeName(route)} (stack below: ${_routeName(previousRoute)})',
      tag: 'NAV',
    );
  }

  String _routeName(Route<dynamic>? route) {
    if (route == null) return 'root';
    final name = route.settings.name;
    if (name == null || name.isEmpty) return 'anonymous';
    return name;
  }

  void _trackScreen(String name) {
    if (name == 'root' || name == 'anonymous') return;
    _analytics.logScreenView(screenName: name);
  }
}
