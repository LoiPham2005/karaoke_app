import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karaoke/shared/models/lyric_line.dart';

/// Karaoke lyrics — highlight dòng đang hát theo timestamp
class LyricsHighlight extends StatefulWidget {
  const LyricsHighlight({
    required this.lyrics, required this.currentTime, super.key,
    this.fontSize = LyricsFontSize.large,
    this.onLineTap,
  });

  final List<LyricLine> lyrics;
  final double currentTime;
  final LyricsFontSize fontSize;
  final ValueChanged<double>? onLineTap;

  @override
  State<LyricsHighlight> createState() => _LyricsHighlightState();
}

enum LyricsFontSize { small, medium, large, xlarge }

class _LyricsHighlightState extends State<LyricsHighlight> {
  final _controller = ScrollController();
  int _activeIndex = 0;

  @override
  void didUpdateWidget(LyricsHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _findActiveIndex();
    if (next != _activeIndex) {
      _activeIndex = next;
      _scrollToActive();
    }
  }

  int _findActiveIndex() {
    int idx = 0;
    for (int i = 0; i < widget.lyrics.length; i++) {
      if (widget.lyrics[i].time <= widget.currentTime) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }

  void _scrollToActive() {
    if (!_controller.hasClients) return;
    final lineHeight = 64.r;
    final offset = (_activeIndex * lineHeight) - 200.r;
    _controller.animateTo(
      offset.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  double get _baseFontSize {
    return switch (widget.fontSize) {
      LyricsFontSize.small => 14.sp,
      LyricsFontSize.medium => 16.sp,
      LyricsFontSize.large => 20.sp,
      LyricsFontSize.xlarge => 26.sp,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      padding: EdgeInsets.symmetric(vertical: 120.r, horizontal: 24.r),
      itemCount: widget.lyrics.length,
      itemBuilder: (context, idx) {
        final line = widget.lyrics[idx];
        final isActive = idx == _activeIndex;
        final isPassed = idx < _activeIndex;
        return GestureDetector(
          onTap: widget.onLineTap == null ? null : () => widget.onLineTap!(line.time),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isActive ? _baseFontSize * 1.15 : _baseFontSize,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? const Color(0xFFFF3D71)
                  : isPassed
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.7),
              shadows: isActive
                  ? [
                      const Shadow(
                        color: Color(0xFFFF3D71),
                        blurRadius: 24,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.r),
              child: Text(line.text, textAlign: TextAlign.center),
            ),
          ),
        );
      },
    );
  }
}
