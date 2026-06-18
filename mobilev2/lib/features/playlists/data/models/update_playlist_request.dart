import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_playlist_request.freezed.dart';
part 'update_playlist_request.g.dart';

/// Body cho `PATCH /playlists/:id` — cập nhật metadata playlist.
///
/// Tất cả field optional (chỉ gửi field cần đổi). Quy tắc vàng: KHÔNG dùng
/// `Map<String, dynamic>` cho request body — luôn dùng `@freezed` Request class
/// có `toJson`.
@freezed
abstract class UpdatePlaylistRequest with _$UpdatePlaylistRequest {
  const factory UpdatePlaylistRequest({
    String? name,
    String? description,
    bool? isPublic,
  }) = _UpdatePlaylistRequest;

  factory UpdatePlaylistRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePlaylistRequestFromJson(json);
}
