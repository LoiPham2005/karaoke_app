import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:karaoke/shared/models/song_model.dart';

part 'history_item_model.freezed.dart';
part 'history_item_model.g.dart';

/// Item của `GET /history` → `{ id, song, playedAt, secondsPlayed }`.
///
/// `song` là plain [SongModel] có `fromJson`/`toJson` thủ công nên
/// json_serializable tự gọi được.
@freezed
abstract class HistoryItemModel with _$HistoryItemModel {
  const factory HistoryItemModel({
    required String id,
    required SongModel song,
    DateTime? playedAt,
    int? secondsPlayed,
  }) = _HistoryItemModel;

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemModelFromJson(json);
}
