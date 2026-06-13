// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/fcm/fcm_service.dart
// ════════════════════════════════════════════════════════════════
//
// Firebase Cloud Messaging service.
//
// Chịu trách nhiệm:
// - Request notification permission (iOS / Android 13+)
// - Lấy FCM token (gọi backend register sau login)
// - Lắng nghe foreground/background message → forward vào LocalNotificationService
// - Lắng nghe tap notification → forward navigation
//
// KHÔNG chịu:
// - Gọi backend register/unregister (do AppAuthNotifier handle)
// - Show notification (do LocalNotificationService handle ở foreground;
//   FCM tự show ở background/terminated)
//
// Lifecycle:
//   1. AppInitializer gọi `init()` lúc boot
//   2. AppAuth sau khi login gọi `getToken()` → POST /devices
//   3. AppAuth lúc logout gọi `deleteToken()` → DELETE /devices/:id

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/services/notification/notification_service.dart';
import 'package:karaoke/core/services/utils/logger.dart';

@LazySingleton()
class FcmService {
  FcmService(this._local);

  static const String _tag = 'FCM';

  final NotificationService _local;

  bool _initialized = false;

  /// Callback khi user tap 1 push notification (foreground/background/terminated).
  /// Set 1 lần ở AppInitializer hoặc App widget — không hardcode route ở đây.
  void Function(Map<String, dynamic> data)? onMessageTap;

  /// Init permission + listeners. Idempotent (gọi nhiều lần OK).
  Future<void> init() async {
    if (_initialized) return;
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission — iOS bắt buộc, Android 13+ cũng cần
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      Logger.info(
        'Permission status: ${settings.authorizationStatus}',
        tag: _tag,
      );

      // Foreground: FCM không tự show, phải dùng LocalNotificationService
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Background: app đang mở nhưng không focus → user tap notification
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      // Terminated: app bị kill → user tap notification → mở app từ tray
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpened(initialMessage);
      }

      _initialized = true;
      Logger.info('FCM initialized', tag: _tag);
    } catch (e, st) {
      Logger.error('FCM init failed', tag: _tag, error: e, stackTrace: st);
      // Best-effort — không break app boot
    }
  }

  /// Lấy FCM token hiện tại — gọi sau khi login để register với backend.
  /// Null nếu permission denied hoặc Firebase chưa init.
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      Logger.warning('getToken failed: $e', tag: _tag);
      return null;
    }
  }

  /// Xoá token — gọi khi logout. Backend cũng cần DELETE /devices/:id riêng.
  Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      Logger.info('FCM token deleted', tag: _tag);
    } catch (e) {
      Logger.warning('deleteToken failed: $e', tag: _tag);
    }
  }

  /// Platform string khớp Prisma enum: IOS | ANDROID | WEB.
  String currentPlatform() {
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    return 'WEB';
  }

  // ─── Internal handlers ──────────────────────────────────────

  void _onForegroundMessage(RemoteMessage message) {
    Logger.info('Foreground message: ${message.notification?.title}', tag: _tag);
    final notif = message.notification;
    if (notif == null) return;
    // Show qua local notification (FCM không auto-show foreground)
    _local.showNotification(
      id: message.hashCode,
      title: notif.title ?? 'Thông báo mới',
      body: notif.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    Logger.info('Notification tapped: ${message.data}', tag: _tag);
    onMessageTap?.call(message.data);
  }
}
