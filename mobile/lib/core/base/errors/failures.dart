// ════════════════════════════════════════════════════════════════
// 📁 lib/core/errors/failures.dart
// ════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

/// Base Failure — CHỈ chứa thông tin cần thiết cho UI + pattern matching
/// Logging/StackTrace được xử lý riêng trong ErrorHandler
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final int? statusCode;

  const Failure({required this.message, this.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String toString() => message;
}

// ════════════════════════════════════════════════════════════════
// Network Failures
// ════════════════════════════════════════════════════════════════

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Không có kết nối mạng', super.code = 'NETWORK_ERROR'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Yêu cầu đã hết thời gian', super.code = 'TIMEOUT'});
}

class CancelledFailure extends Failure {
  const CancelledFailure({super.message = 'Yêu cầu đã bị hủy', super.code = 'CANCELLED'});
}

// ════════════════════════════════════════════════════════════════
// Server Failures
// ════════════════════════════════════════════════════════════════

class ServerFailure extends Failure {
  final DateTime? maintenanceEndTime;
  final Duration? retryAfter;
  // requestId giữ lại ở ServerFailure và AuthFailure vì:
  // - ServerFailure: cần trace khi báo lỗi cho user ("Mã lỗi: xxx")
  // - AuthFailure: cần trace token refresh flow
  final String? requestId;

  const ServerFailure({
    super.message = 'Lỗi máy chủ',
    super.code,
    super.statusCode,
    this.maintenanceEndTime,
    this.retryAfter,
    this.requestId,
  });

  bool get isMaintenance => maintenanceEndTime != null;
  bool get isRateLimited => retryAfter != null;

  @override
  List<Object?> get props => [...super.props, maintenanceEndTime, retryAfter, requestId];
}

// ════════════════════════════════════════════════════════════════
// Auth Failures
// ════════════════════════════════════════════════════════════════

class AuthFailure extends Failure {
  final AuthFailureType type;
  final String? requestId;

  const AuthFailure({
    required super.message,
    this.type = AuthFailureType.unauthenticated,
    super.code,
    super.statusCode,
    this.requestId,
  });

  /// true = cần redirect về Login screen
  /// false (unauthorized/403) = chỉ show error, không logout
  bool get needsReLogin => type != AuthFailureType.unauthorized;

  @override
  List<Object?> get props => [...super.props, type, requestId];
}

enum AuthFailureType {
  unauthenticated, // 401
  unauthorized, // 403
  tokenExpired,
  refreshFailed,
}

// ════════════════════════════════════════════════════════════════
// Data Failures
// ════════════════════════════════════════════════════════════════

class DataFailure extends Failure {
  final DataFailureType type;
  final Map<String, String>? fieldErrors; // {"email": "Email không hợp lệ"}
  final List<String>? globalErrors; // ["Sân đã được đặt trong khung giờ này"]
  final int? maxSize; // dùng cho 413

  const DataFailure({
    required super.message,
    this.type = DataFailureType.unknown,
    this.fieldErrors,
    this.globalErrors,
    this.maxSize,
    super.code,
    super.statusCode,
  });

  /// Lấy lỗi đầu tiên theo thứ tự ưu tiên: field → global → message
  String get firstError {
    if (fieldErrors?.isNotEmpty == true) return fieldErrors!.values.first;
    if (globalErrors?.isNotEmpty == true) return globalErrors!.first;
    return message;
  }

  /// Lấy lỗi của một field cụ thể — dùng trong Form validation
  String? fieldError(String field) => fieldErrors?[field];

  @override
  List<Object?> get props => [...super.props, type, fieldErrors, globalErrors, maxSize];
}

enum DataFailureType {
  notFound, // 404
  validation, // 400, 422
  conflict, // 409
  payloadTooLarge, // 413
  unknown,
}

// ════════════════════════════════════════════════════════════════
// Storage Failures
// ════════════════════════════════════════════════════════════════

class StorageFailure extends Failure {
  final StorageFailureType type;

  const StorageFailure({
    super.message = 'Lỗi lưu trữ',
    this.type = StorageFailureType.unknown,
    super.code,
  });

