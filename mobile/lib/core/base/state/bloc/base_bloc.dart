// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/state/bloc/base_bloc.dart
// ════════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:flutter_base/core/base/errors/error_handler.dart';
import 'package:flutter_base/core/base/errors/failures.dart';
import 'package:flutter_base/core/base/errors/result.dart';
import 'package:flutter_base/core/base/state/bloc/base_state.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/core/data/network/api_paginated_data.dart';
import 'package:flutter_base/core/data/network/api_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_event.dart';

/// 🎯 BaseBloc — Quản lý state tự động, fully type-safe
///
/// | Method                     | Action trả về                            | Khi nào dùng                        |
/// |----------------------------|------------------------------------------|-------------------------------------|
/// | run                        | Future<Result<R>>                        | Có Repository                       |
/// | runService                 | Future<R>                                | Gọi thẳng Retrofit Service          |
/// | runServiceUnwrap           | Future<ApiResponse<R>>                   | Service trả ApiResponse wrapper     |
/// | runResultUnwrap            | Future<Result<ApiResponse<R>>>           | Repo trả Result<ApiResponse>        |
/// | runChain                   | Future<Result<S>> (built ngoài)          | Complex chain thenMap/thenAsyncFlatMap |
/// | runPagination              | Future<Result<S>>                        | Phân trang qua Repository           |
/// | runPaginationService       | Future<S>                                | Phân trang thẳng Service            |
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
abstract class BaseBloc<E extends BaseEvent, S> extends Bloc<E, BaseState<S>> {
  BaseBloc([BaseState<S>? initialState]) : super(initialState ?? const BaseState.initial());

  bool _cancelled = false;

  void cancelOperation() => _cancelled = true;

  // ── Core engine (fully typed — không dynamic) ─────────────────
  //
  // [process] nhận raw response trả về Result<S> đã transform xong.
  // Không còn dynamic cast ẩn — mọi type được kiểm tra compile-time.

