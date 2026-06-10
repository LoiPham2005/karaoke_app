import '../../../errors/result.dart';
import '../../bloc/base_state.dart';
import '../base_provider.dart';

/// 📘 EXAMPLE: CÁCH SỬ DỤNG BASE PROVIDER
class UserProvider extends BaseProvider<List<String>> {
  Future<void> fetchUsers() async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['User 1', 'User 2']);
      },
    );
  }

  Future<void> saveUser(String name) async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return ResultSuccess(['Saved $name']);
      },
      successMessage: 'Lưu thành công',
    );
  }

  Future<void> customrun() async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['Custom']);
      },
      loadingState: BaseState.loading(),
    );
  }
}
