import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/design/theme/styles/app_dimensions.dart';
import 'package:karaoke/shared/mocks/mock_lyrics.dart';
import 'package:karaoke/shared/mocks/mock_songs.dart';
import 'package:karaoke/shared/models/song_model.dart';
import 'package:karaoke/shared/utils/format_utils.dart';
import 'package:karaoke/shared/widgets/lyrics_highlight.dart';

@RoutePage()
class PlayerPage extends StatefulWidget {
  const PlayerPage({@PathParam('id') required this.id, super.key});

  final String id;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Timer? _timer;
  double _currentTime = 0;
  bool _playing = true;
  LyricsFontSize _fontSize = LyricsFontSize.large;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_playing || !mounted) return;
      setState(() => _currentTime += 0.1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = mockSongs.firstWhere(
      (s) => s.youtubeId == widget.id,
      orElse: () => mockSongs.first,
    );
    final queue = mockSongs.where((s) => s.youtubeId != song.youtubeId).take(5).toList();

    return Scaffold(
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
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
                    onPressed: _showMoreSheet,
                  ),
                ],
              ),
            ),

            // ─── Video placeholder ───────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(song.thumbnailUrl, fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.4)),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_display_outlined,
                          size: 48.r,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        SizedBox(height: 8.r),
                        Text(
                          'YouTube IFrame player',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          'videoId: ${song.youtubeId}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Lyrics ──────────────────────────────────
            Expanded(
              child: LyricsHighlight(
                lyrics: mockLyrics,
                currentTime: _currentTime,
                fontSize: _fontSize,
                onLineTap: (t) => setState(() => _currentTime = t),
              ),
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
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                            thumbColor: Colors.white,
                            overlayColor: const Color(0xFFFF3D71).withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: _currentTime.clamp(0, song.duration.toDouble()),
                            max: song.duration.toDouble(),
                            onChanged: (v) => setState(() => _currentTime = v),
                          ),
                        ),
                      ),
                      Text(
                        formatDuration(song.duration),
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
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                        onPressed: () {},
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
                          onPressed: () {
                            setState(() => _playing = !_playing);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.queue_music, color: Colors.white),
                        onPressed: () => _showQueueSheet(queue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                    padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 12.r),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFF3D71) : Colors.white12,
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

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetItem(Icons.favorite_border, 'Yêu thích'),
            _sheetItem(Icons.playlist_add, 'Thêm vào playlist'),
            _sheetItem(Icons.share, 'Chia sẻ'),
            _sheetItem(Icons.flag_outlined, 'Báo cáo bài lỗi'),
          ],
        ),
      ),
    );
  }

  void _showQueueSheet(List<SongModel> queue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => Column(
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
                    '${queue.length} bài',
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: queue.length,
                itemBuilder: (_, i) {
                  final s = queue[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        s.thumbnailUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      s.title,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      s.artist,
                      style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                    ),
                    trailing: const Icon(Icons.drag_handle, color: Colors.white38),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => Navigator.pop(context),
    );
  }
}
