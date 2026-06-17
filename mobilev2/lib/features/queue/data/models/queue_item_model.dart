import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/shared/models/song_model.dart';

part 'queue_item_model.freezed.dart';
part 'queue_item_model.g.dart';

/// Item của `GET /queue` → `{ id, song, position }`.
///
/// `song` là plain [SongModel] có `fromJson`/`toJson` thủ công nên
/// json_serializable tự gọi được.
@freezed
abstract class QueueItemModel with _$QueueItemModel {
  const factory QueueItemModel({
    required String id,
    required SongModel song,
    @Default(0) int position,
  }) = _QueueItemModel;

  factory QueueItemModel.fromJson(Map<String, dynamic> json) =>
      _$QueueItemModelFromJson(json);
}
