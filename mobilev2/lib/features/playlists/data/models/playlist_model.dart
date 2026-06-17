import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/features/playlists/data/models/playlist_item_model.dart';

part 'playlist_model.freezed.dart';
part 'playlist_model.g.dart';

/// Playlist từ backend.
///
/// - `GET /playlists` → list (không kèm `items`).
/// - `GET /playlists/:id` → kèm `items` [{ id, song, position }].
@freezed
abstract class PlaylistModel with _$PlaylistModel {
  const factory PlaylistModel({
    required String id,
    required String name,
    String? description,
    @Default(false) bool isPublic,
    String? coverUrl,
    List<PlaylistItemModel>? items,
  }) = _PlaylistModel;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistModelFromJson(json);
}
