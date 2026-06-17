import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/playlists/data/models/create_playlist_request.dart';
import 'package:karaoke/features/playlists/data/models/playlist_model.dart';
import 'package:karaoke/features/playlists/data/services/playlists_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'playlists_notifier.g.dart';

/// Riverpod notifier cho danh sách playlists của user (cần đăng nhập).
///
/// State = `List<PlaylistModel>`. Sau create/delete/addSong/removeSong → refresh
/// lại list từ server để đồng bộ (id, position do backend sinh).
@riverpod
class PlaylistsNotifier extends _$PlaylistsNotifier
    with BaseNotifier<List<PlaylistModel>> {
  late PlaylistsService _service;

  @override
  Future<List<PlaylistModel>> build() async {
    _service = PlaylistsService(ref.read(dioProvider));
    final isAuth = ref.watch(appAuthProvider).isAuthenticated;
    if (!isAuth) return const [];
    final response = await _service.list();
    return response.data ?? const [];
  }

  /// Tải lại danh sách playlists.
  Future<void> refresh() => runUnwrap(
    action: _service.list,
    mapper: (data) => data,
    keepPreviousOnLoading: true,
  );

  /// Tạo playlist mới rồi refresh lại list.
  Future<void> createPlaylist({
    required String name,
    String? description,
    bool? isPublic,
  }) => runAsync(
    action: () async {
      await _service.create(
        CreatePlaylistRequest(
          name: name,
          description: description,
          isPublic: isPublic,
        ),
      );
      final response = await _service.list();
      return response.data ?? const [];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã tạo playlist',
  );

  /// Xoá playlist rồi refresh lại list.
  Future<void> deletePlaylist(String id) => runAsync(
    action: () async {
      await _service.delete(id);
      final response = await _service.list();
      return response.data ?? const [];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã xoá playlist',
  );

  /// Thêm bài vào playlist [id] rồi refresh lại list.
  Future<void> addSong(String id, SongModel song) => runAsync(
    action: () async {
      await _service.addSong(
        id,
        SongRefRequest(
          youtubeId: song.youtubeId,
          title: song.title,
          artist: song.artist,
          thumbnailUrl: song.thumbnailUrl,
          duration: song.duration,
        ),
      );
      final response = await _service.list();
      return response.data ?? const [];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã thêm vào playlist',
  );

  /// Bỏ bài [youtubeId] khỏi playlist [id] rồi refresh lại list.
  Future<void> removeSong(String id, String youtubeId) => runAsync(
    action: () async {
      await _service.removeSong(id, youtubeId);
      final response = await _service.list();
      return response.data ?? const [];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã xoá bài khỏi playlist',
  );
}

/// FutureProvider-family: chi tiết 1 playlist (kèm `items`) theo [id].
///
/// Dùng cho [PlaylistDetailPage]. Tách riêng khỏi list notifier vì detail có
/// `items` còn list thì không.
@riverpod
Future<PlaylistModel> playlistDetail(Ref ref, String id) async {
  final service = PlaylistsService(ref.read(dioProvider));
  final response = await service.detail(id);
  final data = response.data;
  if (data == null) {
    throw StateError('Playlist không tồn tại');
  }
  return data;
}
