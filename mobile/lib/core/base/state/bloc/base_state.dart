// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/base_state.dart
// ════════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:flutter_base/core/base/state/base_status.dart';


const _$sentinel = Object();

/// 🎯 Unified Base State — BLoC / Cubit
///
/// Flow:     initial → loading → success | empty | failure
/// Refresh:  loading(previousData) — giữ data cũ khi reload
/// Pattern:  when / whenReady / maybeWhen / whenSuccess
class BaseState<T> extends Equatable {
  final BaseStatus status;
  final T? data;
  final String? error;
  final String? message;

  const BaseState._({required this.status, this.data, this.error, this.message});

  // ── Factories ──────────────────────────────────────────────────

  const factory BaseState.initial() = _Initial;

  factory BaseState.loading({T? previousData}) =>
      BaseState._(status: BaseStatus.loading, data: previousData);

  factory BaseState.success({required T data, String? message}) =>
      BaseState._(status: BaseStatus.success, data: data, message: message);

  factory BaseState.empty({String? message}) =>
      BaseState._(status: BaseStatus.empty, message: message);

  factory BaseState.failure({required String error, T? previousData}) =>
      BaseState._(status: BaseStatus.failure, error: error, data: previousData);

  // ── Status checks ──────────────────────────────────────────────

  bool get isInitial => status == BaseStatus.initial;
  bool get isLoading => status == BaseStatus.loading;
  bool get isSuccess => status == BaseStatus.success;
  bool get isEmpty => status == BaseStatus.empty;
  bool get isFailure => status == BaseStatus.failure;

  bool get hasData => data != null;
  bool get hasError => error != null;

  /// Đang loading nhưng vẫn còn data cũ → dùng để hiển thị skeleton overlay
  bool get isRefreshing => isLoading && hasData;

  /// Đã xong (thành công hoặc thất bại), không còn pending
  bool get isDone => isSuccess || isFailure || isEmpty;

  /// Initial hoặc đang loading — chưa có kết quả
  bool get isLoadingOrInitial => isLoading || isInitial;

  // ── Display ────────────────────────────────────────────────────

  String get displayMessage => error ?? message ?? _defaultMessage;

  String get _defaultMessage => switch (status) {
    BaseStatus.loading => hasData ? 'Đang cập nhật...' : 'Đang tải...',
    BaseStatus.success => 'Thành công',
    BaseStatus.empty => 'Không có dữ liệu',
    BaseStatus.failure => 'Đã xảy ra lỗi',
    _ => '',
  };

  // ── copyWith ───────────────────────────────────────────────────

  BaseState<T> copyWith({
    BaseStatus? status,
    Object? data = _$sentinel,
    Object? error = _$sentinel,
    Object? message = _$sentinel,
  }) => BaseState._(
    status: status ?? this.status,
    data: data == _$sentinel ? this.data : data as T?,
    error: error == _$sentinel ? this.error : error as String?,
    message: message == _$sentinel ? this.message : message as String?,
  );

  // ── Pattern matching ───────────────────────────────────────────

  /// Exhaustive — bắt buộc xử lý tất cả trạng thái.
  ///
  /// ```dart
  /// state.when(
  ///   initial:  ()            => const SizedBox(),
  ///   loading:  (data)        => data != null ? OldList(data) : const Spinner(),
  ///   success:  (data, msg)   => ProductList(data),
  ///   empty:    (_)           => const EmptyView(),
  ///   failure:  (err, data)   => ErrorView(err),
  /// )
  /// ```
  R when<R>({
    required R Function() initial,
    required R Function(T? previousData) loading,
    required R Function(T data, String? message) success,
    required R Function(String? message) empty,
    required R Function(String error, T? previousData) failure,
  }) => switch (status) {
    BaseStatus.initial => initial(),
    BaseStatus.loading => loading(data),
    BaseStatus.success => data != null ? success(data as T, message) : empty(message),
    BaseStatus.empty => empty(message),
    BaseStatus.failure => failure(error ?? 'Unknown error', data),
  };