  @override
  List<Object?> get props => [...super.props, type];
}

enum StorageFailureType { cacheNotFound, databaseError, fileNotFound, unknown }

// ════════════════════════════════════════════════════════════════
// Unknown Failure
// ════════════════════════════════════════════════════════════════

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Đã xảy ra lỗi không xác định', super.code = 'UNKNOWN'});
}

// ════════════════════════════════════════════════════════════════
// FailureX Extension
// ════════════════════════════════════════════════════════════════

extension FailureX on Failure {
  // ── Type checks ──────────────────────────────────────────────
  bool get isNetwork => this is NetworkFailure || this is TimeoutFailure;
  bool get isAuth => this is AuthFailure;
  bool get isServer => this is ServerFailure;
  bool get isData => this is DataFailure;
  bool get isCancelled => this is CancelledFailure;
  bool get isStorage => this is StorageFailure;
  bool get isValidation =>
      this is DataFailure && (this as DataFailure).type == DataFailureType.validation;
  bool get isNotFound =>
      this is DataFailure && (this as DataFailure).type == DataFailureType.notFound;

  // ── Behavior ─────────────────────────────────────────────────
  bool get isRetryable => switch (this) {
    NetworkFailure() || TimeoutFailure() => true,
    ServerFailure(:final isRateLimited, :final statusCode) =>
      isRateLimited || (statusCode ?? 0) >= 500,
    _ => false,
  };

  bool get needsReLogin => switch (this) {
    AuthFailure(:final needsReLogin) => needsReLogin,
    _ => false,
  };

  Duration? get retryDelay => switch (this) {
    ServerFailure(:final retryAfter) => retryAfter,
    NetworkFailure() || TimeoutFailure() => const Duration(seconds: 3),
    _ => null,
  };

  // ── UI Helpers ────────────────────────────────────────────────

  /// Message đã được chuẩn hóa cho user — dùng trực tiếp trong UI
  String get userMessage => switch (this) {
    NetworkFailure() || TimeoutFailure() => 'Vui lòng kiểm tra kết nối mạng',
    CancelledFailure() => message,
    AuthFailure(needsReLogin: true) => 'Vui lòng đăng nhập lại',
    AuthFailure() => 'Bạn không có quyền thực hiện thao tác này',
    ServerFailure(isMaintenance: true) => 'Hệ thống đang bảo trì, vui lòng thử lại sau',
    ServerFailure(isRateLimited: true) => 'Quá nhiều yêu cầu, vui lòng thử lại sau',
    DataFailure(type: DataFailureType.validation, :final firstError) => firstError,
    DataFailure(type: DataFailureType.notFound) => 'Không tìm thấy dữ liệu',
    DataFailure(type: DataFailureType.conflict) => message,
    _ => message,
  };

  /// Hành động gợi ý — dùng để quyết định UI response
  FailureAction get action => switch (this) {
    AuthFailure(needsReLogin: true) => FailureAction.reLogin,
    CancelledFailure() => FailureAction.none,
    DataFailure(type: DataFailureType.validation) => FailureAction.fixInput,
    _ when isRetryable => FailureAction.retry,
    _ => FailureAction.showError,
  };

  /// Debug string — dùng trong Logger, KHÔNG hiển thị cho user
  String get debugInfo {
    final sb = StringBuffer()
      ..writeln('$runtimeType')
      ..writeln('  message   : $message')
      ..writeln('  code      : ${code ?? '-'}')
      ..writeln('  statusCode: ${statusCode ?? '-'}');
    if (this is ServerFailure) {
      sb.writeln('  requestId : ${(this as ServerFailure).requestId ?? '-'}');
    }
    if (this is AuthFailure) sb.writeln('  requestId : ${(this as AuthFailure).requestId ?? '-'}');
    if (this is DataFailure) {
      final df = this as DataFailure;
      if (df.fieldErrors != null) sb.writeln('  fields    : ${df.fieldErrors}');
      if (df.globalErrors != null) sb.writeln('  globals   : ${df.globalErrors}');
    }
    return sb.toString();
  }
}

enum FailureAction { showError, retry, reLogin, fixInput, none }
