import 'package:dio/dio.dart';
import 'package:karaoke/core/data/network/api_response.dart';
import 'package:karaoke/features/auth/data/models/auth_request.dart';
import 'package:karaoke/features/auth/data/models/auth_response_model.dart';
import 'package:karaoke/features/auth/data/models/auth_user_model.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_service.g.dart';

/// Retrofit service cho AUTH.
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/auth/login`, ...
/// Response backend bọc `{ statusCode, message, data }` → map sang
/// `ApiResponse<T>` (field `data`, `message`, `success`).
@RestApi()
abstract class AuthService {
  factory AuthService(Dio dio) = _AuthService;

  /// `POST /auth/login` → `data { user, accessToken, refreshToken }`.
  @POST('/auth/login')
  Future<ApiResponse<AuthResponseModel>> login(@Body() LoginRequest body);

  /// `POST /auth/register` → `data { user, accessToken, refreshToken }`.
  @POST('/auth/register')
  Future<ApiResponse<AuthResponseModel>> register(@Body() RegisterRequest body);

  /// `POST /auth/refresh` → `data { user, accessToken, refreshToken }`.
  @POST('/auth/refresh')
  Future<ApiResponse<AuthResponseModel>> refresh(
    @Body() RefreshTokenRequest body,
  );

  /// `GET /users/me` (Bearer access) → `data user`.
  @GET('/users/me')
  Future<ApiResponse<UserModel>> me();

  /// `POST /auth/logout` → `data { success }`.
  @POST('/auth/logout')
  Future<ApiResponse<dynamic>> logout(@Body() RefreshTokenRequest body);
}
