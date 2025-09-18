// lib/services/fcm_service.dart (UPDATED untuk Emergency)
import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/services/notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Background message handler (UPDATED)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
  
  // Check if this is emergency notification
  final isEmergency = message.data['priority'] == 'emergency' || 
                     message.data['type'] == 'urgent';
  
  if (isEmergency) {
    print('🚨 EMERGENCY notification in background');
    await EmergencyNotificationHelper.showEmergencyNotification(message);
  }
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize FCM with emergency support
  static Future<void> initialize({UserRole? userRole}) async {
    try {
      // Request permissions INCLUDING critical alerts
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true, // CRITICAL: untuk iOS emergency
      );

      // Initialize emergency notification helper
      await EmergencyNotificationHelper.initialize();

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Subscribe to topics
      await _subscribeToTopics(userRole);
      
      // Handle foreground messages (UPDATED)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // Check if app was opened from notification
      _handleInitialMessage();

      print('✅ FCM initialized with emergency support for role: ${userRole?.displayName ?? 'No Role'}');
    } catch (e) {
      print('❌ Error in FCM initialize: $e');
      throw e;
    }
  }

  // Subscribe logic (TIDAK BERUBAH dari sebelumnya)
  static Future<void> _subscribeToTopics(UserRole? userRole) async {
    try {
      // Always subscribe to general notifications
      await _messaging.subscribeToTopic('all_users');
      print('✅ Subscribed to topic: all_users');
      
      // Handle role-specific subscriptions
      if (userRole != null) {
        if (userRole == UserRole.admin) {
          // Admin subscribe ke SEMUA role topics
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

  // Admin subscription (TIDAK BERUBAH)
  static Future<void> _subscribeAdminToAllTopics() async {
    try {
      final allRoleTopics = [
        UserRole.makoKor.topicName,
        UserRole.pasPelopor.topicName,
        UserRole.pasGegana.topicName,
        UserRole.pasbrimobI.topicName,
        UserRole.pasbrimobII.topicName,
        UserRole.pasbrimobIII.topicName,
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

  // UPDATED: Handle foreground messages dengan emergency detection
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    
    // Check if this is emergency notification
    final isEmergency = message.data['priority'] == 'emergency' || 
                       message.data['type'] == 'urgent';
    
    if (isEmergency) {
      print('🚨 EMERGENCY notification in foreground');
      // Show emergency notification yang bypass silent mode
      EmergencyNotificationHelper.showEmergencyNotification(message);
      
      // Also show emergency alert dialog if app is active
      final context = navigatorKey.currentContext;
      if (context != null) {
        EmergencyNotificationHelper.showEmergencyAlert(
          context,
          message.notification?.title ?? '🚨 EMERGENCY ALERT',
          message.notification?.body ?? 'Emergency notification received',
        );
      }
    } else {
      print('📢 Normal notification in foreground');
      // Show normal local notification
      EmergencyNotificationHelper.showEmergencyNotification(message);
      
      // Show in-app snackbar for normal notifications
      _showInAppNotification(message);
    }
  }

  // Handle when notification is tapped
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');
    
    final isEmergency = message.data['priority'] == 'emergency' || 
                       message.data['type'] == 'urgent';
    
    if (isEmergency) {
      print('🚨 Emergency notification tapped');
      // Navigate to emergency screen or show emergency info
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Show emergency info dialog
        EmergencyNotificationHelper.showEmergencyAlert(
          context,
          message.notification?.title ?? '🚨 EMERGENCY ALERT',
          message.notification?.body ?? 'Emergency notification',
        );
      }
    } else {
      print('📢 Normal notification tapped');
      // Normal navigation handling
    }
  }

  // Handle when app is opened from terminated state via notification
  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification: ${initialMessage.notification?.title}');
      
      final isEmergency = initialMessage.data['priority'] == 'emergency' || 
                         initialMessage.data['type'] == 'urgent';
      
      if (isEmergency) {
        print('🚨 App opened from emergency notification');
        // Handle emergency notification opening
      }
    }
  }

  // Show normal in-app notification (untuk non-emergency)
  static void _showInAppNotification(RemoteMessage message) {
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

  // TAMBAH: Send emergency notification test
  static Future<void> testEmergencyNotification() async {
    await EmergencyNotificationHelper.testEmergencyNotification();
  }

  // TAMBAH: Check emergency notification permissions
  static Future<bool> checkEmergencyPermissions() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      
      final hasBasicPermission = settings.authorizationStatus == AuthorizationStatus.authorized;
      final hasCriticalPermission = settings.criticalAlert == AppleNotificationSetting.enabled;
      
      print('📱 Notification permissions:');
      print('  Basic: $hasBasicPermission');
      print('  Critical: $hasCriticalPermission');
      
      return hasBasicPermission; // Critical permission is iOS only
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }

  // TAMBAH: Request emergency permissions
  static Future<void> requestEmergencyPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true, // iOS only
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Emergency notification permissions granted');
      } else {
        print('❌ Emergency notification permissions denied');
      }
    } catch (e) {
      print('❌ Error requesting emergency permissions: $e');
    }
  }

  // Update subscription (TIDAK BERUBAH)
  static Future<void> updateRoleSubscription(UserRole newRole) async {
    try {
      if (newRole == UserRole.admin) {
        await _unsubscribeFromAllRoleTopics();
        await _subscribeAdminToAllTopics();
        print('🔄 Admin role subscription updated');
      } else {
        await _unsubscribeFromAllRoleTopics();
        await _messaging.subscribeToTopic(newRole.topicName);
        print('🔄 User role subscription updated to: ${newRole.topicName}');
      }
    } catch (e) {
      print('❌ Error updating role subscription: $e');
    }
  }

  // Helper methods (TIDAK BERUBAH)
  static Future<void> _unsubscribeFromAllRoleTopics() async {
    try {
      for (UserRole role in UserRole.values) {
        if (role != UserRole.admin) {
          try {
            await _messaging.unsubscribeFromTopic(role.topicName);
            print('🗑️ Unsubscribed from: ${role.topicName}');
          } catch (e) {
            print('⚠️ Failed to unsubscribe from ${role.topicName}: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error in unsubscribe all: $e');
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

// Global navigator key (TIDAK BERUBAH)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();