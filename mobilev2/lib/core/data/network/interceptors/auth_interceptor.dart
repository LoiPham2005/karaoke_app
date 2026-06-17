import 'package:dio/dio.dart';
import 'package:karaoke/config/app/flavor_config.dart';
import 'package:karaoke/core/base/di/global_providers.dart';
import 'package:karaoke/core/data/storage/secure_storage_service.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';

/// Gắn Bearer access token vào mọi request; khi gặp 401 thì tự động dùng
/// refresh token gọi `POST /auth/refresh` để lấy token mới rồi retry request.
///
/// Refresh thất bại (refresh token hết hạn/không hợp lệ) → đăng xuất phiên
/// (xoá token + set `appAuthProvider` về chưa đăng nhập) để UI điều hướng login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final SecureStorageService _secureStorage;

  // Khoá dedupe: nhiều request 401 cùng lúc → chỉ refresh 1 lần, các request
  // khác cùng await chung future này.
  static Future<bool>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(_tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Chỉ xử lý 401, và KHÔNG đụng vào chính các endpoint auth (login/register/
    // refresh) — 401 ở đó là sai mật khẩu/refresh hỏng, không phải access hết hạn.
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions)) {
      final refreshed = await _refresh();
      if (refreshed) {
        try {
          final retryResponse = await _retryRequest(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // retry vẫn lỗi → coi như phiên hỏng, rơi xuống logout bên dưới.
        }
      }
      await _logout();
    }
    handler.next(err);
  }

  bool _isAuthEndpoint(RequestOptions o) {
    final p = o.path;
    return p.contains('/auth/login') ||
        p.contains('/auth/register') ||
        p.contains('/auth/refresh');
  }

  /// Dedupe: trả về future refresh đang chạy nếu có, không thì khởi tạo mới.
  Future<bool> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final rt = await _secureStorage.read(_refreshTokenKey);
    if (rt == null || rt.isEmpty) return false;
    try {
      // Dio "trần" (không gắn AuthInterceptor) để tránh vòng lặp 401.
      final dio = Dio(
        BaseOptions(
          baseUrl: FlavorConfig.current.apiBaseUrl,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': rt},
      );
      // Backend bọc response: { success, data: { accessToken, refreshToken } }.
      final data = res.data?['data'] as Map<String, dynamic>?;
      final access = data?['accessToken'] as String?;
      final newRt = data?['refreshToken'] as String?;
      if (access == null || access.isEmpty || newRt == null || newRt.isEmpty) {
        return false;
      }
      await _secureStorage.write(_tokenKey, access);
      await _secureStorage.write(_refreshTokenKey, newRt);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final newToken = await _secureStorage.read(_tokenKey);
    options.headers['Authorization'] = 'Bearer $newToken';
    // Dio trần để không kích hoạt lại AuthInterceptor; options đã có baseUrl/path.
    final dio = Dio();
    return dio.fetch<dynamic>(options);
  }

  /// Phiên hết hạn → xoá token + cập nhật appAuthProvider (UI sẽ về login).
  Future<void> _logout() async {
    await _secureStorage.delete(_tokenKey);
    await _secureStorage.delete(_refreshTokenKey);
    try {
      await globalContainer.read(appAuthProvider.notifier).logout();
    } catch (_) {
      // container chưa sẵn sàng → đã xoá token là đủ cho lần mở app sau.
    }
  }
}
