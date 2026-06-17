import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/search/data/models/search_history_item.dart';
import 'package:karaoke/features/search/presentation/providers/search_history_notifier.dart';
import 'package:karaoke/features/search/presentation/providers/search_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  static const _filters = ['Tất cả', 'Karaoke', 'Có lời', 'Beat', 'Demo'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final query = useState('');
    final filter = useState('Tất cả');
    final debounce = useRef<Timer?>(null);

    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    useAsyncValueChange(state);

    // Lịch sử tìm kiếm (DB, đồng bộ web ↔ mobile).
    final history =
        ref.watch(searchHistoryProvider).value ?? const <SearchHistoryItem>[];
    final historyNotifier = ref.read(searchHistoryProvider.notifier);

    // Mở 1 kết quả → lưu từ khoá hiện tại vào lịch sử rồi sang chi tiết.
    void openSong(String youtubeId) {
      historyNotifier.add(query.value);
      context.router.push(SongDetailRoute(id: youtubeId));
    }

    // Huỷ timer debounce khi widget dispose.
    useEffect(() => () => debounce.value?.cancel(), const []);

    void runSearch(String value) {
      query.value = value;
      debounce.value?.cancel();
      if (value.trim().isEmpty) {
        notifier.clear();
        return;
      }
      debounce.value = Timer(
        const Duration(milliseconds: 350),
        () => notifier.search(value),
      );
    }

    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: TextField(
                controller: controller,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onChanged: runSearch,
                onSubmitted: (v) {
                  debounce.value?.cancel();
                  notifier.search(v);
                  historyNotifier.add(v);
                },
                decoration: InputDecoration(
                  hintText: 'Tìm bài hát, ca sĩ...',
                  hintStyle: TextStyle(color: context.textSub),
                  prefixIcon: Icon(Icons.search, color: context.textSub),
                  suffixIcon: query.value.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.clear, color: context.textSub),
                          onPressed: () {
                            controller.clear();
                            query.value = '';
                            debounce.value?.cancel();
                            notifier.clear();
                          },
                        ),
                  filled: true,
                  fillColor: context.bgInput,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Filter chips (hiện tại chỉ trang trí — YouTube search chưa lọc theo loại)
            SizedBox(
              height: 36.r,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.r),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final active = filter.value == f;
                  return GestureDetector(
                    onTap: () => filter.value = f,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.r, vertical: 6.r),
                      decoration: BoxDecoration(
                        color: active ? context.brandPrimary : context.bgInput,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.circle),
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : context.textBody,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.r),
            Expanded(
              child: query.value.trim().isEmpty
                  ? _buildRecent(
                      context,
                      history,
                      onTap: (q) {
                        controller.text = q;
                        runSearch(q);
                      },
                      onRemove: historyNotifier.remove,
                      onClear: historyNotifier.clear,
                    )
                  : _buildResults(context, state, openSong),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecent(
    BuildContext context,
    List<SearchHistoryItem> items, {
    required ValueChanged<String> onTap,
    required ValueChanged<String> onRemove,
    required VoidCallback onClear,
  }) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      children: [
        Row(
          children: [
            Icon(Icons.history, color: context.textSub, size: 16.r),
            SizedBox(width: 6.r),
            Text(
              'Tìm kiếm gần đây',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.textSub,
              ),
            ),
            const Spacer(),
            if (items.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Xóa tất cả',
                  style: TextStyle(fontSize: 12.sp, color: context.brandPrimary),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.r),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24.r),
            child: Center(
              child: Text(
                'Chưa có lịch sử tìm kiếm',
                style: TextStyle(fontSize: 13.sp, color: context.textSub),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8.r,
            runSpacing: 8.r,
            children: items
                .map(
                  (item) => GestureDetector(
                    onTap: () => onTap(item.query),
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 12.r,
                        right: 6.r,
                        top: 6.r,
                        bottom: 6.r,
                      ),
                      decoration: BoxDecoration(
                        color: context.bgInput,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.circle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.query,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: context.textBody,
                            ),
                          ),
                          SizedBox(width: 4.r),
                          GestureDetector(
                            onTap: () => onRemove(item.id),
                            child: Icon(
                              Icons.close,
                              size: 14.r,
                              color: context.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildResults(
    BuildContext context,
    AsyncValue<List<SongModel>> state,
    void Function(String youtubeId) openSong,
  ) {
    return switch (state) {
      // Đang tải lần đầu (chưa có data cũ).
      AsyncValue(:final value?, isLoading: true) when value.isEmpty =>
        const Center(child: CircularProgressIndicator()),
      AsyncValue(hasValue: false, isLoading: true) =>
        const Center(child: CircularProgressIndicator()),
      AsyncData(value: final list) when list.isEmpty => _empty(context),
      AsyncValue(:final value?) => _list(context, value, openSong),
      AsyncError() => _error(context),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _list(
    BuildContext context,
    List<SongModel> results,
    void Function(String youtubeId) openSong,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.r),
      itemCount: results.length,
      itemBuilder: (_, i) => SongTile(
        song: results[i],
        onTap: () => openSong(results[i].youtubeId),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.r, color: context.textSub),
          SizedBox(height: 12.r),
          Text(
            'Không tìm thấy bài nào',
            style: TextStyle(color: context.textSub, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _error(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64.r, color: context.textSub),
          SizedBox(height: 12.r),
          Text(
            'Lỗi tải kết quả, thử lại',
            style: TextStyle(color: context.textSub, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
