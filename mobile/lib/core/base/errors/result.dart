import './failures.dart';

/// Result pattern using sealed classes for exhaustive matching (Dart 3.x)
/// 🎯 WORLD-CLASS IMPLEMENTATION
sealed class Result<T> {
  const Result();

  /// Create a success result
  const factory Result.success(T data) = ResultSuccess<T>;

  /// Create a failure result
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is ResultSuccess<T>;
  bool get isFailure => this is ResultFailure<T>;

  T? get dataOrNull => fold(onSuccess: (data) => data, onFailure: (_) => null);
  Failure? get failureOrNull => fold(onSuccess: (_) => null, onFailure: (f) => f);

  // ═══════════════════════════════════════════════════════════
  // Core Methods
  // ═══════════════════════════════════════════════════════════

  /// Fold - Exhaustive matching using switch expression
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      ResultSuccess(data: final data) => onSuccess(data),
      ResultFailure(failure: final failure) => onFailure(failure),
    };
  }

  /// Map - Transform success data
  Result<R> map<R>(R Function(T data) transform) {
    return fold(
      onSuccess: (data) => Result.success(transform(data)),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  /// FlatMap - Chain operations
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return fold(onSuccess: transform, onFailure: (failure) => Result.failure(failure));
  }

  /// Get data or fallback
  T getOrElse(T Function() orElse) {
    return fold(onSuccess: (data) => data, onFailure: (_) => orElse());
  }

  /// Get value or throw the [Failure] directly
  /// Callers can catch specific failure types: `on AuthFailure`, `on NetworkFailure`, etc.
  T getOrThrow() => fold(onSuccess: (data) => data, onFailure: (failure) => throw failure);
}

/// Success state implementation
final class ResultSuccess<T> extends Result<T> {
  final T data;
  const ResultSuccess(this.data);

  @override
  String toString() => 'Result.success($data)';
}

/// Failure state implementation
final class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);

  @override
  String toString() => 'Result.failure($failure)';
}

// ═══════════════════════════════════════════════════════════
// Convenience Extensions
// ═══════════════════════════════════════════════════════════

extension ResultListX<T> on Result<List<T>> {
  /// Map list items
  Result<List<R>> mapItems<R>(R Function(T item) transform) {
    return map((list) => list.map(transform).toList());
  }

  /// Filter list
  Result<List<T>> where(bool Function(T item) test) {
    return map((list) => list.where(test).toList());
  }
}

extension ResultFutureX<T> on Future<Result<T>> {
  /// Transform success data (sync) — giữ nguyên nếu failure
  /// ```dart
  /// await getUser(id).thenMap((user) => user.name);
  /// ```
  Future<Result<R>> thenMap<R>(R Function(T data) transform) async {
    return (await this).map(transform);
  }

  /// Chain một sync operation — tiếp tục nếu success
  /// ```dart
  /// await getUser(id).thenFlatMap((user) => validateUser(user));
  /// ```
  Future<Result<R>> thenFlatMap<R>(Result<R> Function(T data) transform) async {
    return (await this).flatMap(transform);
  }

  /// Chain một ASYNC operation — tiếp tục nếu success
  /// ```dart
  /// await getUserUseCase(id)
  ///     .thenAsyncFlatMap((user) => getOrdersUseCase(user.id));
  /// ```
  Future<Result<R>> thenAsyncFlatMap<R>(Future<Result<R>> Function(T data) transform) async {
    final result = await this;
    return switch (result) {
      ResultSuccess(:final data) => transform(data),
      ResultFailure(:final failure) => Result.failure(failure),
    };
  }

  /// Xử lý cả 2 nhánh async — shorthand để tránh await + switch
  /// ```dart
  /// await getUser(id).thenFold(
  ///   onSuccess: (user) => emit(Loaded(user)),
  ///   onFailure: (f) => emit(Error(f.userMessage)),
  /// );
  /// ```
  Future<void> thenFold({
    required void Function(T data) onSuccess,
    required void Function(Failure failure) onFailure,
  }) async {
    (await this).fold(onSuccess: onSuccess, onFailure: onFailure);
  }
}
