import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/base_notifier.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/features/search/data/models/search_history_item.dart';
import 'package:karaoke/features/search/data/services/search_history_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_notifier.g.dart';

/// Lịch sử tìm kiếm lưu DB (đồng bộ web ↔ mobile, cần đăng nhập).
/// Watch appAuthProvider → đăng nhập/đăng xuất tự refetch.
@riverpod
class SearchHistoryNotifier extends _$SearchHistoryNotifier
    with BaseNotifier<List<SearchHistoryItem>> {
  late SearchHistoryService _service;

  @override
  Future<List<SearchHistoryItem>> build() async {
    _service = SearchHistoryService(ref.read(dioProvider));
    final isAuth = ref.watch(appAuthProvider).isAuthenticated;
    if (!isAuth) return const [];
    final res = await _service.list();
    return res.data ?? const [];
  }

  /// Lưu 1 từ khoá rồi refresh (không flash — giữ data cũ khi loading).
  Future<void> add(String query) {
    final q = query.trim();
    if (q.isEmpty || !ref.read(appAuthProvider).isAuthenticated) {
      return Future<void>.value();
    }
    return runAsync(
      action: () async {
        await _service.add(AddSearchRequest(query: q));
        final res = await _service.list();
        return res.data ?? const [];
      },
      keepPreviousOnLoading: true,
    );
  }

  Future<void> remove(String id) => runAsync(
    action: () async {
      await _service.remove(id);
      final res = await _service.list();
      return res.data ?? const [];
    },
    keepPreviousOnLoading: true,
  );

  Future<void> clear() => runAsync(
    action: () async {
      await _service.clear();
      return const <SearchHistoryItem>[];
    },
    keepPreviousOnLoading: true,
  );
}
