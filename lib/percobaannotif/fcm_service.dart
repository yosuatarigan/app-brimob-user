// lib/services/fcm_service.dart (Updated for roles)
import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/services/notification_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Background message handler (WAJIB di top level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize FCM with user role
  static Future<void> initialize({UserRole? userRole}) async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Subscribe to topics
    await _subscribeToTopics(userRole);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps (app in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Check if app was opened from notification
    _handleInitialMessage();
  }

  // Subscribe to appropriate topics based on user role
  static Future<void> _subscribeToTopics(UserRole? userRole) async {
    // Always subscribe to general notifications
    await _messaging.subscribeToTopic('all_users');
    print('Subscribed to topic: all_users');
    
    // Subscribe to role-specific topic if role is provided
    if (userRole != null && userRole != UserRole.admin) {
      await _messaging.subscribeToTopic(userRole.topicName);
      print('Subscribed to topic: ${userRole.topicName}');
    }
  }

  // Update subscription when user role changes
  static Future<void> updateRoleSubscription(UserRole newRole) async {
    // Unsubscribe from all role topics first
    for (UserRole role in UserRole.values) {
      if (role != UserRole.admin) {
        try {
          await _messaging.unsubscribeFromTopic(role.topicName);
        } catch (e) {
          print('Error unsubscribing from ${role.topicName}: $e');
        }
      }
    }
    
    // Subscribe to new role topic
    if (newRole != UserRole.admin) {
      await _messaging.subscribeToTopic(newRole.topicName);
      print('Updated subscription to: ${newRole.topicName}');
    }
  }

  // Handle when notification is tapped (app in background)
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');
    // Navigate to specific screen if needed
  }

  // Handle when app is opened from terminated state via notification
  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification: ${initialMessage.notification?.title}');
      // Navigate to specific screen if needed
    }
  }

  // Handle foreground notifications
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    // Show local notification for foreground
    NotificationHelper.showNotification(message);
    // Also show in-app snackbar
    _showInAppNotification(message);
  }

  // Show in-app notification
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

  // Get FCM token (for debugging)
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

// Add this to your main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();