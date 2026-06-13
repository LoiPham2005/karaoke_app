import 'package:flutter/material.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/routes/config/app_router.dart';

/// 🌍 Global BuildContext — CHỈ DÙNG khi không có context cục bộ (service, observer...).
BuildContext get appContext {
  final ctx = getIt<AppRouter>().navigatorKey.currentContext;
  assert(ctx != null, '⛔ appContext is null — gọi quá sớm (router chưa ready)');
  return ctx!;
}

BuildContext? get appContextOrNull => getIt<AppRouter>().navigatorKey.currentContext;

extension BuildContextX on BuildContext {
  // ─── Theme & MediaQuery ──────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mq => MediaQuery.of(this);
  Size get screenSize => mq.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mq.padding;
  EdgeInsets get viewInsets => mq.viewInsets;
  bool get isKeyboardOpen => viewInsets.bottom > 0;
  bool get isDark => theme.brightness == Brightness.dark;

  // ─── Focus ───────────────────────────────────────────────────────
  void unfocus() => FocusScope.of(this).unfocus();
  void hideKeyboard() => unfocus();

  // ─── Navigation helpers ──────────────────────────────────────────
  NavigatorState get nav => Navigator.of(this);

  Future<T?> navPush<T>(Widget page) => Navigator.of(this)
      .push<T>(MaterialPageRoute<T>(builder: (_) => page));

  void navPop<T>([T? result]) => Navigator.of(this).pop(result);

  bool get canNavPop => Navigator.of(this).canPop();
}
