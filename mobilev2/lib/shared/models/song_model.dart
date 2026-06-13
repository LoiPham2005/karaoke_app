// 📁 Song Model
// Note: Giai đoạn UI-only nên dùng plain class. Migrate sang freezed khi ghép API.

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
}
