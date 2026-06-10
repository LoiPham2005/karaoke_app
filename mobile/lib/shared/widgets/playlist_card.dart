import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/design/theme/styles/app_dimensions.dart';
import 'package:flutter_base/shared/models/playlist_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist, this.onTap});

  final PlaylistModel playlist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                  child: playlist.coverUrl != null
                      ? Image.network(
                          playlist.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackCover(context),
                        )
                      : _fallbackCover(context),
                ),
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppDimensions.circle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          playlist.isPublic ? Icons.public : Icons.lock,
                          size: 10.r,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.r),
                        Text(
                          playlist.isPublic ? 'Công khai' : 'Riêng tư',
                          style: TextStyle(fontSize: 10.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            playlist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: context.textTitle,
            ),
          ),
          Text(
            '${playlist.songCount} bài',
            style: TextStyle(fontSize: 11.sp, color: context.textSub),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [context.brandPrimary, context.brandSecondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Icon(Icons.queue_music, color: Colors.white, size: 48.r),
  );
}
