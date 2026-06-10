// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/riverpod/base_notifier.dart
//
// BaseNotifier — mixin cho Riverpod AsyncNotifier (Code-gen).
// Cung cấp bộ công cụ xử lý Async chuyên sâu, triệt tiêu Boilerplate.
//
// Features:
//   - runAsync / runUnwrap / runPagination / runResult: Tự động hóa luồng Async.
//   - cancelPrevious: Chống Race Condition (hủy request cũ).
//   - keepPreviousOnLoading: Dùng copyWithPrevious — state.isRefreshing + state.value
//     hoạt động native trên widget mà không cần field riêng.
//   - Success/Error Messaging: Kết hợp thông báo tùy chỉnh và lỗi hệ thống.
//   - lastFailure: Truy cập trực tiếp Failure để pattern-match trên UI.
//   - isEmpty / hasMore / paginationMeta: Các trạng thái dữ liệu.
// ════════════════════════════════════════════════════════════════
import 'package:flutter_base/core/base/errors/exceptions.dart';
import 'package:flutter_base/core/base/errors/failures.dart';
import 'package:flutter_base/core/base/errors/result.dart';
import 'package:flutter_base/core/data/network/api_paginated_data.dart';
import 'package:flutter_base/core/data/network/api_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'riverpod_extensions.dart';

