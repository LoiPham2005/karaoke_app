import 'package:dio/dio.dart';
import '../../../base/errors/exceptions.dart';
import '../network_info.dart';

/// 🌐 Interceptor kiểm tra kết nối mạng trước khi request
/// Được thiết kế để thay thế logic checking trong ApiClient
class NetworkCheckInterceptor extends Interceptor {
  final NetworkInfo networkInfo;

  NetworkCheckInterceptor(this.networkInfo);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Kiểm tra kết nối Internet
    if (!await networkInfo.isConnected) {
      // 2. Nếu không có mạng, chặn request và trả về DioException
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const NetworkException(message: 'Không có kết nối mạng'),
          type: DioExceptionType.connectionError,
        ),
      );
    }

    // 3. Nếu có mạng, tiếp tục request
    return handler.next(options);
  }
}
