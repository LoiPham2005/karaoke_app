// 📁 lib/core/data/network/interceptors/smart_cache_interceptor.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../cache/cache_service.dart';
import '../../cache/cache_strategy.dart';

/// 🧠 Smart cache interceptor - Tự động hóa chiến lược cache cho các requests.
/// Sử dụng [CacheService] để lưu trữ dữ liệu.
@LazySingleton()
class SmartCacheInterceptor extends Interceptor {
  final CacheService _cache;

  SmartCacheInterceptor(this._cache);

  /// Định nghĩa chiến lược cache cho từng endpoint.
  static const _strategies = <String, CacheStrategy>{
    // 🚫 No Cache - Auth & Payments
    '/auth/login': CacheStrategy.noCache,
    '/auth/logout': CacheStrategy.noCache,
    '/auth/refresh': CacheStrategy.noCache,
    '/payment': CacheStrategy.noCache,
    '/orders/create': CacheStrategy.noCache,

    // ⚡ Short-term (5 min) - Dữ liệu thay đổi thường xuyên
    '/products/search': CacheStrategy.shortTerm,
    '/notifications': CacheStrategy.shortTerm,

    // ⏱️ Medium-term (1 hour) - Dữ liệu ổn định
    '/products': CacheStrategy.mediumTerm,
    '/user/profile': CacheStrategy.mediumTerm,
    '/venues': CacheStrategy.mediumTerm,

    // 📅 Long-term (1 day) - Dữ liệu ít thay đổi
    '/categories': CacheStrategy.longTerm,
    '/config/app': CacheStrategy.longTerm,

    // ♾️ Permanent - Dữ liệu tĩnh
    '/config/countries': CacheStrategy.permanent,
    '/config/languages': CacheStrategy.permanent,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Chỉ cache method GET
    if (options.method != 'GET') return handler.next(options);

    final strategy = _resolveStrategy(options);
    if (strategy == CacheStrategy.noCache) return handler.next(options);

    final key = _generateKey(options);

    // Xử lý Force Refresh (nếu có)
    final forceRefresh = options.extra['force_refresh'] == true;
    if (forceRefresh) {
      options.extra['cache_key'] = key; // Lưu key để onResponse có thể lưu lại
      return handler.next(options);
    }

    // Kiểm tra cache
    final cachedData = await _cache.getJson(key);
    if (cachedData != null) {
      return handler.resolve(
        Response(requestOptions: options, data: cachedData, statusCode: 200),
      );
    }

    // Lưu key vào extra để onResponse sử dụng
    options.extra['cache_key'] = key;
    options.extra['cache_ttl'] = strategy.ttl;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = response.requestOptions.extra['cache_key'] as String?;
    final ttl = response.requestOptions.extra['cache_ttl'] as Duration?;

    if (key != null && response.statusCode == 200) {
      _cache.setJson(key, response.data, ttl: ttl);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Fallback sang cache nếu lỗi network
    if (_isNetworkError(err)) {
      final key = _generateKey(err.requestOptions);
      final cachedData = await _cache.getJson(key);
      if (cachedData != null) {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: cachedData,
            statusCode: 200,
          ),
        );
      }
    }
    handler.next(err);
  }

  // ── Helpers ──────────────────────────────────────────────────

  CacheStrategy _resolveStrategy(RequestOptions options) {
    final custom = options.extra['cache_strategy'] as CacheStrategy?;
    if (custom != null) return custom;

    final path = options.path;
    // Tìm khớp chính xác
    if (_strategies.containsKey(path)) return _strategies[path]!;

    // Tìm khớp theo prefix
    for (final entry in _strategies.entries) {
      if (path.startsWith(entry.key)) return entry.value;
    }

    return CacheStrategy.noCache;
  }

  String _generateKey(RequestOptions options) {
    final buffer = StringBuffer(options.path);
    if (options.queryParameters.isNotEmpty) {
      buffer.write('?');
      // Sort query params để đảm bảo key đồng nhất
      final sortedKeys = options.queryParameters.keys.toList()..sort();
      buffer.write(
        sortedKeys.map((k) => '$k=${options.queryParameters[k]}').join('&'),
      );
    }
    return 'http_cache_${buffer.toString()}';
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;
  }

  // ── Static Helper Methods cho ApiClient ──────────────────────

  static Options withStrategy(CacheStrategy strategy) =>
      Options(extra: {'cache_strategy': strategy});

  static Options forceRefresh() => Options(extra: {'force_refresh': true});
}
