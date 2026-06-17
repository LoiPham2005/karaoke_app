import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/base/errors/failures.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/core/data/storage/secure_storage_service.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/features/auth/data/models/auth_request.dart';
import 'package:karaoke/features/auth/data/models/auth_response_model.dart';
import 'package:karaoke/features/auth/data/models/auth_user_model.dart';
import 'package:karaoke/features/auth/data/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

/// Riverpod notifier cho AUTH. State = `UserModel?` (null = chưa đăng nhập).
///
/// Sau khi login/register API thành công:
///  1. Lưu access token qua `appAuthProvider.notifier.login(accessToken)`
///     (set `isAuthenticated = true` + ghi vào key `access_token`).
///  2. Lưu refresh token vào ĐÚNG key `refresh_token` mà `AuthInterceptor` đọc.
///  3. Set state = user.
@riverpod
class AuthNotifier extends _$AuthNotifier with BaseNotifier<UserModel?> {
  /// Key refresh token — phải khớp `AuthInterceptor._refreshTokenKey`.
  static const _refreshTokenKey = 'refresh_token';

  late AuthService _service;

  @override
  Future<UserModel?> build() async {
    _service = AuthService(ref.read(dioProvider));
    return null;
  }

  /// Đăng nhập bằng email/password.
  Future<void> login({required String email, required String password}) =>
      runAsync(
        action: () => _authenticate(
          () => _service.login(LoginRequest(email: email, password: password)),
        ),
        successMessage: 'Đăng nhập thành công',
      );

  /// Đăng ký tài khoản mới rồi tự đăng nhập luôn.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) => runAsync(
    action: () => _authenticate(
      () => _service.register(
        RegisterRequest(
          email: email,
          password: password,
          displayName: displayName,
        ),
      ),
    ),
    successMessage: 'Tạo tài khoản thành công',
  );

  /// Đăng xuất: clear access (AppAuth) + refresh token, reset state.
  Future<void> logout() async {
    final storage = getIt<SecureStorageService>();
    final refreshToken = await storage.read(_refreshTokenKey);

    // Best-effort gọi API logout — bỏ qua lỗi mạng để vẫn logout local được.
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _service.logout(RefreshTokenRequest(refreshToken: refreshToken));
      } catch (_) {}
    }

    // AppAuthNotifier.logout() gọi storage.clear() (xoá cả access lẫn refresh),
    // nhưng xoá tường minh refresh key để an toàn nếu logic clear thay đổi.
    await ref.read(appAuthProvider.notifier).logout();
    await storage.delete(_refreshTokenKey);
    if (!ref.mounted) return;
    state = const AsyncValue<UserModel?>.data(null);
  }

  /// Gọi API auth, unwrap `ApiResponse`, lưu token, trả về [UserModel].
  Future<UserModel> _authenticate(
    Future<ApiResponse<AuthResponseModel>> Function() action,
  ) async {
    final response = await action();
    if (!response.isSuccess || response.data == null) {
      throw ServerFailure(response.message ?? 'Đăng nhập thất bại');
    }
    final auth = response.data!;

    // 1. access token + isAuthenticated.
    await ref.read(appAuthProvider.notifier).login(auth.accessToken);
    // 2. refresh token vào đúng key interceptor dùng.
    await getIt<SecureStorageService>().write(
      _refreshTokenKey,
      auth.refreshToken,
    );

    return auth.user;
  }
}
