import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../common/utils/logger.dart';
import '../../errors/failures.dart';
import '../../errors/result.dart';
import '../bloc/base_state.dart';

/// 🎯 BaseProvider cho Provider/ChangeNotifier - Đồng bộ logic với BaseCubit
abstract class BaseProvider<T> extends ChangeNotifier {
  BaseState<T> _state;

  BaseProvider([BaseState<T>? initialState])
    : _state = initialState ?? BaseState<T>.initial();

  BaseState<T> get state => _state;
  T? get data => _state.data;

  Completer<void>? _currentOperation;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    cancel();
    super.dispose();
  }

  void cancel() {
    if (_currentOperation != null && !_currentOperation!.isCompleted) {
      _currentOperation!.complete();
    }
  }

  void updateState(BaseState<T> newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  /// 🚀 Core run
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
}
