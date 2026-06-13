import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:karaoke/core/services/utils/logger.dart';

/// Observer tự động log navigation — push / pop / replace.
/// Chỉ active khi LogConfig.enabled (kDebugMode mặc định).
class RouteLogger extends AutoRouterObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = _routeName(route);
    final from = _routeName(previousRoute);
    Logger.info('➡️  $from → $name', tag: 'NAV');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = _routeName(route);
    final to = _routeName(previousRoute);
    Logger.info('⬅️  $name ← (back to $to)', tag: 'NAV');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final from = _routeName(oldRoute);
    final to = _routeName(newRoute);
    Logger.info('🔄  $from → $to (replace)', tag: 'NAV');
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    Logger.info('📑  Tab init: ${_formatRouteName(route.name)}', tag: 'NAV');
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    Logger.info('📑  Tab: ${_formatRouteName(previousRoute.name)} → ${_formatRouteName(route.name)}', tag: 'NAV');
  }

  String _formatRouteName(String name) {
    if (name.endsWith('Route')) {
      final pageName = '${name.substring(0, name.length - 5)}Page';
      return '$name ($pageName)';
    }
    return name;
  }

  String _routeName(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return 'unknown';
    return _formatRouteName(name);
  }
}
