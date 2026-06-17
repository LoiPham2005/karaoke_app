import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:karaoke/core/base/di/dio_provider.dart';
import 'package:karaoke/core/services/app_auth/app_auth_notifier.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/features/favorites/data/models/song_ref_request.dart';
import 'package:karaoke/features/favorites/data/services/favorites_service.dart';
import 'package:karaoke/features/history/presentation/providers/history_notifier.dart';
import 'package:karaoke/features/player/presentation/providers/now_playing_notifier.dart';
import 'package:karaoke/features/playlists/data/models/create_playlist_request.dart';
import 'package:karaoke/features/playlists/data/models/playlist_model.dart';
import 'package:karaoke/features/playlists/data/services/playlists_service.dart';
import 'package:karaoke/features/queue/data/models/queue_item_model.dart';
import 'package:karaoke/features/queue/data/services/queue_service.dart';
import 'package:karaoke/features/reports/data/models/create_report_request.dart';
import 'package:karaoke/features/reports/data/services/reports_service.dart';
import 'package:karaoke/features/songs/presentation/providers/lyrics_provider.dart';
import 'package:karaoke/routes/config/app_router.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/models/lyric_line.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/lyrics_highlight.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

@RoutePage()
class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({@PathParam('id') required this.id, super.key});

  final String id;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final YoutubePlayerController _controller;

  double _currentTime = 0;
  bool _playing = true;
  LyricsFontSize _fontSize = LyricsFontSize.large;

  /// Đảm bảo chỉ ghi history 1 lần / lần mở player.
  bool _historyRecorded = false;

  /// Đảm bảo chỉ auto-next 1 lần khi bài kết thúc (tránh fire nhiều lần).
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    )..addListener(_onPlayerChanged);
  }

  /// Sync state từ controller thật → UI (progress + lyrics highlight chạy theo
  /// nhạc thật).
  void _onPlayerChanged() {
    if (!mounted) return;
    final value = _controller.value;
    final position = value.position.inMilliseconds / 1000.0;
    final isPlaying = value.isPlaying;
    if (position != _currentTime || isPlaying != _playing) {
      setState(() {
        _currentTime = position;
        _playing = isPlaying;
      });
    }

    // Ghi history best-effort ngay khi player sẵn sàng (1 lần).
    if (!_historyRecorded && value.isReady) {
      _historyRecorded = true;
      _recordHistory();
    }

    // Hết bài → tự chuyển bài kế trong hàng chờ (1 lần).
    if (value.playerState == PlayerState.ended && !_advancing) {
      _advancing = true;
      unawaited(_playNext());
    }
  }

  /// Bài kế/trước trong hàng chờ theo [delta] (+1 = kế, -1 = trước). null nếu hết.
  Future<String?> _adjacentInQueue(int delta) async {
    try {
      final res = await QueueService(ref.read(dioProvider)).list();
      final q = res.data ?? const [];
      final idx = q.indexWhere((e) => e.song.youtubeId == widget.id);
      final j = idx + delta;
      if (idx >= 0 && j >= 0 && j < q.length) return q[j].song.youtubeId;
    } catch (_) {
      // lỗi mạng/queue trống → không chuyển.
    }
    return null;
  }

  Future<void> _playNext() async {
    final next = await _adjacentInQueue(1);
    if (next != null && mounted) {
      await context.router.replace(PlayerRoute(id: next));
    } else {
      _advancing = false; // không có bài kế → cho phép thử lại nếu cần
    }
  }

  Future<void> _playPrev() async {
    final prev = await _adjacentInQueue(-1);
    if (prev != null && mounted) {
      await context.router.replace(PlayerRoute(id: prev));
    }
  }

  void _recordHistory() {
    final result = ref.read(lyricsProvider(widget.id)).value;
    final song =
        result?.song ??
        mockSongs.firstWhere(
          (s) => s.youtubeId == widget.id,
          orElse: () => mockSongs.first,
        );
    // Cập nhật mini-player (BottomNav) → bài đang phát.
    ref.read(nowPlayingProvider.notifier).set(song);
    // Best-effort: lỗi (vd 401) được nuốt trong notifier.
    unawaited(ref.read(historyProvider.notifier).recordPlay(song));
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seekTo(double seconds) {
    _controller.seekTo(Duration(milliseconds: (seconds * 1000).round()));
    setState(() => _currentTime = seconds);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onPlayerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lyricsState = ref.watch(lyricsProvider(widget.id));
    final result = lyricsState.value;

    // Metadata ưu tiên từ backend (qua provider); fallback sang mock theo id.
    final fallbackSong = mockSongs.firstWhere(
      (s) => s.youtubeId == widget.id,
      orElse: () => mockSongs.first,
    );
    final song = result?.song ?? fallbackSong;
    final lyrics = result?.lines ?? const <LyricLine>[];

    // Thời lượng ưu tiên từ player (chính xác hơn metadata), fallback song.
    final playerDuration = _controller.value.metaData.duration.inSeconds;
    final totalDuration = playerDuration > 0 ? playerDuration : song.duration;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFFF3D71),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFFF3D71),
          handleColor: Color(0xFFFF3D71),
        ),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Top bar ─────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      onPressed: () => context.router.maybePop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'ĐANG HÁT',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.r),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.text_fields, color: Colors.white),
                      onPressed: _showFontSizeSheet,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showMoreSheet(song),
                    ),
                  ],
                ),
              ),

              // ─── Video (YouTube player thật) ─────────────
              AspectRatio(aspectRatio: 16 / 9, child: player),

              // ─── Lyrics ──────────────────────────────────
              Expanded(
                child: switch (lyricsState) {
                  AsyncLoading() => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3D71)),
                  ),
                  AsyncData() when lyrics.isEmpty => const _LyricsPlaceholder(),
                  AsyncError() when lyrics.isEmpty =>
                    const _LyricsPlaceholder(),
                  _ => LyricsHighlight(
                    lyrics: lyrics,
                    currentTime: _currentTime,
                    fontSize: _fontSize,
                    onLineTap: _seekTo,
                  ),
                },
              ),

              // ─── Player controls ─────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 16.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: Column(
                  children: [
                    // Progress
                    Row(
                      children: [
                        Text(
                          formatDuration(_currentTime.toInt()),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11.sp,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              activeTrackColor: const Color(0xFFFF3D71),
                              inactiveTrackColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              thumbColor: Colors.white,
                              overlayColor: const Color(
                                0xFFFF3D71,
                              ).withValues(alpha: 0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: _currentTime.clamp(
                                0,
                                totalDuration.toDouble(),
                              ),
                              max: totalDuration > 0
                                  ? totalDuration.toDouble()
                                  : 1,
                              onChanged: (v) =>
                                  setState(() => _currentTime = v),
                              onChangeEnd: _seekTo,
                            ),
                          ),
                        ),
                        Text(
                          formatDuration(totalDuration),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _playPrev,
                        ),
                        Container(
                          width: 64.r,
                          height: 64.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF3D71), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32.r,
                            ),
                            onPressed: _togglePlay,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _playNext,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.queue_music,
                            color: Colors.white,
                          ),
                          onPressed: _showQueueSheet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cỡ chữ lyrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.r),
            Wrap(
              spacing: 12.r,
              children: LyricsFontSize.values.map((size) {
                final isActive = _fontSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() => _fontSize = size);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.r,
                      vertical: 12.r,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFF3D71)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(AppDimensions.circle),
                    ),
                    child: Text(
                      size.name.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreSheet(SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetItem(Icons.favorite_border, 'Thêm yêu thích', () {
              Navigator.pop(context);
              unawaited(_addFavorite(song));
            }),
            _sheetItem(Icons.playlist_add, 'Thêm vào playlist', () {
              Navigator.pop(context);
              unawaited(_showPlaylistPicker(song));
            }),
            _sheetItem(Icons.share, 'Chia sẻ', () {
              Navigator.pop(context);
              _share(song);
            }),
            _sheetItem(Icons.flag_outlined, 'Báo lỗi', () {
              Navigator.pop(context);
              unawaited(_showReportSheet(song));
            }),
          ],
        ),
      ),
    );
  }

  // ─── Helpers cho action (favorite / playlist / share / report) ──────────

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Các action favorite/playlist/report cần đăng nhập. Chưa login → báo + chặn.
  bool _requireAuth() {
    final authed = ref.read(appAuthProvider).isAuthenticated;
    if (!authed) _toast('Đăng nhập để dùng tính năng này');
    return authed;
  }

  SongRefRequest _songRef(SongModel s) => SongRefRequest(
    youtubeId: s.youtubeId,
    title: s.title,
    artist: s.artist,
    thumbnailUrl: s.thumbnailUrl,
    duration: s.duration,
  );

  Future<void> _addFavorite(SongModel song) async {
    if (!_requireAuth()) return;
    try {
      await FavoritesService(ref.read(dioProvider)).add(_songRef(song));
      _toast('Đã thêm vào yêu thích');
    } catch (_) {
      _toast('Không thể thêm yêu thích');
    }
  }

  void _share(SongModel song) {
    Clipboard.setData(ClipboardData(text: 'https://youtu.be/${song.youtubeId}'));
    _toast('Đã copy link bài hát');
  }

  /// Bottom sheet chọn playlist để thêm bài. Kèm nút tạo playlist mới.
  Future<void> _showPlaylistPicker(SongModel song) async {
    if (!_requireAuth()) return;
    final service = PlaylistsService(ref.read(dioProvider));
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        expand: false,
        builder: (_, scrollCtrl) => FutureBuilder<List<PlaylistModel>>(
          future: service.list().then((r) => r.data ?? const []),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3D71)),
              );
            }
            final playlists = snap.data ?? const <PlaylistModel>[];
            return ListView(
              controller: scrollCtrl,
              padding: EdgeInsets.all(16.r),
              children: [
                Text(
                  'Thêm vào playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.r),
                ListTile(
                  leading: const Icon(Icons.add, color: Color(0xFFFF3D71)),
                  title: const Text(
                    'Tạo playlist mới',
                    style: TextStyle(color: Color(0xFFFF3D71)),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    unawaited(_createPlaylistAndAdd(song));
                  },
                ),
                if (playlists.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.r),
                    child: Text(
                      'Chưa có playlist nào',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 13.sp),
                    ),
                  )
                else
                  ...playlists.map(
                    (pl) => ListTile(
                      leading:
                          const Icon(Icons.queue_music, color: Colors.white),
                      title: Text(
                        pl.name,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        unawaited(_addToPlaylist(pl, song));
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _addToPlaylist(PlaylistModel pl, SongModel song) async {
    try {
      await PlaylistsService(ref.read(dioProvider)).addSong(pl.id, _songRef(song));
      _toast('Đã thêm vào "${pl.name}"');
    } catch (_) {
      _toast('Không thể thêm vào playlist');
    }
  }

  Future<void> _createPlaylistAndAdd(SongModel song) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Tạo playlist mới',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Tên playlist...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      final service = PlaylistsService(ref.read(dioProvider));
      final created = await service.create(CreatePlaylistRequest(name: name));
      final pl = created.data;
      if (pl != null) {
        await service.addSong(pl.id, _songRef(song));
      }
      _toast('Đã tạo & thêm vào "$name"');
    } catch (_) {
      _toast('Không thể tạo playlist');
    }
  }

  /// Bottom sheet báo lỗi: chọn lý do + chi tiết (tuỳ chọn) → POST /reports.
  Future<void> _showReportSheet(SongModel song) async {
    if (!_requireAuth()) return;
    const reasons = [
      'Video không phát được',
      'Sai lời bài hát',
      'Sai tên / nghệ sĩ',
      'Nội dung không phù hợp',
      'Khác',
    ];
    var reason = reasons.first;
    final detailController = TextEditingController();
    var submitting = false;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Báo lỗi bài hát',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.r),
                ...reasons.map(
                  (r) => InkWell(
                    onTap: () => setSheet(() => reason = r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.r),
                      child: Row(
                        children: [
                          Icon(
                            reason == r
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: reason == r
                                ? const Color(0xFFFF3D71)
                                : Colors.white38,
                            size: 20.r,
                          ),
                          SizedBox(width: 12.r),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.r),
                TextField(
                  controller: detailController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Mô tả thêm (không bắt buộc)...',
                  ),
                ),
                SizedBox(height: 16.r),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3D71),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: submitting
                        ? null
                        : () async {
                            setSheet(() => submitting = true);
                            final ok = await _submitReport(
                              song,
                              reason,
                              detailController.text.trim(),
                            );
                            if (ok && sheetCtx.mounted) Navigator.pop(sheetCtx);
                            if (!ok) setSheet(() => submitting = false);
                          },
                    child: const Text('Gửi báo lỗi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _submitReport(SongModel song, String reason, String detail) async {
    try {
      await ReportsService(ref.read(dioProvider)).create(
        CreateReportRequest(
          youtubeId: song.youtubeId,
          title: song.title,
          artist: song.artist,
          thumbnailUrl: song.thumbnailUrl,
          duration: song.duration,
          reason: reason,
          detail: detail.isEmpty ? null : detail,
        ),
      );
      _toast('Đã gửi báo lỗi, cảm ơn bạn!');
      return true;
    } catch (_) {
      _toast('Không gửi được báo lỗi');
      return false;
    }
  }

  /// Bottom sheet hàng chờ — tải thật từ `GET /queue` (cần đăng nhập).
  void _showQueueSheet() {
    final service = QueueService(ref.read(dioProvider));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => FutureBuilder<List<QueueItemModel>>(
          future: service.list().then((r) => r.data ?? const []),
          builder: (ctx, snap) {
            final loading = snap.connectionState != ConnectionState.done;
            final items = snap.data ?? const <QueueItemModel>[];
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Text(
                        'Hàng chờ phát',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${items.length} bài',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF3D71)),
                    ),
                  )
                else if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        ref.read(appAuthProvider).isAuthenticated
                            ? 'Hàng chờ trống'
                            : 'Đăng nhập để dùng hàng chờ',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 13.sp),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final s = items[i].song;
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              s.thumbnailUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 44,
                                height: 44,
                                color: Colors.white12,
                                child: const Icon(Icons.music_note,
                                    color: Colors.white38),
                              ),
                            ),
                          ),
                          title: Text(
                            s.title,
                            style: TextStyle(
                                color: Colors.white, fontSize: 13.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            s.artist,
                            style: TextStyle(
                                color: Colors.white60, fontSize: 11.sp),
                          ),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            unawaited(context.router
                                .push(PlayerRoute(id: s.youtubeId)));
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sheetItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

/// Hiển thị khi bài hát chưa có lời (`lrcContent` null/empty).
class _LyricsPlaceholder extends StatelessWidget {
  const _LyricsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lyrics_outlined,
            size: 48.r,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          SizedBox(height: 12.r),
          Text(
            'Lời bài hát đang cập nhật',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
