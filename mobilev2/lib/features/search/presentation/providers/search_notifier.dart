import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/features/songs/data/services/songs_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_notifier.g.dart';

/// Notifier tìm bài hát từ YouTube qua backend `GET /songs/search`.
///
/// State = `List<SongModel>`. Endpoint public (không cần đăng nhập).
/// Mỗi lần gõ → huỷ request cũ (`cancelPrevious`) để tránh race khi gõ nhanh.
@riverpod
class SearchNotifier extends _$SearchNotifier
    with BaseNotifier<List<SongModel>> {
  late SongsService _service;

  @override
  Future<List<SongModel>> build() async {
    _service = SongsService(ref.read(dioProvider));
    return const [];
  }

  /// Tìm theo [query]. Query rỗng → clear kết quả. Tự huỷ call cũ.
  Future<void> search(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      state = const AsyncValue.data(<SongModel>[]);
      return Future<void>.value();
    }
    return runAsync(
      action: () async {
        final res = await _service.search(q, 20);
        return res.data ?? const <SongModel>[];
      },
      cancelPrevious: true,
      keepPreviousOnLoading: true,
      emitEmptyForEmptyList: true,
    );
  }

  /// Xoá kết quả (khi clear ô tìm kiếm).
  void clear() => state = const AsyncValue.data(<SongModel>[]);
}
