import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/utils/format_utils.dart';

/// Card bài hát vertical: thumbnail + title + artist
class SongCard extends StatelessWidget {
  const SongCard({
    required this.song, super.key,
    this.onTap,
    this.width,
  });

  final SongModel song;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      song.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: context.bgInput,
                        child: Icon(Icons.music_note, color: context.textSub),
                      ),
                    ),
                    // Play overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                        ),
                      ),
                    ),
                    if (song.hasLyrics)
                      Positioned(
                        top: 8.r,
                        left: 8.r,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                          decoration: BoxDecoration(
                            color: context.statusSuccess,
                            borderRadius: BorderRadius.circular(AppDimensions.circle),
                          ),
                          child: Text(
                            'Có lời',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 8.r,
                      bottom: 8.r,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          formatDuration(song.duration),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.r),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.textTitle,
              ),
            ),
            SizedBox(height: 2.r),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: context.textSub),
            ),
            SizedBox(height: 2.r),
            Text(
              '${formatNumber(song.viewCount)} lượt xem',
              style: TextStyle(fontSize: 11.sp, color: context.textSub),
            ),
          ],
        ),
      ),
    );
  }
}
