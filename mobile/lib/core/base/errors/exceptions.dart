// ════════════════════════════════════════════════════════════════
// 📁 lib/core/errors/exceptions.dart
// ════════════════════════════════════════════════════════════════

/// Base exception — giữ raw error + stackTrace để ErrorHandler log đầy đủ
/// KHÔNG dùng const vì originalError là dynamic (runtime value)
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final String? requestId;
  final Object? originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extras;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.requestId,
    this.originalError,
    this.stackTrace,
    this.extras,
  });

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

// ════════════════════════════════════════════════════════════════
// Network
// ════════════════════════════════════════════════════════════════

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Không có kết nối mạng',
    super.code = 'NETWORK_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

class TimeoutException extends AppException {
  final Duration? timeout;

  const TimeoutException({
    super.message = 'Hết thời gian chờ',
    super.code = 'TIMEOUT',
    this.timeout,
    super.originalError,
    super.stackTrace,
  });
}

// ════════════════════════════════════════════════════════════════
// Server
// ════════════════════════════════════════════════════════════════

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.statusCode,
    super.requestId,
    super.originalError,
    super.stackTrace,
    super.extras,
  });
}

// ════════════════════════════════════════════════════════════════
// Auth
// ════════════════════════════════════════════════════════════════

class AuthException extends AppException {
  final AuthExceptionType type;

  const AuthException({
    required super.message,
    this.type = AuthExceptionType.unauthenticated,
    super.code,
    super.statusCode,
    super.requestId,
    super.originalError,
    super.stackTrace,
  });
}

enum AuthExceptionType {
  unauthenticated, // 401
  unauthorized, // 403
  tokenExpired,
  refreshFailed,
}

// ════════════════════════════════════════════════════════════════
// Data
// ════════════════════════════════════════════════════════════════

class DataException extends AppException {
  final DataExceptionType type;
  final Map<String, String>? fieldErrors;

  const DataException({
    required super.message,
    this.type = DataExceptionType.unknown,
    this.fieldErrors,
    super.code,
    super.statusCode,
    super.requestId,
    super.originalError,
    super.stackTrace,
  });
}

enum DataExceptionType {
  notFound, // 404
  validation, // 400, 422
  conflict, // 409
  payloadTooLarge, // 413
  unknown,
}

// ════════════════════════════════════════════════════════════════
// Storage
// ════════════════════════════════════════════════════════════════

class StorageException extends AppException {
  final StorageExceptionType type;

  const StorageException({
    super.message = 'Lỗi lưu trữ',
    this.type = StorageExceptionType.unknown,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

enum StorageExceptionType { cache, database, file, unknown }

// Convenience subclass — throw CacheException() thay vì StorageException(type: cache)
class CacheException extends StorageException {
  const CacheException({
    super.message = 'Không tìm thấy cache',
    super.originalError,
    super.stackTrace,
  }) : super(type: StorageExceptionType.cache, code: 'CACHE_MISS');
}
