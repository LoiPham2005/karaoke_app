import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'now_playing_notifier.g.dart';

/// Bài đang/ vừa phát — nguồn cho MiniPlayerBar trên BottomNav.
///
/// `null` = không có gì đang phát → ẩn mini-player. PlayerPage gọi `set` khi mở
/// 1 bài; nút X ở mini-player gọi `clear`.
@Riverpod(keepAlive: true)
class NowPlaying extends _$NowPlaying {
  @override
  SongModel? build() => null;

  void set(SongModel song) => state = song;
  void clear() => state = null;
}
