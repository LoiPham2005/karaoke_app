import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_base/core/base/di/global_providers.dart';
import 'package:flutter_base/core/services/app_auth/providers/app_auth_notifier.dart';
import 'package:flutter_base/core/services/utils/navigation_service.dart';
import 'package:flutter_base/routes/config/route_names.dart';
import 'package:injectable/injectable.dart';
import 'package:quick_actions/quick_actions.dart';

/// Quản lý App Shortcuts (long-press app icon → menu nhanh).
/// - Android 7.1+ (API 25+)
/// - iOS 9.0+
///
/// Shortcut tự đổi theo trạng thái đăng nhập:
/// - Chưa login → Đăng nhập, Đăng ký, Premium, Cài đặt
/// - Đã login  → Trang chủ, Premium, Cài đặt, Đăng xuất
@LazySingleton()
class AppQuickActionsService {
  AppQuickActionsService(this._nav);

  final NavigationService _nav;
  final QuickActions _quickActions = const QuickActions();

  bool _initialized = false;
  String? _pendingActionType;

  // ── Shortcut types ─────────────────────────────────────────────
  static const _typeLogin = 'action_login';
  static const _typeRegister = 'action_register';
  static const _typePremium = 'action_premium';
  static const _typeSettings = 'action_settings';
  static const _typeHome = 'action_home';
  static const _typeLogout = 'action_logout';

  /// Gọi 1 lần khi app khởi động (sau khi DI + NavigationService sẵn sàng).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _quickActions.initialize((shortcutType) {
      debugPrint('[QuickActions] Triggered: $shortcutType');
      _handleAction(shortcutType);
    });

    debugPrint('[QuickActions] Service initialized');
  }

  /// Set shortcut cho user CHƯA đăng nhập.
  Future<void> setForUnauthenticated() async {
    await _quickActions.setShortcutItems(const [
      ShortcutItem(
        type: _typeLogin,
        localizedTitle: 'Đăng nhập',
        icon: 'ic_shortcut_login',
      ),
      ShortcutItem(
        type: _typeRegister,
        localizedTitle: 'Đăng ký',
        icon: 'ic_shortcut_register',
      ),
      ShortcutItem(
        type: _typePremium,
        localizedTitle: 'Mua Premium',
        icon: 'ic_shortcut_premium',
      ),
      ShortcutItem(
        type: _typeSettings,
        localizedTitle: 'Cài đặt',
        icon: 'ic_shortcut_settings',
      ),
    ]);
    debugPrint('[QuickActions] Set shortcuts for unauthenticated');
  }

  /// Set shortcut cho user ĐÃ đăng nhập.
  Future<void> setForAuthenticated() async {
    await _quickActions.setShortcutItems(const [
      ShortcutItem(
        type: _typeHome,
        localizedTitle: 'Trang chủ',
        icon: 'ic_shortcut_home',
      ),
      ShortcutItem(
        type: _typePremium,
        localizedTitle: 'Mua Premium',
        icon: 'ic_shortcut_premium',
      ),
      ShortcutItem(
        type: _typeSettings,
        localizedTitle: 'Cài đặt',
        icon: 'ic_shortcut_settings',
      ),
      ShortcutItem(
        type: _typeLogout,
        localizedTitle: 'Đăng xuất',
        icon: 'ic_shortcut_logout',
      ),
    ]);
    debugPrint('[QuickActions] Set shortcuts for authenticated');
  }

  /// Xóa toàn bộ shortcut (vd: khi disable feature).
  Future<void> clear() => _quickActions.clearShortcutItems();

  /// Nếu app khởi động từ shortcut nhưng navigator chưa ready,
  /// gọi method này SAU khi MaterialApp build xong để consume action pending.
  void consumePendingAction() {
    if (_pendingActionType == null) return;
    final type = _pendingActionType!;
    _pendingActionType = null;
    _handleAction(type);
  }

  // ── Handlers ───────────────────────────────────────────────────

  void _handleAction(String type) {
    // Nếu navigator chưa ready (cold start từ shortcut), defer
    if (_nav.context == null) {
      debugPrint('[QuickActions] Navigator not ready, deferring action: $type');
      _pendingActionType = type;
      _retryLater(type);
      return;
    }

    switch (type) {
      case _typeLogin:
        _nav.goTo(RouteNames.login);
      case _typeRegister:
        _nav.goTo(RouteNames.register);
      case _typePremium:
        _nav.goTo(RouteNames.premium);
      case _typeSettings:
        _nav.goTo(RouteNames.settings);
      case _typeHome:
        _nav.goTo(RouteNames.home);
      case _typeLogout:
        // unawaited(globalContainer.read(appAuthProvider.notifier).logout());
      default:
        debugPrint('[QuickActions] Unknown action: $type');
    }
  }

  void _retryLater(String type, {int attempts = 0}) {
    if (attempts > 10) {
      debugPrint('[QuickActions] Gave up retrying action: $type');
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_nav.context != null) {
        _pendingActionType = null;
        _handleAction(type);
      } else {
        _retryLater(type, attempts: attempts + 1);
      }
    });
  }
}
