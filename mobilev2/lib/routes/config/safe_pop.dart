import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:karaoke/routes/config/app_router.dart';

/// Pop nếu có thể, ngược lại replace về Home.
/// Dùng cho mọi nút Back để tránh "There is nothing to pop".
void safePop(BuildContext context) {
  if (context.router.canPop()) {
    context.router.maybePop();
  } else {
    context.router.replaceAll([const MainRoute()]);
  }
}
