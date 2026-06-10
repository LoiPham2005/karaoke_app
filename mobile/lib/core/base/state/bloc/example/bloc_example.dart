import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../errors/result.dart';
import '../base_bloc.dart';
import '../base_event.dart';
import '../base_state.dart';

/// 📘 EXAMPLE: CÁCH SỬ DỤNG BASE BLOC MỚI
class UserBloc extends BaseBloc {
  UserBloc() : super(const BaseState.initial()) {
    on<LoadUsers>(_onLoadUsers);
    on<UpdateUser>(_onUpdateUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<BaseState> emit) async {
    await run(
      emit: emit,
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess(['User 1', 'User 2']);
      },
    );
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<BaseState> emit) async {
    await run(
      emit: emit,
      action: () async {
        await Future.delayed(const Duration(seconds: 1));
        return const ResultSuccess('OK');
      },
      successMessage: 'Cập nhật thành công',
    );
  }
}

class LoadUsers extends BaseEvent {
  const LoadUsers();
}

class UpdateUser extends BaseEvent {
  final String name;
  const UpdateUser(this.name);
}
