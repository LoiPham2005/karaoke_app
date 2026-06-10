import 'dart:async';
import 'package:dio/dio.dart';

import '../../../base/errors/exceptions.dart';

/// 🔄 Interceptor tự động retry khi gặp lỗi mạng/timeout hoặc 5xx
/// Được thiết kế để thay thế retry logic trong ApiClient
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final Duration? retryDelay;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelay,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 1. Kiểm tra request đã được đánh dấu không retry hoặc hết lượt retry chưa
    var attempt = err.requestOptions.extra['retry_attempt'] ?? 0;

    // 2. Kiểm tra xem lỗi có nằm trong danh sách được phép retry không
    // Tránh retry nếu đó là lỗi từ NetworkCheckInterceptor (không có mạng)
    if (attempt < retries && _isRetryable(err) && err.error is! NetworkException) {
      attempt++;
      err.requestOptions.extra['retry_attempt'] = attempt;

      // 3. Tính toán delay trước khi retry (Exponential Backoff hoặc cố định)
      final delay = retryDelay ?? Duration(seconds: attempt * 2);
      await Future.delayed(delay);

      try {
        // 4. Gửi lại request cũ
        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: err.requestOptions.extra,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
          ),
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          cancelToken: err.requestOptions.cancelToken,
        );

        // 5. Nếu retry thành công, resolve request
        return handler.resolve(response);
      } on DioException catch (e) {
        // 6. Nếu retry thất bại bọc trong DioException, tiếp tục chuỗi onError
        return super.onError(e, handler);
      } catch (e) {
        // 7. Lỗi không xác định khác
        return super.onError(err, handler);
      }
    }

    // 8. Không retry được thì tiếp tục lỗi sang interceptor tiếp theo
    return super.onError(err, handler);
  }

  /// ✅ Logic xác định lỗi có thể retry (mạng kém, server 5xx, ...)
  bool _isRetryable(DioException e) {
    // Không retry nếu là lỗi NetworkException (đã được xử lý bởi NetworkCheckInterceptor)
    if (e.error is NetworkException) {
      return false;
    }

    return switch (e.type) {
      // Các lỗi do đường truyền kém, timeout thì nên retry
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,

      // Lỗi do phản hồi từ server nhưng là 5xx thì nên retry
      DioExceptionType.badResponse =>
        e.response?.statusCode != null && e.response!.statusCode! >= 500,

      // Các lỗi khác (4xx, Cancel,...) không nên retry
      _ => false,
    };
  }
}
