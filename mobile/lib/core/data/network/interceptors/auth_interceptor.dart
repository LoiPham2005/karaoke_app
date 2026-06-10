// ════════════════════════════════════════════════════════════════
// 📁 lib/core/network/interceptors/auth_interceptor.dart
// ════════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_base/core/data/storage/secure/secure_storage_service.dart';
import 'package:flutter_base/core/services/app_auth/app_auth_service.dart';
import 'package:injectable/injectable.dart';

import '../../../base/di/injection.dart';
import '../../../common/constants/api_endpoints.dart';

@LazySingleton()
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  // Dùng lại 1 Dio instance — tránh tạo mới mỗi lần retry
  late final Dio _retryDio = Dio();

  // Cache AppAuthService — lazy init 1 lần, tránh gọi getIt mỗi lần 401
  late final AppAuthService _authService = getIt<AppAuthService>();

  // Queue để tránh race condition khi nhiều request 401 xảy ra cùng lúc
  bool _isRefreshing = false;
  final List<_QueuedRequest> _pendingRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token cho các API public
    if (_isPublicApi(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;

    // Chỉ handle 401 cho các API cần Token
    if (err.response?.statusCode != 401 || _isPublicApi(path)) {
      return handler.next(err);
    }

    Logger.info('Token expired (401) on $path. Refreshing...', tag: 'AUTH');

    // Nếu đang refresh, queue request này lại — tránh gửi nhiều refresh cùng lúc
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(
        _QueuedRequest(requestOptions: err.requestOptions, completer: completer),
      );
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (_) {
        return handler.reject(err);
      }
    }

    _isRefreshing = true;

    try {
      final success = await _authService.refreshToken();

      if (!success) {
        Logger.warning('Refresh failed. Logging out.', tag: 'AUTH');
        _rejectAllPending(err);
        await _authService.logout();
        return handler.reject(err);
      }

      Logger.info('Refresh success. Retrying queued requests.', tag: 'AUTH');

      // Retry request gốc với token mới
      final response = await _retryRequest(err.requestOptions);

      // Resolve tất cả pending requests
      await _resolveAllPending();

      return handler.resolve(response);
    } catch (e) {
      Logger.error('Token refresh error retry sequence', error: e, tag: 'AUTH');
      _rejectAllPending(err);
      await _authService.logout();
      return handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════

  bool _isPublicApi(String path) {
    return ApiEndpoints.publicEndpoints.any((p) => path.contains(p));
  }

  /// Retry 1 request với token mới — dùng lại `_retryDio` thay vì tạo mới
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _secureStorage.getAccessToken();

    // Cập nhật baseUrl + timeout từ request gốc
    _retryDio.options = BaseOptions(
      baseUrl: requestOptions.baseUrl,
      connectTimeout: requestOptions.connectTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
    );

    return _retryDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> _resolveAllPending() async {
    final requests = List<_QueuedRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    for (final request in requests) {
      try {
        final response = await _retryRequest(request.requestOptions);
        request.completer.complete(response);
      } catch (e) {
        request.completer.completeError(e);
      }
    }
  }

  void _rejectAllPending(DioException err) {
    for (final request in _pendingRequests) {
      request.completer.completeError(err);
    }
    _pendingRequests.clear();
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _QueuedRequest({required this.requestOptions, required this.completer});
}
