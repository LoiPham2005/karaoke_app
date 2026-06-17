// 📁 Song Model
// Note: Plain class (UI giai đoạn đầu) + `fromJson`/`toJson` thủ công để Retrofit
// deserialize được khi ghép API. Backend trả JSON camelCase khớp tên field.

class SongModel {
  const SongModel({
    required this.youtubeId,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.duration,
    required this.viewCount,
    this.hasLyrics = false,
    this.category = 'vpop',
    this.isFavorite = false,
  });

  /// Map JSON (camelCase) từ backend → [SongModel].
  ///
  /// Một số endpoint không trả đủ field (vd `/favorites` nhúng `song`), nên map
  /// vừa đủ + default an toàn cho field thiếu.
  factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
    youtubeId: json['youtubeId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    duration: (json['duration'] as num?)?.toInt() ?? 0,
    viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    hasLyrics: json['hasLyrics'] as bool? ?? false,
    category: json['category'] as String? ?? 'vpop',
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
  final String youtubeId;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final int duration; // seconds
  final int viewCount;
  final bool hasLyrics;
  final String category;
  final bool isFavorite;

  SongModel copyWith({
    String? youtubeId,
    String? title,
    String? artist,
    String? thumbnailUrl,
    int? duration,
    int? viewCount,
    bool? hasLyrics,
    String? category,
    bool? isFavorite,
  }) {
    return SongModel(
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      hasLyrics: hasLyrics ?? this.hasLyrics,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
    'youtubeId': youtubeId,
    'title': title,
    'artist': artist,
    'thumbnailUrl': thumbnailUrl,
    'duration': duration,
    'viewCount': viewCount,
    'hasLyrics': hasLyrics,
    'category': category,
    'isFavorite': isFavorite,
  };
}
