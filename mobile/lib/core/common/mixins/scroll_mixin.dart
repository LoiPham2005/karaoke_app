// ============================================================================
// FILE: lib/core/mixins/scroll_mixin.dart
// ============================================================================
import 'package:flutter/material.dart';

/// Mixin quản lý scroll với pagination và nhiều tính năng
mixin ScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  double _scrollThreshold = 0.9;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom && !_isLoadingMore && _hasMore) {
      onLoadMore();
    }
  }

  bool get _isNearBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * _scrollThreshold);
  }

  /// Override để handle load more
  Future<void> onLoadMore() async {}

  void setLoadingMore(bool value) {
    if (mounted) {
      setState(() => _isLoadingMore = value);
    }
  }

  void setHasMore(bool value) {
    if (mounted) {
      setState(() => _hasMore = value);
    }
  }

  /// Set ngưỡng scroll (0.0 - 1.0)
  void setScrollThreshold(double threshold) {
    _scrollThreshold = threshold.clamp(0.0, 1.0);
  }

  /// Scroll to top
  void scrollToTop({Duration? duration}) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Scroll to bottom
  void scrollToBottom({Duration? duration}) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Reset pagination
  void resetPagination() {
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _hasMore = true;
      });
    }
  }
}
