import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version_check_response.freezed.dart';
part 'app_version_check_response.g.dart';

/// Response của public endpoint `GET /app-version/check`.
///
/// Backend KHÔNG bọc trong `ApiResponse<T>` — trả object thẳng (raw DTO).
/// JSON keys là camelCase, khớp tên field nên KHÔNG cần `@JsonKey`.
///
/// `status` là 1 trong: `"up_to_date" | "optional" | "force"`. Service map sang
/// [UpdateStatus]; bất kỳ giá trị lạ nào → `error` (fail-open, không chặn user).
@freezed
abstract class AppVersionCheckResponse with _$AppVersionCheckResponse {
  const factory AppVersionCheckResponse({
    required String status,
    @Default('') String currentVersion,
    @Default('') String latestVersion,
    @Default(false) bool forceUpdate,
    String? message,
    String? storeUrl,
  }) = _AppVersionCheckResponse;

  factory AppVersionCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$AppVersionCheckResponseFromJson(json);
}
