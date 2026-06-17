import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/features/history/data/models/history_add_request.dart';
import 'package:karaoke/features/history/data/models/history_item_model.dart';
import 'package:karaoke/features/history/data/services/history_service.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_notifier.g.dart';

/// Riverpod notifier cho lịch sử nghe (cần đăng nhập).
///
/// State = `List<HistoryItemModel>`. `recordPlay` dùng cho player để ghi history
/// (best-effort) — lỗi không làm hỏng UI.
@riverpod
class HistoryNotifier extends _$HistoryNotifier
    with BaseNotifier<List<HistoryItemModel>> {
  late HistoryService _service;

  @override
  Future<List<HistoryItemModel>> build() async {
    _service = HistoryService(ref.read(dioProvider));
    final isAuth = ref.watch(appAuthProvider).isAuthenticated;
    if (!isAuth) return const [];
    final response = await _service.list();
    return response.data ?? const [];
  }

  /// Tải lại lịch sử.
  Future<void> refresh() => runUnwrap(
    action: _service.list,
    mapper: (data) => data,
    keepPreviousOnLoading: true,
  );

  /// Xoá toàn bộ lịch sử.
  Future<void> clear() => runAsync(
    action: () async {
      await _service.clear();
      return const <HistoryItemModel>[];
    },
    keepPreviousOnLoading: true,
    successMessage: 'Đã xoá lịch sử',
  );

  /// Ghi 1 lượt phát vào lịch sử (best-effort).
  ///
  /// Dùng từ player khi bắt đầu phát. KHÔNG đổi state để tránh flash UI; chỉ
  /// refresh list ở background nếu thành công. Lỗi (vd 401 chưa đăng nhập) được
  /// nuốt — phát nhạc vẫn tiếp tục bình thường.
  Future<void> recordPlay(SongModel song, {int? secondsPlayed}) async {
    try {
      await _service.add(
        HistoryAddRequest(
          youtubeId: song.youtubeId,
          title: song.title,
          artist: song.artist,
          thumbnailUrl: song.thumbnailUrl,
          duration: song.duration,
          secondsPlayed: secondsPlayed,
        ),
      );
      if (!ref.mounted) return;
      // Đồng bộ list nếu tab Lịch sử đang mở.
      await refresh();
    } catch (_) {
      // Best-effort: bỏ qua lỗi (chưa đăng nhập, mạng...).
    }
  }
}