  /// Bỏ qua [initial] — initial tự map sang loading(null).
  ///
  /// ```dart
  /// state.whenReady(
  ///   loading: (data) => const Spinner(),
  ///   success: (data, msg) => ProductList(data),
  ///   empty:   (_)    => const EmptyView(),
  ///   failure: (err, _) => ErrorView(err),
  /// )
  /// ```
  R whenReady<R>({
    required R Function(T? previousData) loading,
    required R Function(T data, String? message) success,
    required R Function(String? message) empty,
    required R Function(String error, T? previousData) failure,
  }) => when(
    initial: () => loading(null),
    loading: loading,
    success: success,
    empty: empty,
    failure: failure,
  );

  /// Non-exhaustive — dùng [orElse] cho các case không cần xử lý.
  ///
  /// ```dart
  /// state.maybeWhen(
  ///   success:  (data, _) => ProductList(data),
  ///   orElse:   ()        => const SizedBox(),
  /// )
  /// ```
  R maybeWhen<R>({
    R Function()? initial,
    R Function(T? previousData)? loading,
    R Function(T data, String? message)? success,
    R Function(String? message)? empty,
    R Function(String error, T? previousData)? failure,
    required R Function() orElse,
  }) => switch (status) {
    BaseStatus.initial => initial?.call() ?? orElse(),
    BaseStatus.loading => loading?.call(data) ?? orElse(),
    BaseStatus.success =>
      data != null
          ? (success?.call(data as T, message) ?? empty?.call(message) ?? orElse())
          : (empty?.call(message) ?? orElse()),
    BaseStatus.empty => empty?.call(message) ?? orElse(),
    BaseStatus.failure => failure?.call(error ?? 'Unknown error', data) ?? orElse(),
  };

  /// Shorthand — chỉ xử lý khi success có data.
  ///
  /// ```dart
  /// state.whenSuccess((data, msg) => doSomething(data));
  /// ```
  R? whenSuccess<R>(R Function(T data, String? message) onSuccess) {
    if (isSuccess && data != null) return onSuccess(data as T, message);
    return null;
  }

  // ── Transform ──────────────────────────────────────────────────

  /// Biến đổi data cùng type khi success, giữ nguyên nếu không phải success.
  ///
  /// ```dart
  /// final newState = state.mapData((list) => [...list, newItem]);
  /// ```
  BaseState<T> mapData(T Function(T data) fn) {
    if (isSuccess && data != null) return copyWith(data: fn(data as T));
    return this;
  }

  /// Biến đổi sang type khác khi success.
  ///
  /// ```dart
  /// final namesState = productsState.mapTo((list) => list.map((p) => p.name).toList());
  /// ```
  BaseState<R> mapTo<R>(R Function(T data) mapper) {
    if (!isSuccess || data == null) return const BaseState.initial();
    return BaseState<R>.success(data: mapper(data as T), message: message);
  }

  /// Lấy data hoặc fallback nếu null.
  ///
  /// ```dart
  /// final list = state.dataOrElse([]);
  /// ```
  T dataOrElse(T fallback) => data ?? fallback;

  // ── Combine ────────────────────────────────────────────────────

  /// Zip 2 states — chỉ success khi cả 2 đều success.
  /// Dùng khi cần combine 2 data source trước khi render.
  ///
  /// ```dart
  /// final combined = BaseState.zip(userState, settingsState);
  /// combined.whenSuccess((data, _) {
  ///   final (user, settings) = data;
  ///   ...
  /// });
  /// ```
  static BaseState<(A, B)> zip<A, B>(BaseState<A> a, BaseState<B> b) {
    if (a.isFailure) return BaseState.failure(error: a.error!);
    if (b.isFailure) return BaseState.failure(error: b.error!);
    if (a.isSuccess && b.isSuccess && a.data != null && b.data != null) {
      return BaseState.success(data: (a.data as A, b.data as B));
    }
    return BaseState.loading();
  }

  // ── Equatable ─────────────────────────────────────────────────

  @override
  List<Object?> get props => [status, data, error, message];

  @override
  String toString() => 'BaseState.$status(data: $hasData, error: $error, msg: $message)';
}

class _Initial<T> extends BaseState<T> {
  const _Initial() : super._(status: BaseStatus.initial);
}
