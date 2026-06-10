import '../../../errors/result.dart';
import '../../bloc/base_state.dart';
import '../base_cubit.dart';

/// 📘 EXAMPLE: CÁCH SỬ DỤNG BASE CUBIT MỚI
class UserCubit extends BaseCubit<List<String>> {
  UserCubit() : super(const BaseState.initial());

  Future<void> fetchUsers() async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['User 1', 'User 2']);
      },
    );
  }

  Future<void> updateProfile(String name) async {
    await run(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['User updated']);
      },
      successMessage: 'Cập nhật thành công!',
    );
  }

  Future<void> loadMore() async {
    await runPagination(
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        final current = state.data ?? [];
        return ResultSuccess([...current, 'User ${current.length + 1}']);
      },
    );
  }
}
