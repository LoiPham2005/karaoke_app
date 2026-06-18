import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/features/songs/data/services/songs_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_notifier.g.dart';

/// Riverpod notifier cho danh sách bài mới ra ("Mới ra" trên Home).
///
/// State = `List<SongModel>`. Service trả `ApiResponse<List<SongModel>>` →
/// dùng `runUnwrap`. Endpoint public nên không cần đăng nhập.
@riverpod
class RecentNotifier extends _$RecentNotifier
    with BaseNotifier<List<SongModel>> {
  late SongsService _service;

  @override
  Future<List<SongModel>> build() async {
    _service = SongsService(ref.read(dioProvider));
    final response = await _service.recent();
    return response.data ?? const [];
  }

  /// Tải lại danh sách bài mới ra, giữ data cũ trong lúc loading.
  Future<void> refresh() => runUnwrap(
    action: _service.recent,
    mapper: (data) => data,
    keepPreviousOnLoading: true,
  );
}
