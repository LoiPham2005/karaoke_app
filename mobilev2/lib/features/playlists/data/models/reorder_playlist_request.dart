import 'package:freezed_annotation/freezed_annotation.dart';

part 'reorder_playlist_request.freezed.dart';
part 'reorder_playlist_request.g.dart';

/// Body cho `PATCH /playlists/:id/reorder` — danh sách youtubeId theo thứ tự mới.
@freezed
abstract class ReorderPlaylistRequest with _$ReorderPlaylistRequest {
  const factory ReorderPlaylistRequest({
    required List<String> orderedYoutubeIds,
  }) = _ReorderPlaylistRequest;

  factory ReorderPlaylistRequest.fromJson(Map<String, dynamic> json) =>
      _$ReorderPlaylistRequestFromJson(json);
}
