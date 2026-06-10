// ════════════════════════════════════════════════════════════════
// 📁 lib/core/base/usecases/usecase.dart
// ════════════════════════════════════════════════════════════════

import '../errors/result.dart';

// ════════════════════════════════════════════════════════════════
// Type Aliases
// ════════════════════════════════════════════════════════════════

typedef FutureResult<T> = Future<Result<T>>;
typedef StreamResult<T> = Stream<Result<T>>;
typedef FutureVoidResult = Future<Result<void>>;
typedef FutureBoolResult = Future<Result<bool>>;

// ════════════════════════════════════════════════════════════════
// Async — có Input
// ════════════════════════════════════════════════════════════════

/// UseCase async có input.
///
/// ```dart
/// class GetCourtUseCase extends UseCase<CourtModel, IdParam> {
///   final CourtRepository _repo;
///   const GetCourtUseCase(this._repo);
///
///   @override
///   FutureResult<CourtModel> call(IdParam params) => _repo.getById(params.id);
/// }
///
/// // Cubit:
/// final result = await _getCourtUseCase(IdParam(courtId));
/// ```
abstract class UseCase<T, P> {
  const UseCase();
  FutureResult<T> call(P params);
}

// ════════════════════════════════════════════════════════════════
// Async — không Input
// ════════════════════════════════════════════════════════════════

/// UseCase async không input.
///
/// ```dart
/// class GetCurrentUserUseCase extends UseCaseNoParams<UserModel> {
///   final AuthRepository _repo;
///   const GetCurrentUserUseCase(this._repo);
///
///   @override
///   FutureResult<UserModel> call() => _repo.getCurrentUser();
/// }
///
/// // Cubit:
/// final result = await _getCurrentUserUseCase();
/// ```
abstract class UseCaseNoParams<T> {
  const UseCaseNoParams();
  FutureResult<T> call();
}

// ════════════════════════════════════════════════════════════════
// Void — có Input
// ════════════════════════════════════════════════════════════════

/// UseCase thao tác (create/update/delete) có input.
/// Trả Result<void> — caller vẫn biết success/failure dù không có data.
///
/// ```dart
/// class BookCourtUseCase extends VoidUseCase<BookingParams> {
///   final BookingRepository _repo;
///   const BookCourtUseCase(this._repo);
///
///   @override
///   FutureVoidResult call(BookingParams params) => _repo.book(params);
/// }
///
/// // Cubit:
/// final result = await _bookCourtUseCase(params);
/// result.fold(
///   onSuccess: (_) => emit(state.booked()),
///   onFailure: (f) => emit(state.error(f)),
/// );
/// ```
abstract class VoidUseCase<P> {
  const VoidUseCase();
  FutureVoidResult call(P params);
}

// ════════════════════════════════════════════════════════════════
// Void — không Input
// ════════════════════════════════════════════════════════════════

/// UseCase thao tác không input.
///
/// ```dart
/// class LogoutUseCase extends VoidUseCaseNoParams {
///   final AuthRepository _repo;
///   const LogoutUseCase(this._repo);
///
///   @override
///   FutureVoidResult call() => _repo.logout();
/// }
///
/// // Cubit:
/// final result = await _logoutUseCase();
/// ```
abstract class VoidUseCaseNoParams {
  const VoidUseCaseNoParams();
  FutureVoidResult call();
}

// ════════════════════════════════════════════════════════════════
// Sync — có Input
// ════════════════════════════════════════════════════════════════

/// UseCase đồng bộ có input — business logic thuần túy, không network/IO.
///
/// ```dart
/// class ValidateBookingUseCase extends SyncUseCase<bool, BookingParams> {
///   const ValidateBookingUseCase();
///
///   @override
///   Result<bool> call(BookingParams params) {
///     if (params.endTime.isBefore(params.startTime)) {
///       return Result.failure(
///         DataFailure(message: 'Giờ kết thúc phải sau giờ bắt đầu'),
///       );
///     }
///     return const Result.success(true);
///   }
/// }
///
/// // Cubit — không cần await:
/// final result = _validateBookingUseCase(params);
/// ```
abstract class SyncUseCase<T, P> {
  const SyncUseCase();
  Result<T> call(P params);
}

// ════════════════════════════════════════════════════════════════
// Sync — không Input
// ════════════════════════════════════════════════════════════════

/// UseCase đồng bộ không input.
///
/// ```dart
/// class GetAppConfigUseCase extends SyncUseCaseNoParams<AppConfig> {
///   final ConfigService _service;
///   const GetAppConfigUseCase(this._service);
///
///   @override
///   Result<AppConfig> call() => Result.success(_service.config);
/// }
/// ```
abstract class SyncUseCaseNoParams<T> {
  const SyncUseCaseNoParams();
  Result<T> call();
}

// ════════════════════════════════════════════════════════════════
// Stream — có Input
// ════════════════════════════════════════════════════════════════

/// Stream UseCase có input — realtime data (WebSocket, Firestore, v.v.).
///
/// ```dart
/// class WatchCourtAvailabilityUseCase
///     extends StreamUseCase<List<SlotModel>, IdParam> {
///   final CourtRepository _repo;
///   const WatchCourtAvailabilityUseCase(this._repo);
///
///   @override
///   StreamResult<List<SlotModel>> call(IdParam params) =>
///       _repo.watchSlots(params.id);
/// }
///
/// // Cubit:
/// _subscription = _watchAvailabilityUseCase(IdParam(courtId)).listen(
///   (result) => result.fold(
///     onSuccess: (slots) => emit(state.slotsUpdated(slots)),
///     onFailure: (f) => emit(state.error(f)),
///   ),
/// );
/// ```
abstract class StreamUseCase<T, P> {
  const StreamUseCase();
  StreamResult<T> call(P params);
}

// ════════════════════════════════════════════════════════════════
// Stream — không Input
// ════════════════════════════════════════════════════════════════

/// Stream UseCase không input.
///
/// ```dart
/// class WatchAuthStateUseCase extends StreamUseCaseNoParams<UserModel?> {
///   final AuthRepository _repo;
///   const WatchAuthStateUseCase(this._repo);
///
///   @override
///   StreamResult<UserModel?> call() => _repo.watchAuthState();
/// }
///
/// // Cubit:
/// _subscription = _watchAuthStateUseCase().listen(
///   (result) => result.fold(
///     onSuccess: (user) => emit(
///       user != null ? Authenticated(user) : Unauthenticated(),
///     ),
///     onFailure: (f) => emit(AuthError(f)),
///   ),
/// );
/// ```
abstract class StreamUseCaseNoParams<T> {
  const StreamUseCaseNoParams();
  StreamResult<T> call();
}
