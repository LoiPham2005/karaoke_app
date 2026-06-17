import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/favorites/data/models/favorite_model.dart';
import 'package:karaoke/features/favorites/presentation/providers/favorites_notifier.dart';
import 'package:karaoke/features/history/data/models/history_item_model.dart';
import 'package:karaoke/features/history/presentation/providers/history_notifier.dart';
import 'package:karaoke/features/playlists/data/models/playlist_model.dart';
import 'package:karaoke/features/playlists/presentation/providers/playlists_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(
      appAuthProvider.select((s) => s.isAuthenticated),
    );

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
              onPressed: isAuthenticated
                  ? () => _showCreatePlaylistDialog(context, ref)
                  : () => _promptLogin(context),
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
        body: isAuthenticated
            ? TabBarView(
                children: [_PlaylistsTab(), _FavoritesTab(), _HistoryTab()],
              )
            : const _LoginPrompt(),
      ),
    );
  }

  static void _promptLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập để dùng thư viện của bạn')),
    );
  }

  static Future<void> _showCreatePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Dialog tự quản controller qua StatefulWidget (dispose đúng vòng đời) —
    // tránh lỗi "TextEditingController used after disposed" khi đóng dialog.
    final result = await showDialog<_CreatePlaylistResult>(
      context: context,
      builder: (_) => const _CreatePlaylistDialog(),
    );
    if (result != null) {
      await ref.read(playlistsProvider.notifier).createPlaylist(
            name: result.name,
            description: result.description,
            isPublic: result.isPublic,
          );
    }
  }
}

/// Kết quả trả về từ [_CreatePlaylistDialog].
class _CreatePlaylistResult {
  const _CreatePlaylistResult(this.name, this.description, this.isPublic);
  final String name;
  final String? description;
  final bool isPublic;
}

/// Dialog tạo playlist — owns controller + dispose trong State (đúng vòng đời).
class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog();

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  final _nameCtl = TextEditingController();
  final _descCtl = TextEditingController();
  bool _isPublic = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      _CreatePlaylistResult(
        name,
        _descCtl.text.trim().isEmpty ? null : _descCtl.text.trim(),
        _isPublic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.bgCard,
      title: Text('Tạo playlist', style: TextStyle(color: context.textTitle)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtl,
              autofocus: true,
              style: TextStyle(color: context.textTitle),
              decoration: const InputDecoration(labelText: 'Tên playlist'),
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(height: 12.r),
            TextField(
              controller: _descCtl,
              style: TextStyle(color: context.textTitle),
              decoration: const InputDecoration(labelText: 'Mô tả (tuỳ chọn)'),
            ),
            SizedBox(height: 8.r),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Công khai',
                style: TextStyle(color: context.textBody, fontSize: 14.sp),
              ),
              value: _isPublic,
              activeThumbColor: context.brandPrimary,
              onChanged: (v) => setState(() => _isPublic = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        TextButton(onPressed: _submit, child: const Text('Tạo')),
      ],
    );
  }
}

/// Tab Playlist — `playlistsProvider`.
class _PlaylistsTab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistsProvider);
    final notifier = ref.read(playlistsProvider.notifier);
    useAsyncValueChange(state);

    return switch (state) {
      AsyncData(:final value) => _buildGrid(context, ref, value),
      AsyncError() => _ErrorRetry(onRetry: notifier.refresh),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<PlaylistModel> playlists,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.r,
        crossAxisSpacing: 16.r,
        childAspectRatio: 0.78,
      ),
      itemCount: playlists.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return GestureDetector(
            onTap: () => LibraryPage._showCreatePlaylistDialog(context, ref),
            child: DottedBorderBox(
              child: Center(
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
              ),
            ),
          );
        }
        final pl = playlists[i - 1];
        return _PlaylistGridCard(playlist: pl);
      },
    );
  }
}

/// Card playlist trong grid (dùng feature [PlaylistModel]).
class _PlaylistGridCard extends ConsumerWidget {
  const _PlaylistGridCard({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.router.push(PlaylistDetailRoute(id: playlist.id)),
      onLongPress: () => _confirmDelete(context, ref),
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radius),
              child: playlist.coverUrl != null
                  ? Image.network(
                      playlist.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackCover(context),
                    )
                  : _fallbackCover(context),
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
            playlist.isPublic ? 'Công khai' : 'Riêng tư',
            style: TextStyle(fontSize: 11.sp, color: context.textSub),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [context.brandPrimary, context.brandSecondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Icon(Icons.queue_music, color: Colors.white, size: 48.r),
  );

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.bgCard,
        title: Text('Xoá playlist?', style: TextStyle(color: ctx.textTitle)),
        content: Text(
          'Xoá "${playlist.name}" khỏi thư viện của bạn.',
          style: TextStyle(color: ctx.textBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Xoá', style: TextStyle(color: ctx.statusError)),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
    }
  }
}

/// Tab Yêu thích — `favoritesProvider`.
class _FavoritesTab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);
    useAsyncValueChange(state);

    return switch (state) {
      AsyncData(value: final list) when list.isEmpty => const _EmptyState(
        icon: Icons.favorite_border,
        message: 'Chưa có bài hát yêu thích',
      ),
      AsyncData(:final value) => _buildList(context, value),
      AsyncError() => _ErrorRetry(onRetry: notifier.refresh),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildList(BuildContext context, List<FavoriteModel> favorites) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.r),
      itemCount: favorites.length,
      itemBuilder: (_, i) => SongTile(
        song: favorites[i].song,
        index: i + 1,
        onTap: () =>
            context.router.push(PlayerRoute(id: favorites[i].song.youtubeId)),
      ),
    );
  }
}

/// Tab Lịch sử — `historyProvider`.
class _HistoryTab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    useAsyncValueChange(state);

    return switch (state) {
      AsyncData(value: final list) when list.isEmpty => const _EmptyState(
        icon: Icons.history,
        message: 'Chưa có lịch sử nghe',
      ),
      AsyncData(:final value) => _buildList(context, ref, value),
      AsyncError() => _ErrorRetry(onRetry: notifier.refresh),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<HistoryItemModel> history,
  ) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 4.r),
            child: TextButton.icon(
              onPressed: () => ref.read(historyProvider.notifier).clear(),
              icon: Icon(Icons.delete_outline, color: context.statusError),
              label: Text(
                'Xoá hết',
                style: TextStyle(color: context.statusError),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            itemCount: history.length,
            itemBuilder: (_, i) => SongTile(
              song: history[i].song,
              onTap: () => context.router.push(
                PlayerRoute(id: history[i].song.youtubeId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Nhắc đăng nhập khi chưa auth.
class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 56.r, color: context.textSub),
          SizedBox(height: 16.r),
          Text(
            'Đăng nhập để dùng thư viện',
            style: TextStyle(fontSize: 15.sp, color: context.textBody),
          ),
          SizedBox(height: 16.r),
          ElevatedButton(
            onPressed: () => context.router.push(const LoginRoute()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.brandPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56.r, color: context.textSub),
          SizedBox(height: 12.r),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: context.textSub),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: context.statusError),
          SizedBox(height: 12.r),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(fontSize: 14.sp, color: context.textBody),
          ),
          SizedBox(height: 12.r),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
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
        ),
      ),
      child: child,
    );
  }
}
