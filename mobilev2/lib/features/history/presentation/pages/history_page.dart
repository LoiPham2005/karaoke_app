import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/features/history/data/models/history_item_model.dart';
import 'package:karaoke/features/history/presentation/providers/history_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

@RoutePage()
class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(
      appAuthProvider.select((s) => s.isAuthenticated),
    );

    return Scaffold(
      backgroundColor: context.bgPage,
      appBar: AppBar(
        backgroundColor: context.bgPage,
        elevation: 0,
        title: Text(
          'Lịch sử hát',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.textTitle,
          ),
        ),
        actions: [
          if (isAuthenticated)
            TextButton.icon(
              onPressed: () => ref.read(historyProvider.notifier).clear(),
              icon: Icon(Icons.delete_outline, color: context.statusError),
              label: Text(
                'Xóa hết',
                style: TextStyle(color: context.statusError),
              ),
            ),
        ],
      ),
      body: isAuthenticated ? const _HistoryBody() : const _LoginPrompt(),
    );
  }
}

class _HistoryBody extends HookConsumerWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    useAsyncValueChange(state);

    return switch (state) {
      AsyncData(value: final list) when list.isEmpty => const _EmptyState(),
      AsyncData(:final value) => RefreshIndicator(
        onRefresh: notifier.refresh,
        child: _buildList(context, value),
      ),
      AsyncError() => _ErrorRetry(onRetry: notifier.refresh),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildList(BuildContext context, List<HistoryItemModel> history) {
    return ListView.builder(
      padding: EdgeInsets.all(8.r),
      itemCount: history.length,
      itemBuilder: (_, i) => SongTile(
        song: history[i].song,
        onTap: () =>
            context.router.push(PlayerRoute(id: history[i].song.youtubeId)),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 56.r, color: context.textSub),
          SizedBox(height: 16.r),
          Text(
            'Đăng nhập để xem lịch sử hát',
            style: TextStyle(fontSize: 15.sp, color: context.textBody),
          ),
          SizedBox(height: 16.r),
          ElevatedButton(
            onPressed: () => context.router.push(const LoginRoute()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.brandPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 56.r, color: context.textSub),
          SizedBox(height: 12.r),
          Text(
            'Chưa có lịch sử hát',
            style: TextStyle(fontSize: 14.sp, color: context.textSub),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: context.statusError),
          SizedBox(height: 12.r),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(fontSize: 14.sp, color: context.textBody),
          ),
          SizedBox(height: 12.r),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
