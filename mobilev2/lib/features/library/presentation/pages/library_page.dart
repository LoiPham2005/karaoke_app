import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_playlists.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/widgets/playlist_card.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.bgPage,
        appBar: AppBar(
          backgroundColor: context.bgPage,
          elevation: 0,
          title: Text(
            'Thư viện của tôi',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: context.textTitle,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: context.brandPrimary),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: context.brandPrimary,
            unselectedLabelColor: context.textSub,
            indicatorColor: context.brandPrimary,
            tabAlignment: TabAlignment.start,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Playlist'),
              Tab(text: 'Yêu thích'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlaylists(context),
            _buildFavorites(context),
            _buildHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylists(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.r,
        crossAxisSpacing: 16.r,
        childAspectRatio: 0.78,
      ),
      itemCount: mockPlaylists.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return GestureDetector(
            onTap: () {},
            child: DottedBorderBox(child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 36.r, color: context.brandPrimary),
                  SizedBox(height: 8.r),
                  Text(
                    'Tạo playlist',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: context.brandPrimary,
                    ),
                  ),
                ],
              ),
            )),
          );
        }
        final pl = mockPlaylists[i - 1];
        return PlaylistCard(playlist: pl, onTap: () => context.router.push(PlaylistDetailRoute(id: pl.id)));
      },
    );
  }

  Widget _buildFavorites(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.r),
      itemCount: 10,
      itemBuilder: (_, i) => SongTile(
        song: mockSongs[i % mockSongs.length],
        index: i + 1,
        onTap: () => context.router.push(SongDetailRoute(id: mockSongs[i % mockSongs.length].youtubeId)),
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final groups = [
      ('Hôm nay', mockSongs.take(3).toList()),
      ('Hôm qua', mockSongs.skip(3).take(3).toList()),
      ('Tuần này', mockSongs.skip(6).take(4).toList()),
    ];
    return ListView(
      padding: EdgeInsets.all(8.r),
      children: [
        for (final (title, songs) in groups) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(12.r, 16.r, 12.r, 8.r),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.textSub,
              ),
            ),
          ),
          ...songs.map(
            (s) => SongTile(song: s, onTap: () => context.router.push(SongDetailRoute(id: s.youtubeId))),
          ),
        ],
      ],
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(
          color: context.brandPrimary.withValues(alpha: 0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}
