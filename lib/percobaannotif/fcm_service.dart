// lib/services/fcm_service.dart (UPDATE untuk admin)
import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/screens/alarm_screen.dart';
import 'package:app_brimob_user/services/notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Background message handler (TIDAK BERUBAH)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
    static bool _isAlarmScreenOpen = false; // ← TAMBAH ini

  // Initialize FCM with user role (UPDATE method signature)
  static Future<void> initialize({UserRole? userRole}) async {
    try {
      // Request permission (TIDAK BERUBAH)
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // Set background message handler (TIDAK BERUBAH)
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Subscribe to topics (UPDATE dengan role parameter)
      await _subscribeToTopics(userRole);

      // Handle foreground messages (TIDAK BERUBAH)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps (TIDAK BERUBAH)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from notification (TIDAK BERUBAH)
      _handleInitialMessage();

      print(
        '✅ FCM initialized successfully for role: ${userRole?.displayName ?? 'No Role'}',
      );
    } catch (e) {
      print('❌ Error in FCM initialize: $e');
      throw e; // Re-throw untuk error handling di caller
    }
  }

  // ← UPDATE: Subscribe logic untuk admin dan user biasa
  static Future<void> _subscribeToTopics(UserRole? userRole) async {
    try {
      // Always subscribe to general notifications
      await _messaging.subscribeToTopic('all_users');
      print('✅ Subscribed to topic: all_users');

      // Handle role-specific subscriptions
      if (userRole != null) {
        if (userRole == UserRole.admin) {
          // ← FIX: Admin subscribe ke SEMUA role topics
          await _subscribeAdminToAllTopics();
        } else {
          // Regular user: subscribe ke topic role sendiri
          await _messaging.subscribeToTopic(userRole.topicName);
          print('✅ Subscribed to topic: ${userRole.topicName}');
        }
      } else {
        print('⚠️ No user role provided, only subscribed to all_users');
      }
    } catch (e) {
      print('❌ Error subscribing to topics: $e');
      throw e;
    }
  }

  // ← TAMBAH: Method baru untuk admin subscribe ke semua topics
  static Future<void> _subscribeAdminToAllTopics() async {
    try {
      final allRoleTopics = [
        UserRole.makoKor.topicName,
        UserRole.pasPelopor.topicName,
        UserRole.pasGegana.topicName,
        UserRole.pasbrimobI.topicName,
        UserRole.pasbrimobII.topicName,
        UserRole.pasbrimobIII.topicName,
        // Tidak perlu admin.topicName dan other.topicName
      ];

      for (String topic in allRoleTopics) {
        await _messaging.subscribeToTopic(topic);
        print('✅ Admin subscribed to topic: $topic');
      }

      print('🎉 Admin successfully subscribed to all role topics');
    } catch (e) {
      print('❌ Error subscribing admin to all topics: $e');
      throw e;
    }
  }

  // ← UPDATE: Update subscription logic untuk admin
  static Future<void> updateRoleSubscription(UserRole newRole) async {
    try {
      if (newRole == UserRole.admin) {
        // Admin: unsubscribe dari semua topic role lama, lalu subscribe ke semua
        await _unsubscribeFromAllRoleTopics();
        await _subscribeAdminToAllTopics();
        print('🔄 Admin role subscription updated');
      } else {
        // Regular user: unsubscribe dari semua, lalu subscribe ke role baru
        await _unsubscribeFromAllRoleTopics();
        await _messaging.subscribeToTopic(newRole.topicName);
        print('🔄 User role subscription updated to: ${newRole.topicName}');
      }
    } catch (e) {
      print('❌ Error updating role subscription: $e');
    }
  }

  // ← TAMBAH: Helper method untuk unsubscribe dari semua role topics
  static Future<void> _unsubscribeFromAllRoleTopics() async {
    try {
      for (UserRole role in UserRole.values) {
        if (role != UserRole.admin) {
          // Skip admin topic (tidak digunakan)
          try {
            await _messaging.unsubscribeFromTopic(role.topicName);
            print('🗑️ Unsubscribed from: ${role.topicName}');
          } catch (e) {
            print('⚠️ Failed to unsubscribe from ${role.topicName}: $e');
            // Continue dengan topic lainnya
          }
        }
      }
    } catch (e) {
      print('❌ Error in unsubscribe all: $e');
    }
  }

  // ← TAMBAH: Method untuk debug - lihat topics yang di-subscribe (opsional)
  static Future<void> debugSubscribedTopics(UserRole? userRole) async {
    print(
      '📋 Expected subscriptions for ${userRole?.displayName ?? 'Unknown'}:',
    );
    print('  - all_users (general notifications)');

    if (userRole == UserRole.admin) {
      print('  - mako_kor_users');
      print('  - pas_pelopor_users');
      print('  - pas_gegana_users');
      print('  - pasbrimob_i_users');
      print('  - pasbrimob_ii_users');
      print('  - pasbrimob_iii_users');
      print('  (Admin receives all role notifications)');
    } else if (userRole != null) {
      print('  - ${userRole.topicName}');
    }
  }

  // METHODS LAINNYA TIDAK BERUBAH...

  // Handle when notification is tapped (TIDAK BERUBAH)
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');

    // Buka alarm screen ketika notif di-tap
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => AlarmScreen(
                title: message.notification?.title ?? 'ALARM PLB',
                message: message.notification?.body ?? '',
                targetRole: message.data['targetRole'] ?? 'Semua Satuan',
              ),
        ),
      );
    }
  }

  // Handle when app is opened from terminated state via notification (TIDAK BERUBAH)
  static Future<void> _handleInitialMessage() async {
  RemoteMessage? initialMessage = await _messaging.getInitialMessage();
  if (initialMessage != null) {
    print('App opened from notification: ${initialMessage.notification?.title}');
    
    // Delay sedikit agar context sudah ready
    Future.delayed(const Duration(milliseconds: 500), () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AlarmScreen(
              title: initialMessage.notification?.title ?? 'ALARM PLB',
              message: initialMessage.notification?.body ?? '',
              targetRole: initialMessage.data['targetRole'] ?? 'Semua Satuan',
            ),
          ),
        );
      }
    });
  }
}

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    // SEMUA notifikasi langsung buka alarm screen
    _showAlarmScreen(message);

    // Tetap show notification di background
    NotificationHelper.showBypassSilentNotification(message);
  }

 static void _showAlarmScreen(RemoteMessage message) {
    // ← PERBAIKAN: Cek apakah alarm screen sudah terbuka
    if (_isAlarmScreenOpen) {
      print('⚠️ Alarm screen already open, skipping');
      return;
    }

    final context = navigatorKey.currentContext;
    if (context != null) {
      _isAlarmScreenOpen = true; // ← Set flag
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlarmScreen(
            title: message.notification?.title ?? 'ALARM PLB',
            message: message.notification?.body ?? '',
            targetRole: message.data['targetRole'] ?? 'Semua Satuan',
          ),
        ),
      ).then((_) {
        _isAlarmScreenOpen = false; // ← Reset flag
      });
    }
  }

  // Show in-app notification (TIDAK BERUBAH)
  static void _showInAppNotification(RemoteMessage message) {
    // Get current context (you'll need to implement this based on your navigation)
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification?.title ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(message.notification?.body ?? ''),
            ],
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Get FCM token (TIDAK BERUBAH)
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      print("FCM Token: $token");
      return token;
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }
}

// Add this to your main.dart (TIDAK BERUBAH)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
