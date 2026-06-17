import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_playlist_request.freezed.dart';
part 'create_playlist_request.g.dart';

/// Body cho `POST /playlists`.
///
/// Quy tắc vàng: KHÔNG dùng `Map<String, dynamic>` cho request body — luôn dùng
/// `@freezed` Request class có `toJson`.
@freezed
abstract class CreatePlaylistRequest with _$CreatePlaylistRequest {
  const factory CreatePlaylistRequest({
    required String name,
    String? description,
    bool? isPublic,
  }) = _CreatePlaylistRequest;

  factory CreatePlaylistRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePlaylistRequestFromJson(json);
}