mixin BaseNotifier<T> {
  // ── Contract — AsyncNotifier cung cấp sẵn ─────────────────────
  AsyncValue<T> get state;
  set state(AsyncValue<T> value);

  // ── Cancellation token ─────────────────────────────────────────
  int _generation = 0;

  // ── isRefreshing: dùng trực tiếp state.isRefreshing của Riverpod ──
  // Hoạt động đúng khi keepPreviousOnLoading = true (copyWithPrevious).
  bool get isRefreshing => state.isRefreshing;

  // ── Empty state ────────────────────────────────────────────────
  // Lưu ý: _isEmpty là field Dart thường, không reactive với Riverpod.
  // Widget rebuild khi state thay đổi, sau đó đọc notifier.isEmpty → đúng giá trị.
  // KHÔNG dùng notifier.isEmpty trong watch expression riêng lẻ.
  bool _isEmpty = false;
  bool get isEmpty => _isEmpty;

  // ── Last failure ───────────────────────────────────────────────
  Failure? _lastFailure;
  Failure? get lastFailure => _lastFailure;

  // ── Pending success/error messages ────────────────────────────
  // RiverpodListeners.async$ / useAsyncValueListener đọc để show Toast.
  String? _pendingSuccessMessage;
  String? get pendingSuccessMessage => _pendingSuccessMessage;

  String? _pendingErrorMessage;
  String? get pendingErrorMessage => _pendingErrorMessage;

  void clearMessages() {
    _pendingSuccessMessage = null;
    _pendingErrorMessage = null;
  }

  // ── Convenience getters ────────────────────────────────────────
  T? get currentData => state.asData?.value;

  // ── Pagination meta ────────────────────────────────────────────
  ApiMeta? _paginationMeta;
  ApiMeta? get paginationMeta => _paginationMeta;
  bool get hasMore => _paginationMeta?.hasMore ?? false;
  bool get isFirstPage => _paginationMeta?.isFirstPage ?? true;
  int get currentPage => _paginationMeta?.page ?? ApiMeta.defaultPage;
  int get totalItems => _paginationMeta?.total ?? 0;

  // ── Core engine ────────────────────────────────────────────────

  /// Phương thức nền tảng — tất cả runXxx đều delegate vào đây.
  ///
  /// [cancelPrevious] — tăng generation token để bỏ qua response từ call cũ.
  /// [keepPreviousOnLoading] — dùng copyWithPrevious, giữ state.value + state.isRefreshing
  ///   trong khi loading. Widget có thể hiển thị overlay refresh thay vì spinner trắng.
  Future<T?> runAsync({
    required Future<T> Function() action,
    bool cancelPrevious = false,
    bool keepPreviousOnLoading = false,
    bool emitEmptyForEmptyList = false,
    String? successMessage,
    String? errorMessage,
    void Function(T data)? onSuccess,
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    if (cancelPrevious) _generation++;
    final token = _generation;

    _isEmpty = false;
    _lastFailure = null;
    _pendingSuccessMessage = null;
    _pendingErrorMessage = null;

    // copyWithPrevious: giữ value cũ trong AsyncLoading → state.isRefreshing = true,
    // state.value = dữ liệu cũ. Widget dùng state.value để hiện overlay refresh.
    state = keepPreviousOnLoading ? state.asRefreshing : const AsyncLoading();

    final next = await AsyncValue.guard(() async {
      final result = await action();
      // Kiểm tra sau khi action() xong — nếu đã bị cancel thì không emit
      if (_generation != token) throw const _CancelledException();
      return result;
    });

    // Bỏ qua nếu đã bị cancel bởi call mới hơn
    if (_generation != token) return null;

    state = next;

    T? resultData;
    next.whenOrNull(
      data: (d) {
        if (emitEmptyForEmptyList && d is List && (d as List).isEmpty) {
          _isEmpty = true;
        }
        _pendingSuccessMessage = successMessage;
        onSuccess?.call(d);
        resultData = d;
      },
      error: (e, s) {
        if (e is Failure) _lastFailure = e;
        _pendingErrorMessage = errorMessage;
        onError?.call(e, s);
      },
    );
    return resultData;
  }

  /// Unwrap `ApiResponse<R>` → dùng mapper để chuyển sang state type T.
  /// Throw [ServerException] nếu response không thành công.
  ///
  /// [sideEffect] — chạy sau khi unwrap thành công, trước khi map sang T.
  /// Dùng cho: save tokens, clear cache, analytics... cần data nguyên gốc R.
  /// Ví dụ login: `sideEffect: (auth) => appAuth.loginSuccess(auth)`.
  Future<T?> runUnwrap<R extends Object>({
    required Future<ApiResponse<R>> Function() action,
    required T Function(R data) mapper,
    Future<void> Function(R data)? sideEffect,
    bool cancelPrevious = false,
    bool keepPreviousOnLoading = false,
    bool emitEmptyForEmptyList = false,
    String? successMessage,
    String? errorMessage,
    void Function(T data)? onSuccess,
    void Function(Object error, StackTrace stack)? onError,
  }) => runAsync(
    action: () async {
      final res = await action();
      if (!res.isSuccess || res.data == null) {
        throw ServerException(
          message: res.message ?? 'Đã có lỗi xảy ra',
          statusCode: res.statusCode,
        );
      }
      final data = res.data as R;
      if (sideEffect != null) await sideEffect(data);
      return mapper(data);
    },
    cancelPrevious: cancelPrevious,
    keepPreviousOnLoading: keepPreviousOnLoading,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
    successMessage: successMessage,
    errorMessage: errorMessage,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Unwrap `ApiResponse<ApiPaginatedData<R>>` → cập nhật paginationMeta
  /// và dùng mapper để convert danh sách items sang state type T.
  ///
  /// [sideEffect] — chạy sau unwrap, trước map. Nhận `List<R>` items.
  Future<T?> runPagination<R>({
    required Future<ApiResponse<ApiPaginatedData<R>>> Function() action,
    required T Function(List<R> items) mapper,
    Future<void> Function(List<R> items)? sideEffect,
    bool cancelPrevious = false,
    bool keepPreviousOnLoading = false,
    bool emitEmptyForEmptyList = false,
    String? successMessage,
    String? errorMessage,
    void Function(T data)? onSuccess,
    void Function(Object error, StackTrace stack)? onError,
  }) => runAsync(
    action: () async {
      final res = await action();
      if (!res.isSuccess || res.data == null) {
        throw ServerException(
          message: res.message ?? 'Đã có lỗi xảy ra',
          statusCode: res.statusCode,
        );
      }
      _paginationMeta = res.data!.meta;
      final items = res.data!.data;
      if (sideEffect != null) await sideEffect(items);
      return mapper(items);
    },
    cancelPrevious: cancelPrevious,
    keepPreviousOnLoading: keepPreviousOnLoading,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
    successMessage: successMessage,
    errorMessage: errorMessage,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Unwrap `Result<R>` → dùng mapper nếu success, throw Failure nếu failure.
  /// Dùng khi layer Repository trả về Result thay vì ApiResponse trực tiếp.
  ///
  /// [sideEffect] — chạy sau khi Result success, trước map.
  Future<T?> runResult<R>({
    required Future<Result<R>> Function() action,
    required T Function(R data) mapper,
    Future<void> Function(R data)? sideEffect,
    bool cancelPrevious = false,
    bool keepPreviousOnLoading = false,
    bool emitEmptyForEmptyList = false,
    String? successMessage,
    String? errorMessage,
    void Function(T data)? onSuccess,
    void Function(Object error, StackTrace stack)? onError,
  }) => runAsync(
    action: () async {
      final result = await action();
      return result.fold(
        onSuccess: (data) async {
          if (sideEffect != null) await sideEffect(data);
          return mapper(data);
        },
        onFailure: (f) => throw f,
      );
    },
    cancelPrevious: cancelPrevious,
    keepPreviousOnLoading: keepPreviousOnLoading,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
    successMessage: successMessage,
    errorMessage: errorMessage,
    onSuccess: onSuccess,
    onError: onError,
  );

  // ── State management helpers ───────────────────────────────────

  /// Reset toàn bộ state về AsyncLoading, xóa hết metadata.
  /// Dùng khi cần reinitialize (vd: đổi filter lớn, logout).
  void reset() {
    _generation++;
    _isEmpty = false;
    _lastFailure = null;
    _pendingSuccessMessage = null;
    _pendingErrorMessage = null;
    _paginationMeta = null;
    state = const AsyncLoading();
  }

  /// Chỉ reset pagination meta — dùng khi load lại từ trang 1.
  void resetPagination() => _paginationMeta = null;
}

final class _CancelledException implements Exception {
  const _CancelledException();
}
