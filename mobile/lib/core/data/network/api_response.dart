// ════════════════════════════════════════════════════════════════
// 📁 lib/core/network/api_response.dart
// ════════════════════════════════════════════════════════════════

import '../../../core/base/errors/error_handler.dart';
import '../../../core/base/errors/failures.dart';
import '../../../core/base/errors/result.dart';

/// Standard API response wrapper
///
/// Hỗ trợ 2 dạng response phổ biến từ backend:
/// - `{ "success": true, "data": {...} }`
/// - `{ "result": true,  "data": {...} }`
class ApiResponse<T> {
  final bool isSuccess;
  final String? message;
  final T? data;
  final String? error;
  final int? code;
  final int? statusCode;
  final dynamic meta;

  const ApiResponse({
    required this.isSuccess,
    this.message,
    this.data,
    this.error,
    this.code,
    this.statusCode,
    this.meta,
  });

  /// Parse từ JSON — tự detect field `success` hoặc `result`
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    // Hỗ trợ cả "success" lẫn "result" từ các API khác nhau
    final rawSuccess = json['success'] ?? json['result'] ?? false;
    final isSuccess = rawSuccess is bool
        ? rawSuccess
        : rawSuccess.toString().toLowerCase() == 'true';

    return ApiResponse<T>(
      isSuccess: isSuccess,
      message: json['message']?.toString(),
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error']?.toString(),
      code: json['code'] is int ? json['code'] : int.tryParse('${json['code']}'),
      statusCode: json['statusCode'] is int
          ? json['statusCode']
          : int.tryParse('${json['statusCode']}'),
      meta: json['meta'],
    );
  }

  /// Convert thành JSON
  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'success': isSuccess,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'error': error,
      'code': code,
      'statusCode': statusCode,
      'meta': meta,
    };
  }

  /// Tiện ích bóc tách dữ liệu an toàn
  T get unwrappedData {
    if (data == null) {
      throw Exception('Response data is null');
    }
    return data!;
  }
}

// ════════════════════════════════════════════════════════════════
// Extension — convert ApiResponse sang Result
// ════════════════════════════════════════════════════════════════

/// Chuyển `Future<ApiResponse<T>>` → `Future<Result<T>>` để chain Result.
///
/// ```dart
/// await _service.getProducts()
///     .asResult()
///     .thenMap((p) => p.data)
///     .thenFold(
///       onSuccess: (data) => emit(BaseState.success(data: data)),
///       onFailure: (f)    => emit(BaseState.failure(error: f.userMessage)),
///     );
/// ```
extension ApiResponseFutureX<T> on Future<ApiResponse<T>> {
  Future<Result<T>> asResult() async {
    try {
      final r = await this;
      if (r.isSuccess && r.data != null) return Result.success(r.data as T);
      return Result.failure(
        ServerFailure(message: r.message ?? 'Đã có lỗi xảy ra', statusCode: r.statusCode),
      );
    } catch (e, st) {
      return Result.failure(ErrorHandler.toFailure(e, st));
    }
  }
}
