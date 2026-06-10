// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/network/network_monitor.dart
// ════════════════════════════════════════════════════════════════
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base/core/data/network/network_info.dart';
import 'package:flutter_base/core/services/utils/toast_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../base/di/injection.dart';

/// 🌐 Network monitor with UI feedback
///
/// - Dùng [NetworkInfo] (internet_connection_checker_plus) để kiểm tra
///   kết nối **thực sự** (ping ra internet) — chính xác hơn connectivity_plus
///   (connectivity_plus chỉ check interface WiFi/4G, không đảm bảo có internet)
/// - Hiển thị banner persistent khi mất mạng, auto dismiss khi có lại
/// - Singleton — dùng toàn app
class NetworkMonitor {
  factory NetworkMonitor() => _instance;
  NetworkMonitor._();
  static final NetworkMonitor _instance = NetworkMonitor._();

  // Inject NetworkInfo từ DI
  NetworkInfo get _networkInfo => getIt<NetworkInfo>();

  StreamSubscription<InternetStatus>? _subscription;

  // Tag for persistent network banner
  static const String _networkTag = 'network_status';

  // ═══════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════

  /// Bắt đầu theo dõi kết nối mạng
  /// Gọi 1 lần trong màn hình root (ví dụ: HomePage hoặc AppWrapper)
  Future<void> startMonitoring({
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
    bool showBanner = true,
  }) async {
    // ✅ Kiểm tra trạng thái ban đầu
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      if (showBanner) _showDisconnectedBanner();
      onDisconnected?.call();
    }

    // ✅ Theo dõi thay đổi liên tục
    await _subscription?.cancel();
    _subscription = _networkInfo.onStatusChange.listen((status) {
      _handleStatusChange(
        status,
        showBanner: showBanner,
        onConnected: onConnected,
        onDisconnected: onDisconnected,
      );
    });
  }

  /// Dừng theo dõi kết nối mạng
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    SmartDialog.dismiss(tag: _networkTag);
  }

  void dispose() => stopMonitoring();

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE
  // ═══════════════════════════════════════════════════════════════

  void _handleStatusChange(
    InternetStatus status, {
    bool showBanner = true,
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
  }) {
    if (status == InternetStatus.connected) {
      // Dismiss banner cũ
      SmartDialog.dismiss(tag: _networkTag);

      if (showBanner) _showConnectedToast();
      onConnected?.call();
    } else {
      if (showBanner) _showDisconnectedBanner();
      onDisconnected?.call();
    }
  }

  void _showConnectedToast() {
    getIt<ToastService>().success('Đã kết nối internet', title: 'Trực tuyến');
  }

  void _showDisconnectedBanner() {
    SmartDialog.show(
      tag: _networkTag,
      alignment: Alignment.topCenter,
      maskColor: Colors.transparent,
      backDismiss: false,
      clickMaskDismiss: false,
      builder: (_) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mất kết nối mạng. Vui lòng kiểm tra lại.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
