import '../../../errors/result.dart';
import '../../bloc/base_state.dart';
import '../base_controller.dart';

/// 📘 EXAMPLE: CÁCH SỬ DỤNG BASE CONTROLLER (GETX)
class UserXController extends BaseController<List<String>> {
  Future<void> fetchUsers() async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['User 1', 'User 2']);
      },
    );
  }

  Future<void> addUser(String name) async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return ResultSuccess(['User 1', 'User 2', name]);
      },
      successMessage: 'Thêm người dùng thành công',
    );
  }

  Future<void> fetchWithCustomStatus() async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['Data']);
      },
      loadingState: BaseState.loading(),
    );
  }
}
