import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../errors/result.dart';
import '../auto_bloc/auto_bloc.dart';
import '../base_bloc.dart';
import '../base_event.dart';
import '../base_state.dart';
import '../bloc_listeners.dart';

// ════════════════════════════════════════════════════════════════
// 1. ĐỊNH NGHĨA EVENTS
// ════════════════════════════════════════════════════════════════

class LoadUsers extends BaseEvent {
  const LoadUsers();
}

class AddUser extends BaseEvent {
  final String name;
  const AddUser(this.name);

  @override
  List<Object?> get props => [name];
}

class RemoveUser extends BaseEvent {
  final int index;
  const RemoveUser(this.index);

  @override
  List<Object?> get props => [index];
}

// ════════════════════════════════════════════════════════════════
// 2. ĐỊNH NGHĨA BLOC
// ════════════════════════════════════════════════════════════════

class UserExampleBloc extends BaseBloc {
  /// Khởi tạo với state mặc định
  UserExampleBloc() : super(const BaseState<List<String>>.initial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<RemoveUser>(_onRemoveUser);
  }

  /// 📥 FETCH DATA (QUERY)
  Future<void> _onLoadUsers(LoadUsers event, Emitter<BaseState> emit) async {
    // run() tự động handle Loading, Success, Empty, Failure cho bạn
    await run(
      emit: emit,
      action: () async {
        // Giả lập gọi API thành công sau 1 giây
        await Future.delayed(const Duration(seconds: 1));
        return const Result.success(['An', 'Bình', 'Chi']);

        // Hoặc giả lập lỗi:
        // return const Result.failure(ServerFailure(message: 'Lỗi kết nối server'));
      },
    );
  }

  /// 🚀 SUBMIT ACTION (MUTATION)
  Future<void> _onAddUser(AddUser event, Emitter<BaseState> emit) async {
    final currentUsers = state.data as List<String>? ?? [];

    await run(
      emit: emit,
      action: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        return Result.success(event.name);
      },
      // mapper: Chuyển đổi kết quả API thành kiểu dữ liệu của state
      mapper: (newName) => [...currentUsers, newName],
      // successMessage: Tự động emit state với message để UI hiển thị Toast
      successMessage: 'Đã thêm thành viên mới!',
    );
  }

  Future<void> _onRemoveUser(RemoveUser event, Emitter<BaseState> emit) async {
    final currentUsers = List<String>.from(state.data as List? ?? []);
    if (event.index < currentUsers.length) {
      currentUsers.removeAt(event.index);
    }

    // Thủ công emit thành công nếu không cần qua API
    emit(BaseState.success(data: currentUsers));
  }
}

// ════════════════════════════════════════════════════════════════
// 3. UI USAGE EXAMPLE
// ════════════════════════════════════════════════════════════════

class UserExamplePage extends StatelessWidget {
  const UserExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AutoBloc Example')),
      // 🚀 AutoBlocConsumer: Kết hợp Builder và Listener
      // Nó sẽ tự động Register BLoC vào BlocManager và Dispose khi widget bị hủy
      body: AutoBlocConsumer<UserExampleBloc, BaseState>(
        onInit: (bloc) => bloc.add(const LoadUsers()), // Gọi ngay khi khởi tạo
        listener: (context, bloc, state) {
          // Lắng nghe các hiệu ứng phụ (Toast, Navigate, Dialog)
          if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.isSuccess && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, bloc, state) {
          // Sử dụng functional programming style .when() của BaseState
          return state.when(
            initial: () => const Center(child: Text('Bấm để tải dữ liệu')),
            loading: (previousData) =>
                const Center(child: CircularProgressIndicator()),
            success: (data, message) {
              final users = data as List<String>;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(users[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => bloc.add(RemoveUser(index)),
                  ),
                ),
              );
            },
            failure: (error, previousData) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lỗi: $error'),
                  ElevatedButton(
                    onPressed: () => bloc.add(const LoadUsers()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
            empty: (message) => const Center(child: Text('Danh sách trống')),
          );
        },
      ),
      floatingActionButton: AutoBlocBuilder<UserExampleBloc, BaseState>(
        // builder có access vào 'bloc' instance trực tiếp
        builder: (context, bloc, state) => FloatingActionButton(
          onPressed: state.isLoading
              ? null
              : () => bloc.add(const AddUser('Thành viên mới')),
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// 4. ADVANCED USAGE: SCOPED & FACTORY
// ════════════════════════════════════════════════════════════════

class DetailPageExample extends StatelessWidget {
  final int userId;
  const DetailPageExample({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AutoBlocBuilder<UserExampleBloc, BaseState>(
        // scopeKey: Dùng khi có nhiều instance của cùng 1 loại Bloc trong app
        // Ví dụ: Mỗi tab có 1 UserExampleBloc riêng biệt
        scopeKey: 'user_detail_$userId',

        // factory: Dùng khi cần truyền tham số vào Constructor mà GetIt không quản lý
        // factory: () => UserExampleBloc(initialId: userId),
        builder: (context, bloc, state) => Text('User ID: $userId'),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// 5. OPTIMIZATION: SELECTOR
// ════════════════════════════════════════════════════════════════

class UserCountWidget extends StatelessWidget {
  const UserCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ rebuild khi Số lượng user thay đổi, không rebuild khi tên user thay đổi
    return AutoBlocSelector<UserExampleBloc, BaseState, int>(
      selector: (state) => (state.data as List<String>?)?.length ?? 0,
      builder: (context, count) {
        return Text('Số lượng: $count');
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// 6. HELPER: BLOC LISTENERS
// ════════════════════════════════════════════════════════════════

class BaseListenerExample extends StatelessWidget {
  const BaseListenerExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocListeners.common để tự động hiển thị SnackBar khi có lỗi hoặc thông báo thành công
    // Giúp code UI sạch hơn, không cần viết listener thủ công cho mọi page
    return BlocListeners.common<UserExampleBloc, dynamic>(
      child: const Text('Nội dung trang'),
    );
  }
}
