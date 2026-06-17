import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_add_request.freezed.dart';
part 'history_add_request.g.dart';

/// Body cho `POST /history` → `{ SongRef..., secondsPlayed? }`.
///
/// Khác [SongRefRequest] ở chỗ có thêm `secondsPlayed`, nên dùng request riêng
/// (vẫn tuân quy tắc vàng: không dùng `Map` cho body).
@freezed
abstract class HistoryAddRequest with _$HistoryAddRequest {
  const factory HistoryAddRequest({
    required String youtubeId,
    required String title,
    String? artist,
    String? thumbnailUrl,
    int? duration,
    int? secondsPlayed,
  }) = _HistoryAddRequest;

  factory HistoryAddRequest.fromJson(Map<String, dynamic> json) =>
      _$HistoryAddRequestFromJson(json);
}
