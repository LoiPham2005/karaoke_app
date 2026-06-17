import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_ref_request.freezed.dart';
part 'song_ref_request.g.dart';

/// Body cho `POST /favorites`.
///
/// Quy tắc vàng: KHÔNG dùng `Map<String, dynamic>` cho request body — luôn dùng
/// `@freezed` Request class có `toJson`.
@freezed
abstract class SongRefRequest with _$SongRefRequest {
  const factory SongRefRequest({
    required String youtubeId,
    required String title,
    String? artist,
    String? thumbnailUrl,
    int? duration,
  }) = _SongRefRequest;

  factory SongRefRequest.fromJson(Map<String, dynamic> json) =>
      _$SongRefRequestFromJson(json);
}
