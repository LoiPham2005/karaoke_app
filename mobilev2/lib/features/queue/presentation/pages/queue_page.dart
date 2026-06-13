import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

@RoutePage()
class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nowPlaying = mockSongs.first;
    final upNext = mockSongs.skip(1).take(5).toList();
    final recommend = mockSongs.skip(6).take(6).toList();

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
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.delete_outline, color: context.statusError),
            label: Text(
              'Xóa hết',
              style: TextStyle(color: context.statusError),
            ),
          ),
        ],
      ),
      body: ListView(
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
              border: Border.all(color: context.brandPrimary.withValues(alpha: 0.4)),
            ),
            child: SongTile(
              song: nowPlaying,
              trailing: Icon(Icons.volume_up, color: context.brandPrimary, size: 20.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.r, 24.r, 12.r, 8.r),
            child: Row(
              children: [
                Text(
                  'TIẾP THEO (${upNext.length})',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textSub,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  'Kéo để sắp xếp',
                  style: TextStyle(fontSize: 11.sp, color: context.textSub),
                ),
              ],
            ),
          ),
          ...upNext.map(
            (s) => SongTile(
              song: s,
              trailing: Icon(Icons.drag_handle, color: context.textSub, size: 18.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.r, 24.r, 12.r, 8.r),
            child: Text(
              'ĐỀ XUẤT TỰ ĐỘNG',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.textSub,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...recommend.map(
            (s) => Opacity(
              opacity: 0.7,
              child: SongTile(
                song: s,
                trailing: Icon(Icons.add, color: context.brandPrimary, size: 20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
