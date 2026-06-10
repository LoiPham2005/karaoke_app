class LyricLine {
  final double time; // seconds
  final String text;

  const LyricLine({required this.time, required this.text});
}

/// Parse LRC content (định dạng `[mm:ss.ms]text`)
List<LyricLine> parseLrc(String content) {
  final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
  final lines = <LyricLine>[];
  for (final line in content.split('\n')) {
    final match = regex.firstMatch(line);
    if (match != null) {
      final m = int.parse(match.group(1)!);
      final s = int.parse(match.group(2)!);
      final ms = int.parse(match.group(3)!.padRight(3, '0'));
      final text = match.group(4)!.trim();
      if (text.isNotEmpty) {
        lines.add(LyricLine(time: m * 60 + s + ms / 1000, text: text));
      }
    }
  }
  lines.sort((a, b) => a.time.compareTo(b.time));
  return lines;
}
