import 'package:karaoke/shared/models/lyric_line.dart';

/// Parse nội dung LRC (`[mm:ss.xx]text`) → danh sách [LyricLine] đã sort theo
/// thời gian (giây).
///
/// - Bỏ qua metadata tag dạng `[ar:...]`, `[ti:...]`, `[al:...]`, `[by:...]`,
///   `[offset:...]`, `[length:...]` (group đầu KHÔNG phải số phút:giây).
/// - Hỗ trợ nhiều timestamp trên cùng 1 dòng: `[00:01.00][00:05.00]text`.
/// - Bỏ dòng không có text sau khi trim.
List<LyricLine> parseLrc(String lrc) {
  // Tách phần timestamp [mm:ss.xx] và phần text còn lại.
  final timeTag = RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]');
  final lines = <LyricLine>[];

  for (final rawLine in lrc.split('\n')) {
    final matches = timeTag.allMatches(rawLine).toList();
    if (matches.isEmpty) continue; // metadata tag hoặc dòng trống → bỏ.

    // Text = phần sau timestamp cuối cùng.
    final text = rawLine.substring(matches.last.end).trim();
    if (text.isEmpty) continue;

    for (final m in matches) {
      final minutes = int.parse(m.group(1)!);
      final seconds = int.parse(m.group(2)!);
      final fracRaw = m.group(3);
      final fraction = fracRaw == null
          ? 0.0
          : int.parse(fracRaw) / _fractionDivisor(fracRaw.length);
      lines.add(LyricLine(time: minutes * 60 + seconds + fraction, text: text));
    }
  }

  lines.sort((a, b) => a.time.compareTo(b.time));
  return lines;
}

/// Chia đúng theo số chữ số phần thập phân: 2 chữ số → /100, 3 chữ số → /1000.
double _fractionDivisor(int digits) => switch (digits) {
  1 => 10,
  2 => 100,
  _ => 1000,
};
