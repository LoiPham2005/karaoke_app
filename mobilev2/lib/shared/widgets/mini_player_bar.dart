import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';

/// Mini player sticky trên BottomNav khi đang phát nhạc
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final song = mockSongs.first;
    return Material(
      color: context.bgCard,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 64.r,
          padding: EdgeInsets.symmetric(horizontal: 12.r),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.borderDefault, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                child: Image.network(
                  song.thumbnailUrl,
                  width: 44.r,
                  height: 44.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 44.r,
                    height: 44.r,
                    color: context.bgInput,
                    child: Icon(Icons.music_note, color: context.textSub),
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textTitle,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.sp, color: context.textSub),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.favorite_border, color: context.textBody),
              ),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.brandPrimary, context.brandSecondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.play_arrow, color: Colors.white, size: 22.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
