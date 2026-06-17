import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:karaoke/features/player/presentation/providers/now_playing_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';

/// Mini player sticky trên BottomNav. Ẩn khi không có bài đang phát.
/// Bấm cả khối (hoặc nút ▶) → mở lại màn hát; nút X → tắt mini-player.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(nowPlayingProvider);
    if (song == null) return const SizedBox.shrink();

    void openPlayer() =>
        context.router.push(PlayerRoute(id: song.youtubeId));

    return Material(
      color: context.bgCard,
      child: InkWell(
        onTap: openPlayer,
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
              FavoriteButton(song: song, size: 20.r),
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
                  onPressed: openPlayer,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.play_arrow, color: Colors.white, size: 22.r),
                ),
              ),
              IconButton(
                onPressed: () => ref.read(nowPlayingProvider.notifier).clear(),
                icon: Icon(Icons.close, color: context.textSub, size: 20.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
