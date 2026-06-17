import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/song/presentation/providers/song_detail_providers.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/song_card.dart';

@RoutePage()
class SongDetailPage extends ConsumerWidget {
  const SongDetailPage({@PathParam('id') required this.id, super.key});

  final String id;

  // Tạm ẩn phần lời bài hát. Đổi `true` để bật lại preview lyrics.
  static const bool _showLyrics = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(songDetailProvider(id));

    return Scaffold(
      backgroundColor: context.bgPage,
      body: switch (songAsync) {
        AsyncData(:final value) => _content(context, ref, value),
        AsyncError() => _errorState(context, ref),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _errorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64.r, color: context.textSub),
          SizedBox(height: 12.r),
          Text(
            'Không tải được bài hát',
            style: TextStyle(color: context.textSub, fontSize: 14.sp),
          ),
          SizedBox(height: 12.r),
          TextButton(
            onPressed: () => ref.invalidate(songDetailProvider(id)),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, SongModel song) {
    final similarAsync = ref.watch(similarSongsProvider(id));
    final similar = similarAsync.value ?? const <SongModel>[];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 360.r,
          pinned: true,
          backgroundColor: context.bgPage,
          iconTheme: IconThemeData(color: context.textTitle),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  song.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: context.bgInput),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        context.bgPage.withValues(alpha: 0.7),
                        context.bgPage,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16.r,
                  right: 16.r,
                  bottom: 16.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textTitle,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        song.artist,
                        style:
                            TextStyle(fontSize: 14.sp, color: context.textBody),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        '${formatNumber(song.viewCount)} lượt xem • ${formatDuration(song.duration)}',
                        style:
                            TextStyle(fontSize: 12.sp, color: context.textSub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Actions ──────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.r,
                        child: ElevatedButton.icon(
                          onPressed: () => context.router
                              .push(PlayerRoute(id: song.youtubeId)),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            'Hát ngay',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.brandPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radius),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.r),
                    _ActionIcon(icon: Icons.queue_music, onTap: () {}),
                    _ActionIcon(icon: Icons.favorite_border, onTap: () {}),
                    _ActionIcon(icon: Icons.share_outlined, onTap: () {}),
                  ],
                ),
                SizedBox(height: 24.r),

                // ─── Lyrics preview (tạm ẩn) ──────────
                if (_showLyrics) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.music_note,
                            color: context.brandPrimary, size: 18.r),
                        SizedBox(width: 6.r),
                        Text(
                          'Lời bài hát',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.r),
                ],

                // ─── Similar ──────────────────────────
                Text(
                  'Bài tương tự',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textTitle,
                  ),
                ),
                SizedBox(height: 12.r),
              ],
            ),
          ),
        ),
        if (similar.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.r,
                crossAxisSpacing: 12.r,
                // Khít với nội dung card (thumbnail 16:9 + 3 dòng text) → bớt
                // khoảng trống dọc giữa các hàng.
                childAspectRatio: 0.86,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => SongCard(
                  song: similar[i],
                  onTap: () => context.router
                      .push(SongDetailRoute(id: similar[i].youtubeId)),
                ),
                childCount: similar.length,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Center(
                child: similarAsync.isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Chưa có bài tương tự',
                        style:
                            TextStyle(color: context.textSub, fontSize: 13.sp),
                      ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 24.r)),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4.r),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: context.textBody),
      ),
    );
  }
}
