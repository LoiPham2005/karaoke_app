import 'package:dio/dio.dart';
import 'package:karaoke/core/services/app_version/data/app_version_check_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_version_api.g.dart';

/// Retrofit client cho public endpoint kiểm tra version.
///
/// Base URL của Dio đã bao gồm `/api/v1` nên path ở đây là `/app-version/check`.
/// Endpoint NO AUTH (backend `@Public()`) — trả [AppVersionCheckResponse] raw
/// (KHÔNG bọc `ApiResponse<T>`).
@RestApi()
abstract class AppVersionApi {
  factory AppVersionApi(Dio dio) = _AppVersionApi;

  /// `GET /app-version/check?platform=&version=&build=`
  /// - [platform]: `android` | `ios` (case-insensitive ở backend).
  /// - [version]: semver hiện tại của app.
  /// - [build]: build number (int dạng string), optional.
  @GET('/app-version/check')
  Future<AppVersionCheckResponse> checkVersion(
    @Query('platform') String platform,
    @Query('version') String version,
    @Query('build') String build,
  );
}
