// lib/services/notification_helper.dart
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize local notifications
  static Future<void> initialize() async {
    // Android initialization dengan custom sound
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );

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

    await _notificationsPlugin.initialize(initializationSettings);

    // Create notification channels for Android
    await _createNotificationChannels();
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
      sound: RawResourceAndroidNotificationSound('audionotif'), // tanpa extension
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
      sound: RawResourceAndroidNotificationSound('audionotif'), // tanpa extension
    );

    // Channel untuk high importance
    const AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Notifikasi dengan prioritas tinggi',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
      sound: RawResourceAndroidNotificationSound('audionotif'), // tanpa extension
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(mainChannel);
      await androidImplementation.createNotificationChannel(bypassChannel);
      await androidImplementation.createNotificationChannel(highImportanceChannel);
    }
  }

  // Show local notification (for foreground) dengan custom sound
  static Future<void> showNotification(RemoteMessage message) async {
    // Android notification details dengan custom sound
     AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'brimob_main_channel',
          'Brimob Notifications',
          channelDescription: 'Notifikasi utama aplikasi Brimob',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('audionotif'), // custom sound
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            message.notification?.body ?? '',
            contentTitle: message.notification?.title ?? '',
            summaryText: 'SDM Korbrimob',
          ),
        );

    // iOS notification details dengan custom sound
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'audionotif.mp3', // custom sound dengan extension untuk iOS
          badgeNumber: 1,
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
      payload: message.data.toString(),
    );
  }

  // Show notification dengan channel bypass silent
  static Future<void> showBypassSilentNotification(RemoteMessage message) async {
     AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'bypass_silent_channel',
          'Bypass Silent Notifications',
          channelDescription: 'Notifikasi yang bypass silent mode',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('audionotif'),
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'audionotif.mp3',
          badgeNumber: 1,
          interruptionLevel: InterruptionLevel.critical, // Untuk bypass silent mode iOS
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
      payload: message.data.toString(),
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
    final channelId = isCritical ? 'bypass_silent_channel' : 'brimob_main_channel';
    final channelName = isCritical ? 'Bypass Silent Notifications' : 'Brimob Notifications';
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: isCritical 
            ? 'Notifikasi yang bypass silent mode'
            : 'Notifikasi utama aplikasi Brimob',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('audionotif'),
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: isCritical ? 'SDM Korbrimob - Penting' : 'SDM Korbrimob',
          ),
          audioAttributesUsage: isCritical 
            ? AudioAttributesUsage.alarm 
            : AudioAttributesUsage.notification,
          enableLights: isCritical,
          ledColor: isCritical ? const Color.fromARGB(255, 255, 0, 0) : null,
          ledOnMs: isCritical ? 1000 : null,
          ledOffMs: isCritical ? 500 : null,
        );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'audionotif.mp3',
          badgeNumber: 1,
          interruptionLevel: isCritical 
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
    final androidImplementation = _notificationsPlugin
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
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    
    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission() ?? false;
    }

    final iOSImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    
    if (iOSImplementation != null) {
      return await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true, // Untuk critical notifications iOS
      ) ?? false;
    }
    
    return false;
  }
}