import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/features/songs/data/services/songs_service.dart';
import 'package:karaoke/shared/models/lyric_line.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/utils/lrc_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_provider.g.dart';

/// Kết quả tải lyrics cho 1 video: metadata bài hát đã resolve + danh sách dòng
/// lyrics đã parse.
///
/// [lines] rỗng = bài chưa có lời ("đang cập nhật").
class LyricsResult {
  const LyricsResult({required this.song, required this.lines});

  final SongModel? song;
  final List<LyricLine> lines;

  bool get hasLyrics => lines.isNotEmpty;
}

/// FutureProvider-family: resolve metadata bài hát theo [youtubeId] rồi gọi
/// `GET /lyrics` và parse LRC.
///
/// Metadata lấy từ `GET /songs/{id}`; nếu lỗi (vd id mock) thì trả về null song
/// — page sẽ tự fallback sang dữ liệu hiện có. Cần [title] cho `/lyrics` nên
/// nếu thiếu metadata sẽ không gọi lyrics (trả rỗng).
@riverpod
Future<LyricsResult> lyrics(Ref ref, String youtubeId) async {
  final service = SongsService(ref.read(dioProvider));

  SongModel? song;
  try {
    final detail = await service.detail(youtubeId);
    song = detail.data;
  } catch (_) {
    // Bài không có trên backend (vd id mock) → bỏ qua, fallback ở UI.
    song = null;
  }

  final title = song?.title;
  if (title == null || title.isEmpty) {
    return LyricsResult(song: song, lines: const []);
  }

  final response = await service.getLyrics(
    youtubeId,
    title,
    song?.artist,
    song?.duration,
  );
  final lrc = response.data?.lrcContent;
  if (lrc == null || lrc.trim().isEmpty) {
    return LyricsResult(song: song, lines: const []);
  }

  return LyricsResult(song: song, lines: parseLrc(lrc));
}
