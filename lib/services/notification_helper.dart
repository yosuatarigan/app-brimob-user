// lib/services/notification_helper.dart
import 'dart:ui';

import 'package:app_brimob_user/percobaannotif/fcm_service.dart';
import 'package:app_brimob_user/screens/alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isAlarmScreenOpen = false;

  // Initialize local notifications
  static Future<void> initialize() async {
    // Android initialization dengan custom sound
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS initialization dengan custom sound
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Handle notification tap dan action buttons
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped with payload: ${response.payload}');

        // Jangan handle action button dismiss
        if (response.actionId == 'dismiss') {
          final int notificationId =
              int.tryParse(response.id?.toString() ?? '0') ?? 0;
          await _notificationsPlugin.cancel(notificationId);
          return;
        }

        // ← PERBAIKAN: Navigate ke alarm screen saat notif di-tap
        _navigateToAlarmScreen(response.payload);
      },
    );

    await _createNotificationChannels();
  }

  static void _navigateToAlarmScreen(String? payload) {
    try {
      // ← PERBAIKAN: Cek apakah alarm screen sudah terbuka
      if (_isAlarmScreenOpen) {
        print('⚠️ Alarm screen already open, skipping');
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        print('Context is null, cannot navigate');
        return;
      }

      String title = 'ALARM PLB BRIMOB';
      String message = 'Anda memiliki notifikasi penting';
      String targetRole = 'Semua Satuan';

      if (payload != null && payload.isNotEmpty) {
        final parts = payload.split('|');
        if (parts.length >= 3) {
          title = parts[0];
          message = parts[1];
          targetRole = parts[2];
        }
      }

      _isAlarmScreenOpen = true; // ← Set flag

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder:
                  (_) => AlarmScreen(
                    title: title,
                    message: message,
                    targetRole: targetRole,
                  ),
            ),
          )
          .then((_) {
            _isAlarmScreenOpen = false; // ← Reset flag saat screen ditutup
          });
    } catch (e) {
      _isAlarmScreenOpen = false; // ← Reset flag jika error
      print('Error navigating to alarm screen: $e');
    }
  }

  // Create notification channels (Android 8.0+)
  static Future<void> _createNotificationChannels() async {
    // Channel utama dengan custom sound
    const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'brimob_main_channel',
      'Brimob Notifications',
      description: 'Notifikasi utama aplikasi Brimob',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
      sound: RawResourceAndroidNotificationSound('audionotif'),
    );

    // Channel untuk bypass silent mode
    const AndroidNotificationChannel bypassChannel = AndroidNotificationChannel(
      'bypass_silent_channel',
      'Bypass Silent Notifications',
      description: 'Notifikasi yang bypass silent mode',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
      sound: RawResourceAndroidNotificationSound('audionotif'),
    );

    // Channel untuk high importance
    const AndroidNotificationChannel highImportanceChannel =
        AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'Notifikasi dengan prioritas tinggi',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
          showBadge: true,
          sound: RawResourceAndroidNotificationSound('audionotif'),
        );

    // Channel untuk critical alarm
    const AndroidNotificationChannel criticalAlarmChannel =
        AndroidNotificationChannel(
          'critical_alarm_channel',
          'Critical Alarm',
          description: 'Alarm kritis yang harus dibaca',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          showBadge: true,
          sound: RawResourceAndroidNotificationSound('audionotif'),
        );

    final androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(mainChannel);
      await androidImplementation.createNotificationChannel(bypassChannel);
      await androidImplementation.createNotificationChannel(
        highImportanceChannel,
      );
      await androidImplementation.createNotificationChannel(
        criticalAlarmChannel,
      );
    }
  }

  // Show local notification (for foreground) dengan custom sound
  static Future<void> showNotification(RemoteMessage message) async {
    // Android notification details dengan fullscreen dan ongoing

    final String payload =
        '${message.notification?.title ?? 'ALARM PLB'}|'
        '${message.notification?.body ?? ''}|'
        '${message.data['targetRole'] ?? 'Semua Satuan'}';
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'brimob_main_channel',
          'Brimob Notifications',
          channelDescription: 'Notifikasi utama aplikasi Brimob',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFFFF0000), // Merah
          colorized: true, // Aktifkan colorization
          // Full screen - muncul penuh di lockscreen
          fullScreenIntent: true,

          // Ongoing - tidak bisa di-swipe, harus klik button
          ongoing: true,
          autoCancel: false,

          showWhen: true,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('audionotif'),
          icon: '@mipmap/launcher_icon',
          largeIcon: const DrawableResourceAndroidBitmap(
            '@mipmap/launcher_icon',
          ),

          styleInformation: BigTextStyleInformation(
            message.notification?.body ?? '',
            contentTitle: message.notification?.title ?? '',
            summaryText: 'SDM Korbrimob',
          ),

          // Tombol dismiss
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'dismiss',
              'TUTUP NOTIFIKASI',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        );

    // iOS notification details dengan custom sound
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'audionotif.mp3',
          badgeNumber: 1,
          interruptionLevel: InterruptionLevel.critical,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'SDM Korbrimob',
      message.notification?.body ?? 'Anda memiliki notifikasi baru',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show notification dengan channel bypass silent
  static Future<void> showBypassSilentNotification(
    RemoteMessage message,
  ) async {
    final String payload =
        '${message.notification?.title ?? 'ALARM PLB'}|'
        '${message.notification?.body ?? ''}|'
        '${message.data['targetRole'] ?? 'Semua Satuan'}';
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'bypass_silent_channel',
          'Bypass Silent Notifications',
          channelDescription: 'Notifikasi yang bypass silent mode',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFFFF0000), // Merah
          colorized: true, // Aktifkan colorization
          // Full screen - muncul penuh di lockscreen
          fullScreenIntent: true,

          // Ongoing - tidak bisa di-swipe
          ongoing: true,
          autoCancel: false,

          showWhen: true,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('audionotif'),
          icon: '@mipmap/launcher_icon',
          largeIcon: const DrawableResourceAndroidBitmap(
            '@mipmap/launcher_icon',
          ),

          styleInformation: BigTextStyleInformation(
            message.notification?.body ?? '',
            contentTitle: message.notification?.title ?? '',
            summaryText: 'SDM Korbrimob - Penting',
          ),

          // Tambahan untuk bypass silent mode
          audioAttributesUsage: AudioAttributesUsage.alarm,
          enableLights: true,
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,

          // Tombol dismiss
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'dismiss',
              'TUTUP ALARM',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'audionotif.mp3',
          badgeNumber: 1,
          interruptionLevel: InterruptionLevel.critical,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'SDM Korbrimob - Penting',
      message.notification?.body ?? 'Anda memiliki notifikasi penting',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show custom notification dengan parameter lengkap
  static Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isCritical = false,
  }) async {
    final channelId =
        isCritical ? 'bypass_silent_channel' : 'brimob_main_channel';
    final channelName =
        isCritical ? 'Bypass Silent Notifications' : 'Brimob Notifications';

    final AndroidNotificationDetails
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          isCritical
              ? 'Notifikasi yang bypass silent mode'
              : 'Notifikasi utama aplikasi Brimob',
      importance: Importance.max,
      priority: Priority.max,
      color: const Color(0xFFFF0000), // Merah
      colorized: true, // Aktifkan colorization
      // Full screen - muncul penuh di lockscreen
      fullScreenIntent: true,

      // Ongoing - tidak bisa di-swipe
      ongoing: true,
      autoCancel: false,

      showWhen: true,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('audionotif'),
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),

      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: isCritical ? 'SDM Korbrimob - Penting' : 'SDM Korbrimob',
      ),

      audioAttributesUsage:
          isCritical
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
      enableLights: isCritical,
      ledColor: isCritical ? const Color.fromARGB(255, 255, 0, 0) : null,
      ledOnMs: isCritical ? 1000 : null,
      ledOffMs: isCritical ? 500 : null,

      // Tombol dismiss
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'dismiss',
          isCritical ? 'TUTUP ALARM' : 'TUTUP NOTIFIKASI',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'audionotif.mp3',
          badgeNumber: 1,
          interruptionLevel:
              isCritical
                  ? InterruptionLevel.critical
                  : InterruptionLevel.active,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    return false;
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      // Request full screen intent permission (Android 14+)
      await androidImplementation.requestNotificationsPermission();
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    final iOSImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iOSImplementation != null) {
      return await iOSImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          ) ??
          false;
    }

    return false;
  }
}
