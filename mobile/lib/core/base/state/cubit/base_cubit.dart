// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/cubit/base_cubit.dart
// ════════════════════════════════════════════════════════════════
import 'package:flutter_base/core/base/errors/error_handler.dart';
import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/core/data/network/api_paginated_data.dart';
import 'package:flutter_base/core/data/network/api_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../errors/failures.dart';
import '../../errors/result.dart';

/// 🎯 BaseCubit — Quản lý state tự động, fully type-safe
///
/// | Method                     | Action trả về                            | Khi nào dùng                        |
/// |----------------------------|------------------------------------------|-------------------------------------|
/// | run                        | Future<Result<R>>                        | Có Repository                       |
/// | runService                 | Future<R>                                | Gọi thẳng Retrofit Service          |
/// | runServiceUnwrap           | Future<ApiResponse<R>>                   | Service trả ApiResponse wrapper     |
/// | runResultUnwrap            | Future<Result<ApiResponse<R>>>           | Repo trả Result<ApiResponse>        |
/// | runChain                   | Future<Result<T>> (built ngoài)          | Complex chain thenMap/thenAsyncFlatMap |
/// | runPagination              | Future<Result<T>>                        | Phân trang qua Repository           |
/// | runPaginationService       | Future<T>                                | Phân trang thẳng Service            |
/// | runServiceUnwrapPagination | Future<ApiResponse<ApiPaginatedData<R>>> | Load-more: bóc tách paginated list  |
///
/// Tham số dùng chung:
/// - [failureMapper]: tuỳ chỉnh state theo từng loại Failure
///   ```dart
///   failureMapper: (f, prev) => switch (f) {
///     NetworkFailure() => BaseState.failure(error: 'Mất mạng', previousData: prev),
///     AuthFailure()    => BaseState.failure(error: 'Hết phiên'),
///     _                => BaseState.failure(error: f.userMessage, previousData: prev),
///   }
///   ```
abstract class BaseCubit<T> extends Cubit<BaseState<T>> {
  BaseCubit([BaseState<T>? initialState]) : super(initialState ?? const BaseState.initial());

  bool _cancelled = false;

  // ── Pagination meta ────────────────────────────────────────────
  ApiMeta? _paginationMeta;

  ApiMeta? get paginationMeta => _paginationMeta;
  bool get hasMore => _paginationMeta?.hasMore ?? false;
  bool get isFirstPage => _paginationMeta?.isFirstPage ?? true;
  int get currentPaginationPage => _paginationMeta?.page ?? ApiMeta.defaultPage;
  int get totalPages => _paginationMeta?.totalPages ?? 1;
  int get totalItems => _paginationMeta?.total ?? 0;

  void cancelOperation() => _cancelled = true;

  void safeEmit(BaseState<T> newState) {
    if (!isClosed) emit(newState);
  }

  // ── Core engine (fully typed — không dynamic) ─────────────────
  //
  // [process] nhận raw response trả về Result<T> đã transform xong.
  // Không còn dynamic cast ẩn — mọi type được kiểm tra compile-time.