  Future<S?> _execute<R>({
    required Emitter<BaseState<S>> emit,
    required Future<R> Function() action,
    required Result<S> Function(R raw) process,
    void Function(S data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<S> Function(Failure failure, S? previousData)? failureMapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) async {
    if (cancelPrevious) cancelOperation();
    _cancelled = false;

    if (!emit.isDone) {
      emit(loadingState ?? BaseState.loading(previousData: state.data));
    }

    try {
      final raw = await action();
      if (_cancelled) return null;

      return process(raw).fold(
        onSuccess: (data) {
          if (emit.isDone) return null;
          if (emitEmptyForEmptyList && data is List && data.isEmpty) {
            emit(BaseState.empty());
          } else {
            emit(BaseState.success(data: data, message: successMessage));
          }
          onSuccess?.call(data);
          return data;
        },
        onFailure: (failure) {
          if (!emit.isDone) {
            emit(
              failureMapper?.call(failure, state.data) ??
                  BaseState.failure(error: failure.message, previousData: state.data),
            );
          }
          onFailure?.call(failure);
          return null;
        },
      );
    } catch (e, stackTrace) {
      if (_cancelled) return null;
      Logger.error('BaseBloc error', error: e, stackTrace: stackTrace);
      final failure = ErrorHandler.toFailure(e, stackTrace);
      if (!emit.isDone) {
        emit(
          failureMapper?.call(failure, state.data) ??
              BaseState.failure(error: failure.message, previousData: state.data),
        );
      }
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
  Future<S?> run<R>({
    required Emitter<BaseState<S>> emit,
    required Future<Result<R>> Function() action,
    S Function(R data)? mapper,
    void Function(S data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<S> Function(Failure failure, S? previousData)? failureMapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<Result<R>>(
    emit: emit,
    action: action,
    process: (result) => result.fold(
      onSuccess: (r) => Result.success(mapper != null ? mapper(r) : r as S),
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
  Future<S?> runService<R>({
    required Emitter<BaseState<S>> emit,
    required Future<R> Function() action,
    S Function(R data)? mapper,
    void Function(S data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<S> Function(Failure failure, S? previousData)? failureMapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<R>(
    emit: emit,
    action: action,
    process: (raw) => Result.success(mapper != null ? mapper(raw) : raw as S),
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 🟠 Service trả ApiResponse<R> → tự bóc gói
  Future<S?> runServiceUnwrap<R extends Object>({
    required Emitter<BaseState<S>> emit,
    required Future<ApiResponse<R>> Function() action,
    S Function(R data)? mapper,
    void Function(S data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<S> Function(Failure failure, S? previousData)? failureMapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<ApiResponse<R>>(
    emit: emit,
    action: action,
    process: (response) => _fromApiResponse<R, S>(response, mapper),
    onSuccess: onSuccess,
    onFailure: onFailure,
    failureMapper: failureMapper,
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: emitEmptyForEmptyList,
  );

  /// 🔴 Repository trả Result<ApiResponse<R>> → unwrap 2 tầng
  Future<S?> runResultUnwrap<R extends Object>({
    required Emitter<BaseState<S>> emit,
    required Future<Result<ApiResponse<R>>> Function() action,
    S Function(R data)? mapper,
    void Function(S data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<S> Function(Failure failure, S? previousData)? failureMapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<Result<ApiResponse<R>>>(
    emit: emit,
    action: action,
    process: (result) => result.fold(
      onSuccess: (response) => _fromApiResponse<R, S>(response, mapper),
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

  /// 🔗 Complex chain — nhận Future<Result<S>> đã build sẵn từ bên ngoài
  ///
  /// ```dart
  /// runChain(
  ///   emit: emit,
  ///   chain: () => _service.getProducts()
  ///       .asResult()
  ///       .thenMap((p) => p.data.where((e) => e.isActive).toList())
  ///       .thenAsyncFlatMap(_enrichFirstItem),
  /// );
  /// ```
  Future<S?> runChain({
    required Emitter<BaseState<S>> emit,
    required Future<Result<S>> Function() chain,
    void Function(S data)? onSuccess,
    void Function(Failure failure)? onFailure,
    BaseState<S> Function(Failure failure, S? previousData)? failureMapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
    bool emitEmptyForEmptyList = true,
  }) => _execute<Result<S>>(
    emit: emit,
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
  Future<S?> runPagination({
    required Emitter<BaseState<S>> emit,
    required Future<Result<S>> Function() action,
  }) => run<S>(emit: emit, action: action, emitEmptyForEmptyList: false);

  /// 📥 Pagination với Service trực tiếp
  Future<S?> runPaginationService({
    required Emitter<BaseState<S>> emit,
    required Future<S> Function() action,
  }) => runService<S>(emit: emit, action: action, emitEmptyForEmptyList: false);

  /// 📥 Load-more: Service trả ApiResponse<ApiPaginatedData<R>>
  ///
  /// ```dart
  /// runServiceUnwrapPagination(
  ///   emit: emit,
  ///   action: () => _service.getProducts(params: {'page': page}),
  ///   mapper: (items) => [...(state.data ?? []), ...items],
  /// );
  /// ```
  Future<S?> runServiceUnwrapPagination<R extends Object>({
    required Emitter<BaseState<S>> emit,
    required Future<ApiResponse<ApiPaginatedData<R>>> Function() action,
    required S Function(List<R> items) mapper,
    BaseState<S>? loadingState,
    String? successMessage,
    bool cancelPrevious = false,
  }) => runServiceUnwrap<ApiPaginatedData<R>>(
    emit: emit,
    action: action,
    mapper: (paginated) => mapper(paginated.data),
    loadingState: loadingState,
    successMessage: successMessage,
    cancelPrevious: cancelPrevious,
    emitEmptyForEmptyList: false,
  );

  /// 🔄 Reset về initial
  void reset(Emitter<BaseState<S>> emit) {
    cancelOperation();
    if (!emit.isDone) emit(const BaseState.initial());
  }

  @override
  Future<void> close() {
    cancelOperation();
    return super.close();
  }
}
