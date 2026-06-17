import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/shared/models/song_model.dart';

part 'playlist_item_model.freezed.dart';
part 'playlist_item_model.g.dart';

/// Item bên trong 1 playlist → `{ id, song, position }`.
///
/// `song` là plain [SongModel] có `fromJson`/`toJson` thủ công nên
/// json_serializable tự gọi được.
@freezed
abstract class PlaylistItemModel with _$PlaylistItemModel {
  const factory PlaylistItemModel({
    required String id,
    required SongModel song,
    @Default(0) int position,
  }) = _PlaylistItemModel;

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistItemModelFromJson(json);
}
