import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/features/favorites/data/models/favorite_model.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/favorites/data/services/favorites_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_notifier.g.dart';

/// Riverpod notifier cho danh sách yêu thích (cần đăng nhập).
///
/// State = `List<FavoriteModel>`. Sau add/remove → refresh lại list từ server
/// để đồng bộ (id, createdAt do backend sinh).
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier
    with BaseNotifier<List<FavoriteModel>> {
  late FavoritesService _service;

  @override
  Future<List<FavoriteModel>> build() async {
    _service = FavoritesService(ref.read(dioProvider));
    // Chưa đăng nhập → trả rỗng (tránh 401). Watch appAuthProvider để khi
    // đăng nhập/đăng xuất, provider tự rebuild + refetch lại danh sách.
    final isAuth = ref.watch(appAuthProvider).isAuthenticated;
    if (!isAuth) return const [];
    final response = await _service.list();
    return response.data ?? const [];
  }

  /// Tải lại danh sách favorites.
  Future<void> refresh() => runUnwrap(
    action: _service.list,
    mapper: (data) => data,
    keepPreviousOnLoading: true,
  );

  /// `true` nếu [youtubeId] đang nằm trong list favorites hiện tại.
  bool isFavorite(String youtubeId) => (state.value ?? const <FavoriteModel>[])
      .any((f) => f.song.youtubeId == youtubeId);

  /// Thêm bài vào yêu thích rồi refresh lại list.
  Future<void> addFavorite(SongModel song) => runAsync(
    action: () async {
      await _service.add(
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
    successMessage: 'Đã thêm vào yêu thích',
  );

  /// Bỏ bài khỏi yêu thích rồi refresh lại list.
  Future<void> removeFavorite(String youtubeId) => runAsync(
    action: () async {
      await _service.remove(youtubeId);
      final response = await _service.list();
      return response.data ?? const [];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã bỏ khỏi yêu thích',
  );
}
