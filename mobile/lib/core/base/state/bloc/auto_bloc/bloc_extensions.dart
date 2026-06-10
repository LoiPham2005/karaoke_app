// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/base_state_extensions.dart
// ════════════════════════════════════════════════════════════════

import '../base_state.dart';

/// Extension trên BaseState<T> — chỉ thêm những gì base_state.dart KHÔNG có
extension BaseStateX<T> on BaseState<T> {
  /// Transform data sang type khác khi success.
  /// Khác mapData (cùng type T) — cái này đổi sang type R.
  ///
  /// ```dart
  /// final namesState = productsState.mapTo((list) => list.map((p) => p.name).toList());
  /// ```
  BaseState<R> mapTo<R>(R Function(T data) mapper) {
    if (!isSuccess || data == null) return BaseState<R>.initial();
    return BaseState<R>.success(data: mapper(data as T), message: message);
  }

  /// Trả về data hoặc fallback nếu không có.
  ///
  /// ```dart
  /// final list = state.dataOrElse([]);
  /// ```
  T dataOrElse(T fallback) => data ?? fallback;
}
