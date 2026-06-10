import 'package:flutter/material.dart';
import 'package:flutter_base/core/base/state/riverpod/base_notifier.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/utils/toast_service.dart';
import '../../errors/failures.dart';

class RiverpodListeners {
  RiverpodListeners._();

  /// Listener cho AsyncValue — toast error / success tự động.
  ///
  /// Hỗ trợ 2 nguồn `successMessage`/`errorMessage`:
  /// 1. [notifier] — per-method message (truyền vào `runAsync/runUnwrap/...`),
  ///    ưu tiên cao hơn. RiverpodListeners tự clear sau khi show.
  /// 2. [successMessage]/[errorMessage] — global fallback.
  static void async$<T>({
    required WidgetRef ref,
    required BuildContext context,
    required ProviderListenable<AsyncValue<T>> provider,
    BaseNotifier<T>? notifier,
    String? successMessage,
    String? errorMessage,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
  }) {
    ref.listen<AsyncValue<T>>(provider, (previous, next) {
      if (next == previous) return;
      next.whenOrNull(
        error: (error, _) {
          final customMsg = notifier?.pendingErrorMessage ?? errorMessage;
          final systemMsg = error is Failure ? error.userMessage : error.toString();

          // Kết hợp: "Thông báo của bạn: Lỗi từ hệ thống"
          final msg = customMsg != null ? '$customMsg: $systemMsg' : systemMsg;

          toast.error(msg);
          notifier?.clearMessages();
          if (error is Failure) onFailure?.call(error);
        },
        data: (data) {
          // Ưu tiên Message từ Notifier
          final msg = notifier?.pendingSuccessMessage ?? successMessage;
          if (msg != null) {
            toast.success(msg);
          }
          notifier?.clearMessages();
          onSuccess?.call(data);
        },
      );
    });
  }
}

/// Hook convenience wrapper cho [RiverpodListeners.async$].
/// Dùng trong [HookConsumerWidget] — truyền [ref] từ build(context, ref).
void useAsyncValueListener<T>({
  required ProviderListenable<AsyncValue<T>> provider,
  required WidgetRef ref,
  BaseNotifier<T>? notifier,
  String? successMessage,
  String? errorMessage,
  void Function(T data)? onSuccess,
  void Function(Failure failure)? onFailure,
}) {
  final context = useContext();
  RiverpodListeners.async$(
    ref: ref,
    context: context,
    provider: provider,
    notifier: notifier,
    successMessage: successMessage,
    errorMessage: errorMessage,
    onSuccess: onSuccess,
    onFailure: onFailure,
  );
}
