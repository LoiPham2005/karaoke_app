// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/bloc_listeners.dart
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_base/core/common/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_state.dart';

/// Tập hợp BlocListener helpers phổ biến
class BlocListeners {
  BlocListeners._();

  /// Listener chuẩn: SnackBar khi failure hoặc success (có message).
  /// Màu lấy từ Theme — không hardcode.
  static BlocListener<B, BaseState<T>> common<B extends StateStreamable<BaseState<T>>, T>({
    void Function(BuildContext, BaseState<T>)? onFailure,
    void Function(BuildContext, BaseState<T>)? onSuccess,
    void Function(BuildContext, BaseState<T>)? listener,
    Widget? child,
  }) => BlocListener<B, BaseState<T>>(
    listener: (context, state) {
      listener?.call(context, state);

      if (state.isFailure && state.error != null) {
        onFailure?.call(context, state);
        context.toast.error(state.error!);
      } else if (state.isSuccess && state.message != null) {
        onSuccess?.call(context, state);
        context.toast.success(state.message!);
      }
    },
    child: child ?? const SizedBox.shrink(),
  );

  /// Listener chỉ xử lý failure — không hiển thị SnackBar tự động.
  static BlocListener<B, BaseState<T>> onError<B extends StateStreamable<BaseState<T>>, T>({
    required void Function(BuildContext context, String error, T? previousData) onFailure,
    Widget? child,
  }) => BlocListener<B, BaseState<T>>(
    listenWhen: (prev, curr) => curr.isFailure && prev != curr,
    listener: (context, state) {
      if (state.isFailure) {
        onFailure(context, state.error ?? 'Unknown error', state.data);
      }
    },
    child: child ?? const SizedBox.shrink(),
  );

  /// Listener chỉ xử lý success.
  static BlocListener<B, BaseState<T>> onSuccess<B extends StateStreamable<BaseState<T>>, T>({
    required void Function(BuildContext context, T data, String? message) onSuccess,
    Widget? child,
  }) => BlocListener<B, BaseState<T>>(
    listenWhen: (prev, curr) => curr.isSuccess && prev != curr,
    listener: (context, state) {
      if (state.isSuccess && state.data != null) {
        onSuccess(context, state.data as T, state.message);
      }
    },
    child: child ?? const SizedBox.shrink(),
  );
}
