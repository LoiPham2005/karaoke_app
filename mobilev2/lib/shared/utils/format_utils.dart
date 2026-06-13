/// Format số giây thành mm:ss
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Format số lớn: 1.2M, 5.4K
String formatNumber(int n) {
  if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)}B';
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}
