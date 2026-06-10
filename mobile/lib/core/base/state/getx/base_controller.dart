import 'dart:async';

import 'package:get/get.dart';

import '../../../common/utils/logger.dart';
import '../../errors/failures.dart';
import '../../errors/result.dart';
import '../bloc/base_state.dart';

/// 🎯 BaseController cho GetX - Đồng bộ logic với BaseCubit
abstract class BaseController<T> extends GetxController {
  final Rx<BaseState<T>> _state;

  BaseController([BaseState<T>? initialState])
    : _state = (initialState ?? BaseState<T>.initial()).obs;

  BaseState<T> get state => _state.value;
  T? get data => state.data;

  Completer<void>? _currentOperation;

  void cancel() {
    if (_currentOperation != null && !_currentOperation!.isCompleted) {
      _currentOperation!.complete();
    }
  }

  void updateState(BaseState<T> newState) {
    _state.value = newState;
  }

  /// 🚀 Core run - Tương tự BaseCubit
  Future<T?> run<R>({
    required Future<Result<R>> Function() action,
    T Function(R data)? mapper,
    void Function(R data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T>? loadingState,
    String? successMessage,
  }) async {
    if (successMessage != null || loadingState != null) cancel();
    _currentOperation = Completer<void>();

    updateState(loadingState ?? BaseState.loading(previousData: state.data));

    try {
      final result = await action();
      if (_currentOperation?.isCompleted ?? false) return null;

      return result.fold(
        onSuccess: (rawData) {
          final T data = mapper != null ? mapper(rawData) : (rawData as T);

          if (data is List && data.isEmpty) {
            updateState(BaseState.empty());
          } else {
            updateState(BaseState.success(data: data, message: successMessage));
          }

          onSuccess?.call(rawData);
          return data;
        },
        onFailure: (failure) {
          updateState(
            BaseState.failure(error: failure.message, previousData: state.data),
          );
          onFailure?.call(failure);
          return null;
        },
      );
    } catch (e, stackTrace) {
      Logger.error(
        '$runtimeType: Execution error',
        error: e,
        stackTrace: stackTrace,
      );
      updateState(
        BaseState.failure(error: e.toString(), previousData: state.data),
      );
      onFailure?.call(UnknownFailure(message: e.toString()));
      return null;
    } finally {
      _currentOperation = null;
    }
  }

  void reset() {
    cancel();
    updateState(BaseState.initial());
  }

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}
