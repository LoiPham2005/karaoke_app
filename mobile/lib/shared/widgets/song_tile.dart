import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_base/shared/models/song_model.dart';
import 'package:flutter_base/shared/utils/format_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// List tile cho bài hát — dùng trong list, playlist, queue
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.index,
    this.trailing,
    this.onTap,
  });

  final SongModel song;
  final int? index;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 6.r),
        child: Row(
          children: [
            if (index != null) ...[
              SizedBox(
                width: 24.r,
                child: Text(
                  '$index',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.r),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              child: Image.network(
                song.thumbnailUrl,
                width: 48.r,
                height: 48.r,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 48.r,
                  height: 48.r,
                  color: context.bgInput,
                  child: Icon(Icons.music_note, color: context.textSub, size: 20.r),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
            SizedBox(width: 8.r),
            Text(
              formatDuration(song.duration),
              style: TextStyle(fontSize: 12.sp, color: context.textSub),
            ),
            if (trailing != null) ...[SizedBox(width: 4.r), trailing!],
          ],
        ),
      ),
    );
  }
}
