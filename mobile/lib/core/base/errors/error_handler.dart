// ════════════════════════════════════════════════════════════════
// 📁 lib/core/errors/error_handler.dart
// ════════════════════════════════════════════════════════════════

import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/utils/logger.dart';
import '../../services/crashlytics/crashlytics_service.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  ErrorHandler._();

  // ════════════════════════════════════════════════════════════
  // Main Entry Point
  // ════════════════════════════════════════════════════════════

  /// Convert bất kỳ error nào → Failure + tự động log
  /// Dùng trong BaseCubit.run() và mọi catch block
  static Failure toFailure(Object error, [StackTrace? stackTrace]) {
    _logError(error, stackTrace);

    return switch (error) {
      // Nếu đã là Failure rồi thì pass-through — tránh double-wrap
      Failure() => error,
      DioException() => _fromDio(error),
      AppException() => _fromAppException(error),
      SocketException() => const NetworkFailure(),
      // Strip "Exception:" prefix cho cleaner message
      Exception() => UnknownFailure(message: error.toString().replaceAll('Exception: ', '')),
      _ => UnknownFailure(message: error.toString()),
    };
  }

  // ════════════════════════════════════════════════════════════
  // Logging — tách hoàn toàn khỏi Failure
  // ════════════════════════════════════════════════════════════

  static void _logError(Object error, [StackTrace? stackTrace]) {
    Logger.error('ErrorHandler: ${error.runtimeType}', error: error, stackTrace: stackTrace);

    // Breadcrumb ngắn cho Crashlytics — giới hạn 200 ký tự
    final msg = error.toString();
    CrashlyticsService.instance.log(
      '[ErrorHandler] ${error.runtimeType}: ${msg.length > 200 ? '${msg.substring(0, 200)}...' : msg}',
    );
  }

  // ════════════════════════════════════════════════════════════
  // DioException → Failure
  // ════════════════════════════════════════════════════════════

  static Failure _fromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),

      DioExceptionType.connectionError => const NetworkFailure(),

      DioExceptionType.cancel => CancelledFailure(message: e.message ?? 'Đã hủy'),

      DioExceptionType.badCertificate => const NetworkFailure(
        message: 'Lỗi chứng chỉ bảo mật',
        code: 'SSL_ERROR',
      ),

      DioExceptionType.badResponse => _fromHttpResponse(e.response),

      // unknown + SocketException = mất mạng thực sự
      DioExceptionType.unknown when e.error is SocketException => const NetworkFailure(),

      DioExceptionType.unknown => UnknownFailure(message: e.message ?? 'Lỗi không xác định'),
    };
  }

  // ════════════════════════════════════════════════════════════
  // HTTP Response → Failure
  // ════════════════════════════════════════════════════════════

  static Failure _fromHttpResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Extract tất cả metadata một lần — tránh parse lại nhiều lần
    final message = _extractMessage(data);
    final code = _extractCode(data);
    final requestId = _extractRequestId(data);

    return switch (statusCode) {
      // ── Auth ─────────────────────────────────────────────────
      401 => AuthFailure(
        message: message.ifEmpty('Phiên đăng nhập hết hạn'),
        type: _isTokenExpired(code)
            ? AuthFailureType.tokenExpired
            : AuthFailureType.unauthenticated,
        statusCode: 401,
        code: code,
        requestId: requestId,
      ),
      403 => AuthFailure(
        message: message.ifEmpty('Không có quyền truy cập'),
        type: AuthFailureType.unauthorized,
        statusCode: 403,
        code: code,
        requestId: requestId,
      ),

      // ── Data ─────────────────────────────────────────────────
      400 || 422 => DataFailure(
        message: message.ifEmpty('Dữ liệu không hợp lệ'),
        type: DataFailureType.validation,
        // Handle cả Map {"email": "..."} lẫn List NestJS format
        fieldErrors: _extractFieldErrors(data),
        globalErrors: _extractGlobalErrors(data),
        statusCode: statusCode,
        code: code,
      ),
      404 => DataFailure(
        message: message.ifEmpty('Không tìm thấy'),
        type: DataFailureType.notFound,
        statusCode: 404,
        code: code,
      ),
      409 => DataFailure(
        message: message.ifEmpty('Dữ liệu đã tồn tại'),
        type: DataFailureType.conflict,
        statusCode: 409,
        code: code,
      ),
      413 => DataFailure(
        message: message.ifEmpty('Dữ liệu quá lớn'),
        type: DataFailureType.payloadTooLarge,
        maxSize: _extractInt(data, ['maxSize', 'maxFileSize']),
        statusCode: 413,
        code: code,
      ),

      // ── Server ───────────────────────────────────────────────
      429 => ServerFailure(
        message: message.ifEmpty('Quá nhiều yêu cầu, vui lòng thử lại sau'),
        retryAfter: _extractRetryAfter(response),
        statusCode: 429,
        code: code,
        requestId: requestId,
      ),
      500 || 502 || 504 => ServerFailure(
        message: 'Lỗi máy chủ, vui lòng thử lại',
        statusCode: statusCode,
        code: code,
        requestId: requestId,
      ),
      503 when _isMaintenance(code) => ServerFailure(
        message: message.ifEmpty('Hệ thống đang bảo trì'),
        maintenanceEndTime: _extractDateTime(data, ['estimatedEndTime', 'endTime']),
        statusCode: 503,
        code: code,
        requestId: requestId,
      ),
      503 => ServerFailure(
        message: 'Dịch vụ tạm thời không khả dụng',
        statusCode: 503,
        code: code,
        requestId: requestId,
      ),

      _ => ServerFailure(
        message: message.ifEmpty('Đã xảy ra lỗi'),
        statusCode: statusCode,
        code: code,
        requestId: requestId,
      ),
    };
  }

  // ════════════════════════════════════════════════════════════
  // AppException → Failure
  // ════════════════════════════════════════════════════════════

  static Failure _fromAppException(AppException e) {
    return switch (e) {
      NetworkException() => NetworkFailure(message: e.message, code: e.code),
      TimeoutException() => TimeoutFailure(message: e.message, code: e.code),
      ServerException() => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
        requestId: e.requestId,
      ),
      AuthException() => AuthFailure(
        message: e.message,
        type: _mapAuthType(e.type),
        statusCode: e.statusCode,
        code: e.code,
        requestId: e.requestId,
      ),
      DataException() => DataFailure(
        message: e.message,
        type: _mapDataType(e.type),
        fieldErrors: e.fieldErrors,
        statusCode: e.statusCode,
        code: e.code,
      ),
      StorageException() => StorageFailure(
        message: e.message,
        type: _mapStorageType(e.type),
        code: e.code,
      ),
      _ => UnknownFailure(message: e.message, code: e.code),
    };
  }

  // ════════════════════════════════════════════════════════════
  // Extractors — parse response body an toàn
  // ════════════════════════════════════════════════════════════

  static String _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return data is String ? data : '';
    // NestJS ValidationPipe trả List, các error khác trả String
    final msg = data['message'];
    if (msg is List && msg.isNotEmpty) return msg.first.toString();
    return msg?.toString() ?? data['msg']?.toString() ?? '';
  }

  static String? _extractCode(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    // 'code'/'errorCode' = custom code, 'error' = NestJS default exception name
    return data['code']?.toString() ?? data['errorCode']?.toString() ?? data['error']?.toString();
  }

  static String? _extractRequestId(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    return data['requestId']?.toString() ?? data['traceId']?.toString();
  }

  /// Handle 2 format NestJS phổ biến:
  /// - Map: `{"email": "Email không hợp lệ"}`
  /// - List: `[{"field": "email", "message": "Email không hợp lệ"}]`
  static Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final errors = data['errors'] ?? data['fieldErrors'];

    if (errors is Map<String, dynamic>) {
      return errors.map((k, v) => MapEntry(k, v is List ? v.first.toString() : v.toString()));
    }

    if (errors is List) {
      final result = <String, String>{};
      for (final item in errors) {
        if (item is Map<String, dynamic> && item.containsKey('field')) {
          result.putIfAbsent(
            item['field'].toString(),
            () => item['message']?.toString() ?? 'Lỗi không xác định',
          );
        }
      }
      return result.isNotEmpty ? result : null;
    }

    return null;
  }

  static List<String>? _extractGlobalErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final errors = data['globalErrors'];
    return errors is List ? errors.map((e) => e.toString()).toList() : null;
  }

  static int? _extractInt(dynamic data, List<String> keys) {
    if (data is! Map<String, dynamic>) return null;
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  static DateTime? _extractDateTime(dynamic data, List<String> keys) {
    if (data is! Map<String, dynamic>) return null;
    for (final key in keys) {
      final value = data[key];
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static Duration? _extractRetryAfter(Response? response) {
    final header = response?.headers.value('retry-after');
    if (header == null) return null;
    final seconds = int.tryParse(header);
    return seconds != null ? Duration(seconds: seconds) : null;
  }

  // ════════════════════════════════════════════════════════════
  // Condition Checks — nhận String? thay vì dynamic
  // ════════════════════════════════════════════════════════════

  static bool _isTokenExpired(String? code) {
    if (code == null) return false;
    final c = code.toLowerCase();
    return c.contains('token_expired') ||
        c.contains('jwt_expired') ||
        // NestJS UnauthorizedException default
        c.contains('unauthorizedexception');
  }

  static bool _isMaintenance(String? code) {
    if (code == null) return false;
    return code.toLowerCase().contains('maintenance');
  }

  // ════════════════════════════════════════════════════════════
  // Type Mappers
  // ════════════════════════════════════════════════════════════

  static AuthFailureType _mapAuthType(AuthExceptionType t) => switch (t) {
    AuthExceptionType.unauthenticated => AuthFailureType.unauthenticated,
    AuthExceptionType.unauthorized => AuthFailureType.unauthorized,
    AuthExceptionType.tokenExpired => AuthFailureType.tokenExpired,
    AuthExceptionType.refreshFailed => AuthFailureType.refreshFailed,
  };

  static DataFailureType _mapDataType(DataExceptionType t) => switch (t) {
    DataExceptionType.notFound => DataFailureType.notFound,
    DataExceptionType.validation => DataFailureType.validation,
    DataExceptionType.conflict => DataFailureType.conflict,
    DataExceptionType.payloadTooLarge => DataFailureType.payloadTooLarge,
    DataExceptionType.unknown => DataFailureType.unknown,
  };

  static StorageFailureType _mapStorageType(StorageExceptionType t) => switch (t) {
    StorageExceptionType.cache => StorageFailureType.cacheNotFound,
    StorageExceptionType.database => StorageFailureType.databaseError,
    StorageExceptionType.file => StorageFailureType.fileNotFound,
    StorageExceptionType.unknown => StorageFailureType.unknown,
  };

  // ════════════════════════════════════════════════════════════
  // Quick Checks — dùng trong interceptor / retry logic
  // ════════════════════════════════════════════════════════════

  static bool isNetworkError(Object e) =>
      e is NetworkException ||
      e is NetworkFailure ||
      e is SocketException ||
      (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout));

  static bool isAuthError(Object e) =>
      e is AuthException ||
      e is AuthFailure ||
      (e is DioException && [401, 403].contains(e.response?.statusCode));

  static bool isRetryable(Object e) {
    if (e is Failure) return e.isRetryable;
    return isNetworkError(e) || (e is DioException && (e.response?.statusCode ?? 0) >= 500);
  }
}

// ════════════════════════════════════════════════════════════
// Internal String Extension
// ════════════════════════════════════════════════════════════

extension _StringX on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
