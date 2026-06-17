import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics_response.freezed.dart';
part 'lyrics_response.g.dart';

/// Payload `data` của `GET /lyrics`.
///
/// `lrcContent` null/empty → bài chưa có lời ("đang cập nhật").
/// JSON keys camelCase khớp backend nên KHÔNG cần `@JsonKey`.
@freezed
abstract class LyricsResponse with _$LyricsResponse {
  const factory LyricsResponse({
    String? lrcContent,
    String? source,
    String? language,
  }) = _LyricsResponse;

  factory LyricsResponse.fromJson(Map<String, dynamic> json) =>
      _$LyricsResponseFromJson(json);
}
