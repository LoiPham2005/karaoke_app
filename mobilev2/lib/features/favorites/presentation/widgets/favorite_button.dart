import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/features/favorites/presentation/providers/favorites_notifier.dart';
import 'package:karaoke/shared/models/song_model.dart';

/// Nút tim toggle yêu thích cho 1 bài hát.
///
/// - Chưa đăng nhập → toast nhắc đăng nhập, không gọi API.
/// - Đã đăng nhập → add/remove qua [FavoritesNotifier] (tự refresh list).
/// - Trạng thái filled lấy từ list favorites hiện tại, fallback `song.isFavorite`.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({required this.song, super.key, this.size, this.color});

  final SongModel song;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(
      appAuthProvider.select((s) => s.isAuthenticated),
    );
    // Watch list favorites để nút tự cập nhật khi add/remove.
    final favorites = ref.watch(favoritesProvider).value;
    final isFavorite = isAuthenticated && favorites != null
        ? favorites.any((f) => f.song.youtubeId == song.youtubeId)
        : song.isFavorite;

    return IconButton(
      iconSize: size ?? 22.r,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? context.brandPrimary : (color ?? context.textBody),
      ),
      onPressed: () => _onTap(context, ref, isFavorite: isFavorite),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref, {
    required bool isFavorite,
  }) async {
    final isAuthenticated = ref.read(appAuthProvider).isAuthenticated;
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập để lưu bài yêu thích')),
      );
      return;
    }

    final notifier = ref.read(favoritesProvider.notifier);
    if (isFavorite) {
      await notifier.removeFavorite(song.youtubeId);
    } else {
      await notifier.addFavorite(song);
    }
  }
}