  Future<T?> _execute<R>({
    required Future<R> Function() action,
    required Result<T> Function(R raw) process,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T> Function(Failure failure, T? previousData)? failureMapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) async {
    if (cancelPrevious) cancelOperation();
    _cancelled = false;

    safeEmit(loadingState ?? BaseState.loading(previousData: state.data));

    try {
      final raw = await action();
      if (_cancelled) return null;

      return process(raw).fold(
        onSuccess: (data) {
          if (emitEmptyForEmptyList && data is List && data.isEmpty) {
            safeEmit(BaseState.empty());
          } else {
            safeEmit(BaseState.success(data: data, message: successMessage));
          }
          onSuccess?.call(data);
          return data;
        },
        onFailure: (failure) {
          safeEmit(
            failureMapper?.call(failure, state.data) ??
                BaseState.failure(error: failure.message, previousData: state.data),
          );
          onFailure?.call(failure);
          return null;
        },
      );
    } catch (e, stackTrace) {
      if (_cancelled) return null;
      Logger.error('BaseCubit error', error: e, stackTrace: stackTrace);
      final failure = ErrorHandler.toFailure(e, stackTrace);
      safeEmit(
        failureMapper?.call(failure, state.data) ??
            BaseState.failure(error: failure.message, previousData: state.data),
      );
      onFailure?.call(failure);
      return null;
    }
  }

  // ── ApiResponse helper (typed, dùng chung cho runServiceUnwrap + runResultUnwrap) ──

  // Api extends Object đảm bảo type param không nullable → loại bỏ warning `!` trên generic
  static Result<Data> _fromApiResponse<Api extends Object, Data>(
    ApiResponse<Api> response,
    Data Function(Api)? mapper,
  ) {
    final apiData = response.data;
    if (response.isSuccess && apiData != null) {
      return Result.success(mapper != null ? mapper(apiData) : apiData as Data);
    }
    return Result.failure(
      ServerFailure(
        message: response.message ?? 'Đã có lỗi xảy ra',
        statusCode: response.statusCode,
      ),
    );
  }

  // ── Public API ─────────────────────────────────────────────────

  /// 🔵 Repository → Result<R>
  Future<T?> run<R>({
    required Future<Result<R>> Function() action,
    T Function(R data)? mapper,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T> Function(Failure failure, T? previousData)? failureMapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<Result<R>>(
    action: action,
    process: (result) => result.fold(
      onSuccess: (r) => Result.success(mapper != null ? mapper(r) : r as T),
      onFailure: Result.failure,
    ),
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 🟢 Retrofit Service → Future<R> trực tiếp
  Future<T?> runService<R>({
    required Future<R> Function() action,
    T Function(R data)? mapper,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T> Function(Failure failure, T? previousData)? failureMapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<R>(
    action: action,
    process: (raw) => Result.success(mapper != null ? mapper(raw) : raw as T),
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 🟠 Service trả ApiResponse<R> → tự bóc gói
  Future<T?> runServiceUnwrap<R extends Object>({
    required Future<ApiResponse<R>> Function() action,
    T Function(R data)? mapper,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T> Function(Failure failure, T? previousData)? failureMapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<ApiResponse<R>>(
    action: action,
    process: (response) => _fromApiResponse<R, T>(response, mapper),
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 🔴 Repository trả Result<ApiResponse<R>> → unwrap 2 tầng
  Future<T?> runResultUnwrap<R extends Object>({
    required Future<Result<ApiResponse<R>>> Function() action,
    T Function(R data)? mapper,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T> Function(Failure failure, T? previousData)? failureMapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<Result<ApiResponse<R>>>(
    action: action,
    process: (result) => result.fold(
      onSuccess: (response) => _fromApiResponse<R, T>(response, mapper),
      onFailure: Result.failure,
    ),
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 🔗 Complex chain — nhận Future<Result<T>> đã build sẵn từ bên ngoài
  ///
  /// ```dart
  /// runChain(
  ///   chain: () => _service.getProducts()
  ///       .asResult()
  ///       .thenMap((p) => p.data.where((e) => e.isActive).toList())
  ///       .thenAsyncFlatMap(_enrichFirstItem),
  /// );
  /// ```
  Future<T?> runChain({
    required Future<Result<T>> Function() chain,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<T> Function(Failure failure, T? previousData)? failureMapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<Result<T>>(
    action: chain,
    process: (result) => result,
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 📥 Pagination với Repository
  Future<T?> runPagination({required Future<Result<T>> Function() action}) =>
      run<T>(action: action, emitEmptyForEmptyList: false);

  /// 📥 Pagination với Service trực tiếp
  Future<T?> runPaginationService({required Future<T> Function() action}) =>
      runService<T>(action: action, emitEmptyForEmptyList: false);

  /// 📥 Load-more: Service trả ApiResponse<ApiPaginatedData<R>>
  ///
  /// ```dart
  /// runServiceUnwrapPagination(
  ///   action: () => _service.getProducts(params: {'page': page}),
  ///   mapper: (items) => [...(state.data ?? []), ...items],
  /// );
  /// ```
  Future<T?> runServiceUnwrapPagination<R>({
    required Future<ApiResponse<ApiPaginatedData<R>>> Function() action,
    required T Function(List<R> items) mapper,
    BaseState<T>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
  }) => _execute<ApiResponse<ApiPaginatedData<R>>>(
    action: action,
    process: (response) {
      final apiData = response.data;
      if (response.isSuccess && apiData != null) {
        _paginationMeta = apiData.meta;
        return Result.success(mapper(apiData.data));
      }
      return Result.failure(
        ServerFailure(
          message: response.message ?? 'Đã có lỗi xảy ra',
          statusCode: response.statusCode,
        ),
      );
    },
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: false,
  );

  /// 🔄 Reset về initial
  void reset() {
    cancelOperation();
    safeEmit(const BaseState.initial());
  }

  @override
  Future<void> close() {
    cancelOperation();
    return super.close();
  }
}
