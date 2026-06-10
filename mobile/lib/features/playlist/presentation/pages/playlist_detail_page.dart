import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_base/shared/mocks/mock_playlists.dart';
import 'package:flutter_base/shared/utils/format_utils.dart';
import 'package:flutter_base/shared/widgets/song_tile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final pl = mockPlaylists.firstWhere(
      (p) => p.id == id,
      orElse: () => mockPlaylists.first,
    );

    return Scaffold(
      backgroundColor: context.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.r,
            pinned: true,
            backgroundColor: context.bgPage,
            iconTheme: IconThemeData(color: context.textTitle),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (pl.coverUrl != null)
                    Image.network(pl.coverUrl!, fit: BoxFit.cover)
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [context.brandPrimary, context.brandSecondary],
                        ),
                      ),
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                          decoration: BoxDecoration(
                            color: pl.isPublic
                                ? context.statusSuccess
                                : context.bgCard.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(AppDimensions.circle),
                          ),
                          child: Text(
                            pl.isPublic ? '🌐 Công khai' : '🔒 Riêng tư',
                            style: TextStyle(fontSize: 10.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 8.r),
                        Text(
                          pl.name,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textTitle,
                          ),
                        ),
                        if (pl.description != null) ...[
                          SizedBox(height: 4.r),
                          Text(
                            pl.description!,
                            style: TextStyle(fontSize: 12.sp, color: context.textBody),
                          ),
                        ],
                        SizedBox(height: 4.r),
                        Text(
                          '${pl.ownerName} • ${pl.songCount} bài • ${formatDuration(pl.totalDuration)}',
                          style: TextStyle(fontSize: 11.sp, color: context.textSub),
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
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.r,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (pl.songs.isNotEmpty) {
                            context.push('/play/${pl.songs.first.youtubeId}');
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát tất cả'),
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
                  Container(
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.shuffle, color: context.textBody),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 4.r),
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert, color: context.textBody),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => SongTile(
                  song: pl.songs[i],
                  index: i + 1,
                  onTap: () => context.push('/play/${pl.songs[i].youtubeId}'),
                ),
                childCount: pl.songs.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.r)),
        ],
      ),
    );
  }
}
