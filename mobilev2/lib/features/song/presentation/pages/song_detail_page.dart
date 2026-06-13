import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_lyrics.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/song_card.dart';

@RoutePage()
class SongDetailPage extends StatelessWidget {
  const SongDetailPage({@PathParam('id') required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final song = mockSongs.firstWhere(
      (s) => s.youtubeId == id,
      orElse: () => mockSongs.first,
    );
    final similar = mockSongs.where((s) => s.youtubeId != song.youtubeId).take(6).toList();

    return Scaffold(
      backgroundColor: context.bgPage,
      body: CustomScrollView(
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
                  Image.network(song.thumbnailUrl, fit: BoxFit.cover),
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
                          style: TextStyle(fontSize: 14.sp, color: context.textBody),
                        ),
                        SizedBox(height: 4.r),
                        Text(
                          '${formatNumber(song.viewCount)} lượt xem • ${formatDuration(song.duration)}',
                          style: TextStyle(fontSize: 12.sp, color: context.textSub),
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
                            onPressed: () => context.router.push(PlayerRoute(id: song.youtubeId)),
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

                  // ─── Lyrics preview ───────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.music_note, color: context.brandPrimary, size: 18.r),
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
                        SizedBox(height: 12.r),
                        ...mockLyrics.take(8).map(
                              (line) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.r),
                                child: Text(
                                  line.text,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: context.textBody,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        SizedBox(height: 8.r),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Xem lời đầy đủ →',
                            style: TextStyle(color: context.brandPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.r),

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
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.r,
                crossAxisSpacing: 12.r,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => SongCard(
                  song: similar[i],
                  onTap: () => context.router.push(SongDetailRoute(id: similar[i].youtubeId)),
                ),
                childCount: similar.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.r)),
        ],
      ),
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
