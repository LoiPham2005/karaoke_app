import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/shared/models/song_model.dart';

part 'favorite_model.freezed.dart';
part 'favorite_model.g.dart';

/// Item của `GET /favorites` → `{ id, song, createdAt }`.
///
/// `song` là plain [SongModel] có `fromJson`/`toJson` thủ công nên
/// json_serializable tự gọi được.
@freezed
abstract class FavoriteModel with _$FavoriteModel {
  const factory FavoriteModel({
    required String id,
    required SongModel song,
    DateTime? createdAt,
  }) = _FavoriteModel;

  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteModelFromJson(json);
}
