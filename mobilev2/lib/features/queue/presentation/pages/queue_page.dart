import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/queue/data/models/queue_item_model.dart';
import 'package:karaoke/features/queue/presentation/providers/queue_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

@RoutePage()
class QueuePage extends HookConsumerWidget {
  const QueuePage({super.key});

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
          'Hàng chờ phát',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.textTitle,
          ),
        ),
        actions: [
          if (isAuthenticated)
            TextButton.icon(
              onPressed: () => ref.read(queueProvider.notifier).clear(),
              icon: Icon(Icons.delete_outline, color: context.statusError),
              label: Text(
                'Xóa hết',
                style: TextStyle(color: context.statusError),
              ),
            ),
        ],
      ),
      body: isAuthenticated ? const _QueueBody() : const _LoginPrompt(),
    );
  }
}

class _QueueBody extends HookConsumerWidget {
  const _QueueBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(queueProvider);
    final notifier = ref.read(queueProvider.notifier);
    useAsyncValueChange(state);

    return switch (state) {
      AsyncData(value: final list) when list.isEmpty => const _EmptyState(),
      AsyncData(:final value) => _buildList(context, ref, value),
      AsyncError() => _ErrorRetry(onRetry: notifier.refresh),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<QueueItemModel> queue,
  ) {
    final nowPlaying = queue.first;
    final upNext = queue.skip(1).toList();

    return ListView(
      padding: EdgeInsets.all(8.r),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 8.r),
          child: Text(
            'ĐANG PHÁT',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: context.textSub,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.r),
          decoration: BoxDecoration(
            color: context.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radius),
            border: Border.all(
              color: context.brandPrimary.withValues(alpha: 0.4),
            ),
          ),
          child: SongTile(
            song: nowPlaying.song,
            onTap: () =>
                context.router.push(PlayerRoute(id: nowPlaying.song.youtubeId)),
            trailing: Icon(
              Icons.volume_up,
              color: context.brandPrimary,
              size: 20.r,
            ),
          ),
        ),
        if (upNext.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(12.r, 24.r, 12.r, 8.r),
            child: Text(
              'TIẾP THEO (${upNext.length})',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.textSub,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...upNext.map(
            (item) => SongTile(
              song: item.song,
              onTap: () =>
                  context.router.push(PlayerRoute(id: item.song.youtubeId)),
              trailing: IconButton(
                icon: Icon(Icons.close, color: context.textSub, size: 18.r),
                onPressed: () =>
                    ref.read(queueProvider.notifier).removeItem(item.id),
              ),
            ),
          ),
        ],
      ],
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
            'Đăng nhập để dùng hàng chờ phát',
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
          Icon(Icons.queue_music, size: 56.r, color: context.textSub),
          SizedBox(height: 12.r),
          Text(
            'Hàng chờ trống',
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
