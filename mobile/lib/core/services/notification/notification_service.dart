// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/notification_service.dart (ADVANCED)
// ════════════════════════════════════════════════════════════════
import 'dart:async';
import 'dart:io';

import 'package:flutter_base/core/services/utils/navigation_service.dart';
import 'package:flutter_base/core/common/utils/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../base/di/injection.dart';

/// 🔔 Notification Service - Local Notification management
@LazySingleton()
class NotificationService {
  static const String _tag = 'NOTIFICATION';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel constants
  static const String _channelId = 'app_notification_channel';
  static const String _channelName = 'General Notifications';
  static const String _channelDescription =
      'This channel is used for general app notifications.';

  /// 🚀 Initialize Notification Service
  Future<void> initialize() async {
    try {
      // 1. Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // 2. iOS/macOS settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      // 3. Initialize
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 4. Create Android channel
      if (Platform.isAndroid) {
        await _createAndroidChannel();
      }

      Logger.success('Notification Service initialized', tag: _tag);
    } catch (e, stack) {
      Logger.error(
        'Failed to initialize Notification Service',
        error: e,
        stackTrace: stack,
        tag: _tag,
      );
    }
  }

  /// 🛠️ Create high importance channel for Android
  Future<void> _createAndroidChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// 📲 Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: importance,
      priority: priority,
      ticker: 'ticker',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// 📅 Schedule a notification (Skeleton)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Note: requires timezone initialization, skipping implementation to keep it simple but keeping the method as placeholder
    Logger.info('Scheduling notification: $title at $scheduledDate', tag: _tag);
  }

  /// 🗑️ Cancel notification
  Future<void> cancel(int id) async =>
      await _notificationsPlugin.cancel(id: id);

  /// 🧹 Cancel all
  Future<void> cancelAll() async => await _notificationsPlugin.cancelAll();

  /// 🖱️ Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    Logger.info('Notification tapped with payload: $payload', tag: _tag);

    if (payload == 'go_to_premium') {
      getIt<NavigationService>().goTo('/premium');
    }
  }
}
