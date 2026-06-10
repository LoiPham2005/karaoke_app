import 'package:flutter_base/shared/models/song_model.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final int songCount;
  final int totalDuration;
  final String ownerName;
  final List<SongModel> songs;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.isPublic = false,
    required this.songCount,
    required this.totalDuration,
    required this.ownerName,
    this.songs = const [],
  });
}
