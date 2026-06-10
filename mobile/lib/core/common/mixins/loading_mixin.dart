// ============================================================================
// FILE: lib/core/mixins/loading_mixin.dart
// ============================================================================
import 'package:flutter/material.dart';

/// Mixin quản lý trạng thái loading với nhiều tính năng nâng cao
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _loadingMessage;
  final Map<String, bool> _loadingStates = {};

  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  /// Set loading state đơn giản
  void setLoading(bool value, {String? message}) {
    if (mounted) {
      setState(() {
        _isLoading = value;
        _loadingMessage = message;
      });
    }
  }

  /// Set loading cho một task cụ thể (multiple loading states)
  void setLoadingState(String key, bool value) {
    if (mounted) {
      setState(() => _loadingStates[key] = value);
    }
  }

  /// Check loading state của một task cụ thể
  bool isLoadingState(String key) => _loadingStates[key] ?? false;

  /// Check có bất kỳ task nào đang loading không
  bool get hasAnyLoading =>
      _isLoading || _loadingStates.values.any((loading) => loading);

  /// Thực thi action với loading
  Future<R?> withLoading<R>(
    Future<R> Function() action, {
    String? message,
    void Function(Object error)? onError,
  }) async {
    setLoading(true, message: message);
    try {
      return await action();
    } catch (e) {
      onError?.call(e);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Thực thi action với loading cho task cụ thể
  Future<R?> withLoadingState<R>(
    String key,
    Future<R> Function() action, {
    void Function(Object error)? onError,
  }) async {
    setLoadingState(key, true);
    try {
      return await action();
    } catch (e) {
      onError?.call(e);
      rethrow;
    } finally {
      setLoadingState(key, false);
    }
  }

  /// Clear tất cả loading states
  void clearAllLoadingStates() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _loadingStates.clear();
      });
    }
  }
}
