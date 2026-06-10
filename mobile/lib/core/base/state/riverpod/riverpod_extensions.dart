import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── AsyncValue extensions ──────────────────────────────────────────────────

extension AsyncValueX<T> on AsyncValue<T> {
  T? get dataOrNull => whenOrNull(data: (d) => d);

  AsyncValue<R> mapData<R>(R Function(T data) mapper) => when(
    data: (data) => AsyncData(mapper(data)),
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );

  T dataOrDefault(T fallback) => whenOrNull(data: (d) => d) ?? fallback;

  /// Tạo AsyncLoading giữ nguyên data cũ (overlay refresh pattern).
  /// Khi state mới = loadingWithPrevious(state):
  ///   - state.isRefreshing == true
  ///   - state.value == data cũ (widget vẫn hiển thị được)
  ///
  /// copyWithPrevious là @internal trong Riverpod nhưng đây là wrapper tập trung —
  /// nếu API thay đổi chỉ cần sửa 1 chỗ này.
  // ignore: invalid_use_of_internal_member
  AsyncValue<T> get asRefreshing => AsyncLoading<T>().copyWithPrevious(this);
}


// ── BuildContext extensions ───────────────────────────────────────────────

extension BuildContextProviderX on BuildContext {
  /// Lấy [ProviderContainer] từ [BuildContext] — dùng khi cần read provider
  /// trong callback có context nhưng không có WidgetRef.
  ///
  /// ```dart
  /// onPressed: () => context.container.read(authProvider.notifier).logout(),
  /// ```
  ProviderContainer get container =>
      ProviderScope.containerOf(this, listen: false);
}
