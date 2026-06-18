import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/base/riverpod/riverpod_listeners.dart';
import 'package:karaoke/design/theme/styles/app_color_tokens.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:karaoke/features/playlists/data/models/playlist_item_model.dart';
import 'package:karaoke/features/playlists/data/models/playlist_model.dart';
import 'package:karaoke/features/playlists/data/models/reorder_playlist_request.dart';
import 'package:karaoke/features/playlists/data/services/playlists_service.dart';
import 'package:karaoke/features/playlists/presentation/providers/playlists_notifier.dart';
import 'package:karaoke/features/queue/data/services/queue_service.dart';
import 'package:karaoke/features/queue/presentation/providers/queue_notifier.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/song_tile.dart';

@RoutePage()
class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({@PathParam('id') required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistDetailProvider(id));

    return Scaffold(
      backgroundColor: context.bgPage,
      body: switch (state) {
        AsyncData(:final value) => _PlaylistDetailContent(
          id: id,
          playlist: value,
        ),
        AsyncError() => _ErrorRetry(
          onRetry: () => ref.invalidate(playlistDetailProvider(id)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Nội dung chi tiết — giữ danh sách bài ở local state để hỗ trợ kéo-thả sắp
/// xếp lại (`SliverReorderableList`) mà không bị reset bởi provider.
class _PlaylistDetailContent extends HookConsumerWidget {
  const _PlaylistDetailContent({required this.id, required this.playlist});

  final String id;
  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = useState<List<PlaylistItemModel>>([...?playlist.items]);
    final enqueuing = useState(false);
    final list = items.value;
    final totalDuration = list.fold<int>(
      0,
      (sum, it) => sum + it.song.duration,
    );

    // Toast cho add-hàng-chờ và update/delete playlist (qua successMessage của
    // notifier) — hook lắng nghe transition state để hiện toast.
    useAsyncValueChange(ref.watch(queueProvider));
    useAsyncValueChange(ref.watch(playlistsProvider));

    SongRefRequest refOf(PlaylistItemModel it) => SongRefRequest(
      youtubeId: it.song.youtubeId,
      title: it.song.title,
      artist: it.song.artist,
      thumbnailUrl: it.song.thumbnailUrl,
      duration: it.song.duration,
    );

    // Thêm 1 bài vào hàng chờ (server /queue). Toast tự hiện qua queue notifier.
    Future<void> addToQueue(PlaylistItemModel it) =>
        ref.read(queueProvider.notifier).addSong(it.song);

    // Phát tất cả: nạp toàn bộ bài vào hàng chờ (server /queue) rồi mở player.
    Future<void> playAll() async {
      if (list.isEmpty || enqueuing.value) return;
      enqueuing.value = true;
      try {
        final queue = QueueService(ref.read(dioProvider));
        await queue.clear();
        for (final it in list) {
          await queue.add(refOf(it));
        }
        if (context.mounted) {
          await context.router.push(PlayerRoute(id: list.first.song.youtubeId));
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể phát playlist')),
          );
        }
      } finally {
        enqueuing.value = false;
      }
    }

    // Kéo-thả: cập nhật local ngay (optimistic) + lưu thứ tự lên server.
    void onReorder(int oldIndex, int newIndex) {
      final updated = [...list];
      if (newIndex > oldIndex) newIndex -= 1;
      final moved = updated.removeAt(oldIndex);
      updated.insert(newIndex, moved);
      items.value = updated;
      unawaited(_saveOrder(ref, context, updated));
    }

    Future<void> removeSong(String youtubeId) async {
      items.value = list.where((it) => it.song.youtubeId != youtubeId).toList();
      await ref.read(playlistsProvider.notifier).removeSong(id, youtubeId);
    }

    return CustomScrollView(
      slivers: [
        _appBar(context, ref, list.length, totalDuration),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44.r,
                    child: ElevatedButton.icon(
                      onPressed: list.isEmpty || enqueuing.value
                          ? null
                          : playAll,
                      icon: enqueuing.value
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: const Text('Phát tất cả'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.brandPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius,
                          ),
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
                    onPressed: () => ref.invalidate(playlistDetailProvider(id)),
                    icon: Icon(Icons.refresh, color: context.textBody),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48.r),
              child: Center(
                child: Text(
                  'Playlist chưa có bài hát',
                  style: TextStyle(fontSize: 14.sp, color: context.textSub),
                ),
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 8.r),
              child: Text(
                'Nhấn giữ để kéo sắp xếp lại',
                style: TextStyle(fontSize: 11.sp, color: context.textSub),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            sliver: SliverReorderableList(
              itemCount: list.length,
              onReorder: onReorder,
              itemBuilder: (context, i) {
                final item = list[i];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(item.song.youtubeId),
                  index: i,
                  child: Material(
                    color: Colors.transparent,
                    child: SongTile(
                      song: item.song,
                      index: i + 1,
                      onTap: () => context.router.push(
                        PlayerRoute(id: item.song.youtubeId),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: context.textSub,
                              size: 20.r,
                            ),
                            tooltip: 'Thêm vào hàng chờ',
                            onPressed: () => addToQueue(item),
                          ),
                          FavoriteButton(song: item.song, size: 20.r),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: context.textSub,
                              size: 20.r,
                            ),
                            tooltip: 'Xoá khỏi playlist',
                            onPressed: () => removeSong(item.song.youtubeId),
                          ),
                          Icon(
                            Icons.drag_handle,
                            color: context.textSub,
                            size: 20.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 24.r)),
      ],
    );
  }

  Future<void> _saveOrder(
    WidgetRef ref,
    BuildContext context,
    List<PlaylistItemModel> ordered,
  ) async {
    try {
      await PlaylistsService(ref.read(dioProvider)).reorder(
        id,
        ReorderPlaylistRequest(
          orderedYoutubeIds: ordered.map((e) => e.song.youtubeId).toList(),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không lưu được thứ tự')));
      }
    }
  }

  /// Dialog sửa metadata: tên + mô tả + Switch công khai. Submit → update.
  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: playlist.name);
    final descController = TextEditingController(
      text: playlist.description ?? '',
    );
    var isPublic = playlist.isPublic;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: context.bgCard,
          title: const Text('Sửa playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên playlist'),
              ),
              SizedBox(height: 12.r),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 2,
              ),
              SizedBox(height: 8.r),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Công khai'),
                value: isPublic,
                onChanged: (v) => setState(() => isPublic = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    final name = nameController.text.trim();
    final desc = descController.text.trim();
    nameController.dispose();
    descController.dispose();

    if (saved != true || name.isEmpty) return;
    await ref
        .read(playlistsProvider.notifier)
        .updatePlaylist(
          id,
          name: name,
          description: desc.isEmpty ? null : desc,
          isPublic: isPublic,
        );
  }

  /// Confirm rồi xoá playlist → quay về library (pop).
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.bgCard,
        title: const Text('Xoá playlist?'),
        content: Text('Playlist "${playlist.name}" sẽ bị xoá vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(playlistsProvider.notifier).deletePlaylist(id);
    if (context.mounted) await context.router.maybePop();
  }

  /// Copy link playlist vào clipboard + toast.
  void _share(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: 'http://localhost:3000/playlist/$id'),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã copy link')));
  }

  Widget _appBar(
    BuildContext context,
    WidgetRef ref,
    int count,
    int totalDuration,
  ) {
    return SliverAppBar(
      expandedHeight: 280.r,
      pinned: true,
      backgroundColor: context.bgPage,
      iconTheme: IconThemeData(color: context.textTitle),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: context.textTitle),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                unawaited(_showEditDialog(context, ref));
              case 'toggle':
                unawaited(
                  ref
                      .read(playlistsProvider.notifier)
                      .updatePlaylist(id, isPublic: !playlist.isPublic),
                );
              case 'share':
                _share(context);
              case 'delete':
                unawaited(_confirmDelete(context, ref));
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Sửa'),
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(
                  playlist.isPublic ? Icons.lock_outline : Icons.public,
                ),
                title: Text(
                  playlist.isPublic ? 'Đặt riêng tư' : 'Đặt công khai',
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share_outlined),
                title: Text('Chia sẻ'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Xoá playlist'),
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (playlist.coverUrl != null)
              Image.network(playlist.coverUrl!, fit: BoxFit.cover)
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.r,
                      vertical: 3.r,
                    ),
                    decoration: BoxDecoration(
                      color: playlist.isPublic
                          ? context.statusSuccess
                          : context.bgCard.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppDimensions.circle),
                    ),
                    child: Text(
                      playlist.isPublic ? '🌐 Công khai' : '🔒 Riêng tư',
                      style: TextStyle(fontSize: 10.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    playlist.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textTitle,
                    ),
                  ),
                  if (playlist.description != null) ...[
                    SizedBox(height: 4.r),
                    Text(
                      playlist.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.textBody,
                      ),
                    ),
                  ],
                  SizedBox(height: 4.r),
                  Text(
                    '$count bài • ${formatDuration(totalDuration)}',
                    style: TextStyle(fontSize: 11.sp, color: context.textSub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: context.statusError),
          SizedBox(height: 12.r),
          Text(
            'Không tải được playlist',
            style: TextStyle(fontSize: 14.sp, color: context.textBody),
          ),
          SizedBox(height: 12.r),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
