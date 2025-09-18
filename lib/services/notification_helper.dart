// lib/services/emergency_notification_helper.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class EmergencyNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Initialize emergency notifications
  static Future<void> initialize() async {
    // Android initialization dengan emergency channel
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization dengan emergency settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestCriticalPermission: true, // CRITICAL: untuk bypass silent mode
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Create emergency notification channels
    await _createEmergencyChannels();
  }

  // Create emergency notification channels (Android)
  static Future<void> _createEmergencyChannels() async {
    // Regular emergency channel
    AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
      'emergency_channel', // Channel ID
      'Emergency Notifications', // Channel name
      description: 'Critical emergency notifications that bypass silent mode',
      importance: Importance.max, // Highest importance
      // priority: Priority.max, // Highest priority
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0), // Red LED
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]), // Strong vibration
      sound: const RawResourceAndroidNotificationSound('emergency_alert'), // Custom sound
      bypassDnd: true, // CRITICAL: Bypass Do Not Disturb
    );

    // Urgent channel (less intrusive)
    AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
      'urgent_channel',
      'Urgent Notifications',
      description: 'Urgent notifications with high priority',
      importance: Importance.high,
      // priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      sound: const RawResourceAndroidNotificationSound('urgent_alert'),
    );

    // Normal channel
    const AndroidNotificationChannel normalChannel = AndroidNotificationChannel(
      'normal_channel',
      'Normal Notifications',
      description: 'Normal notifications',
      importance: Importance.defaultImportance,
      // priority: Priority.defaultPriority,
      playSound: true,
      enableVibration: true,
    );

    final plugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(emergencyChannel);
    await plugin?.createNotificationChannel(urgentChannel);
    await plugin?.createNotificationChannel(normalChannel);

    print('✅ Emergency notification channels created');
  }

  // Show emergency notification yang bypass silent mode
  static Future<void> showEmergencyNotification(RemoteMessage message) async {
    print('🚨 EMERGENCY NOTIFICATION: ${message.notification?.title}');

    // Determine notification priority from data
    final isEmergency = message.data['priority'] == 'emergency' || 
                       message.data['type'] == 'urgent';
    
    if (isEmergency) {
      // Play emergency sound manually (bypass system volume)
      await _playEmergencySound();
      
      // Trigger strong vibration
      await _triggerEmergencyVibration();
    }

    // Create notification with appropriate channel
    await _showLocalNotification(message, isEmergency);
  }

  // Play emergency sound yang bypass silent mode
  static Future<void> _playEmergencySound() async {
    try {
      // Set audio context untuk emergency (Android)
      if (Platform.isAndroid) {
        await _setAudioContextEmergency();
      }

      // Play emergency sound dengan volume maksimal
      await _audioPlayer.play(
        AssetSource('sounds/emergency_alert.mp3'), // File sound darurat
        volume: 1.0, // Volume maksimal
      );

      // Ulangi 3x untuk memastikan terdengar
      await Future.delayed(const Duration(seconds: 2));
      await _audioPlayer.play(AssetSource('sounds/emergency_alert.mp3'), volume: 1.0);
      await Future.delayed(const Duration(seconds: 2));
      await _audioPlayer.play(AssetSource('sounds/emergency_alert.mp3'), volume: 1.0);

      print('🔊 Emergency sound played');
    } catch (e) {
      print('❌ Error playing emergency sound: $e');
    }
  }

  // Set audio context untuk emergency (Android)
  static Future<void> _setAudioContextEmergency() async {
    try {
      // Use platform channel untuk set audio stream type
      const platform = MethodChannel('emergency_audio');
      await platform.invokeMethod('setEmergencyAudio');
    } catch (e) {
      print('Warning: Could not set emergency audio context: $e');
    }
  }

  // Trigger strong vibration
  static Future<void> _triggerEmergencyVibration() async {
    try {
      // Use platform channel untuk strong vibration
      const platform = MethodChannel('emergency_vibration');
      await platform.invokeMethod('emergencyVibrate');
      print('📳 Emergency vibration triggered');
    } catch (e) {
      print('Warning: Could not trigger emergency vibration: $e');
      // Fallback ke haptic feedback
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
    }
  }

  // Show local notification dengan channel yang sesuai
  static Future<void> _showLocalNotification(RemoteMessage message, bool isEmergency) async {
    final title = message.notification?.title ?? 'Emergency Alert';
    final body = message.notification?.body ?? '';
    
    String channelId;
    AndroidNotificationDetails androidDetails;

    if (isEmergency) {
      channelId = 'emergency_channel';
      androidDetails = AndroidNotificationDetails(
        channelId,
        'Emergency Notifications',
        channelDescription: 'Critical emergency notifications',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        sound: const RawResourceAndroidNotificationSound('emergency_alert'),
        category: AndroidNotificationCategory.alarm, // CRITICAL: kategorikan sebagai alarm
        fullScreenIntent: true, // Tampilkan fullscreen
        ongoing: true, // Tidak bisa di-dismiss easily
        autoCancel: false, // Harus manual dismiss
        colorized: true,
        color: const Color.fromARGB(255, 255, 0, 0), // Red color
      );
    } else {
      channelId = message.data['type'] == 'urgent' ? 'urgent_channel' : 'normal_channel';
      androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == 'urgent_channel' ? 'Urgent Notifications' : 'Normal Notifications',
        importance: channelId == 'urgent_channel' ? Importance.high : Importance.defaultImportance,
        priority: channelId == 'urgent_channel' ? Priority.high : Priority.defaultPriority,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );
    }

    // iOS critical notification details
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical, // CRITICAL: bypass silent mode di iOS
      // criticalAlert: true, // CRITICAL: untuk emergency
      sound: 'emergency_alert.aiff', // Custom emergency sound
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      message.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );

    print('📱 Emergency notification displayed');
  }

  // Show emergency alert dialog
  static Future<void> showEmergencyAlert(
    BuildContext context,
    String title,
    String message,
  ) async {
    // Play sound and vibration
    await _playEmergencySound();
    await _triggerEmergencyVibration();

    // Show alert dialog yang tidak bisa di-dismiss
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa dismiss dengan tap outside
      builder: (context) => EmergencyAlertDialog(
        title: title,
        message: message,
      ),
    );
  }

  // Test emergency notification (untuk debugging)
  static Future<void> testEmergencyNotification() async {
    final testMessage = RemoteMessage(
      notification: const RemoteNotification(
        title: '🚨 TEST EMERGENCY ALERT',
        body: 'This is a test emergency notification',
      ),
      data: {
        'priority': 'emergency',
        'type': 'urgent',
      },
    );

    await showEmergencyNotification(testMessage);
  }
}

// Emergency Alert Dialog
class EmergencyAlertDialog extends StatefulWidget {
  final String title;
  final String message;

  const EmergencyAlertDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  State<EmergencyAlertDialog> createState() => _EmergencyAlertDialogState();
}

class _EmergencyAlertDialogState extends State<EmergencyAlertDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.red.shade300,
      end: Colors.red.shade600,
    ).animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _colorAnimation.value ?? Colors.red,
                width: 3,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tanggal: ${DateTime.now().toString().substring(0, 19)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _animationController.stop();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        'UNDERSTOOD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}