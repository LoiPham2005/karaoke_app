// import 'package:karaoke/routes/config/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/core/services/quick_actions/quick_actions_service.dart';

abstract class QuickActionsHandler {
  /// Khởi tạo và thiết lập các sự kiện điều hướng khi click shortcut
  static void init(WidgetRef ref) {
    final qa = getIt<QuickActionsService>();
    qa.initialize(
      onAction: (type) {
        // final router = getIt<AppRouter>();
        // switch (type) {
        //   case 'search':
        //     router.push(const CharacterListRoute());
        //     break;
        //   case 'scan':
        //     router.push(const VoucherListRoute());
        //     break;
        //   case 'login':
        //     router.push(const LoginRoute());
        //     break;
        //   case 'logout':
        //     ref.read(appAuthProvider.notifier).logout();
        //     break;
        // }
      },
    );

    // Cập nhật danh sách shortcut ban đầu dựa trên auth state
    final isAuthenticated = ref.read(appAuthProvider).isAuthenticated;
    updateActions(isAuthenticated);
  }

  /// Cập nhật danh sách shortcut hiển thị trên Home Screen theo trạng thái đăng nhập
  static void updateActions(bool isAuthenticated) {
    final qa = getIt<QuickActionsService>();

    if (isAuthenticated) {
      qa.setActions([
        const QuickActionItem(type: 'search', label: 'Tìm kiếm', icon: 'ic_shortcut_search'),
        const QuickActionItem(type: 'scan', label: 'Quét mã', icon: 'ic_shortcut_scan'),
        const QuickActionItem(type: 'logout', label: 'Đăng xuất', icon: 'ic_shortcut_logout'),
      ]);
    } else {
      qa.setActions([
        const QuickActionItem(type: 'login', label: 'Đăng nhập', icon: 'ic_shortcut_login'),
      ]);
    }
  }
}
