import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/queue/data/models/queue_item_model.dart';
import 'package:karaoke/features/queue/data/services/queue_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_notifier.g.dart';

/// Riverpod notifier cho hàng chờ phát (cần đăng nhập).
///
/// State = `List<QueueItemModel>`. Sau add/remove/clear → refresh lại list từ
/// server để đồng bộ (id, position do backend sinh).
@riverpod
class QueueNotifier extends _$QueueNotifier
    with BaseNotifier<List<QueueItemModel>> {
  late QueueService _service;

  @override
  Future<List<QueueItemModel>> build() async {
    _service = QueueService(ref.read(dioProvider));
    final isAuth = ref.watch(appAuthProvider).isAuthenticated;
    if (!isAuth) return const [];
    final response = await _service.list();
    return response.data ?? const [];
  }

  /// Tải lại hàng chờ.
  Future<void> refresh() => runUnwrap(
    action: _service.list,
    mapper: (data) => data,
    keepPreviousOnLoading: true,
  );

  /// Thêm bài vào hàng chờ rồi refresh lại list.
  Future<void> addSong(SongModel song) => runAsync(
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
    successMessage: 'Đã thêm vào hàng chờ',
  );

  /// Xoá 1 item khỏi hàng chờ rồi refresh lại list.
  Future<void> removeItem(String id) => runAsync(
    action: () async {
      await _service.removeItem(id);
      final response = await _service.list();
      return response.data ?? const [];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã xoá khỏi hàng chờ',
  );

  /// Xoá toàn bộ hàng chờ.
  Future<void> clear() => runAsync(
    action: () async {
      await _service.clear();
      return const <QueueItemModel>[];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã xoá hàng chờ',
  );
}
