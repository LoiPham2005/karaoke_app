import 'package:karaoke/shared/models/song_model.dart';

class PlaylistModel {

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songCount, required this.totalDuration, required this.ownerName, this.description,
    this.coverUrl,
    this.isPublic = false,
    this.songs = const [],
  });
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final int songCount;
  final int totalDuration;
  final String ownerName;
  final List<SongModel> songs;
}
