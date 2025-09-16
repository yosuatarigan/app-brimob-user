import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_model.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    // Request permission
    await _requestPermission();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Get FCM token and save to user document
    await _updateFCMToken();
    
    // Subscribe to role-based topics
    await _subscribeToRoleTopics();
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle app opened from terminated state
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static Future<void> _requestPermission() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      announcement: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static Future<void> _updateFCMToken() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final String? token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((String token) async {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> _subscribeToRoleTopics() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Get user role from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final String userRole = userDoc.get('role') ?? 'other';
        
        // Subscribe to role-specific topic
        await _messaging.subscribeToTopic('role_$userRole');
        
        // Subscribe to general topic for all users
        await _messaging.subscribeToTopic('all_users');
        
        print('Subscribed to topics: role_$userRole, all_users');
      }
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  static Future<void> unsubscribeFromRoleTopics(String oldRole) async {
    try {
      await _messaging.unsubscribeFromTopic('role_$oldRole');
      print('Unsubscribed from topic: role_$oldRole');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Send notification to specific role (Admin function)
  static Future<bool> sendNotificationToRole({
    required String title,
    required String message,
    required UserRole targetRole,
    String? imageUrl,
    NotificationType type = NotificationType.general,
    String? actionData,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Get admin info
      final DocumentSnapshot adminDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final String senderName = adminDoc.get('fullName') ?? 'Administrator';

      // Create notification document
      final String notificationId = _firestore.collection('notifications').doc().id;
      final NotificationModel notification = NotificationModel(
        id: notificationId,
        title: title,
        message: message,
        targetRole: targetRole.name,
        senderName: senderName,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        type: type,
        actionData: actionData,
      );

      // Save to Firestore
      await _firestore.collection('notifications').doc(notificationId).set(notification.toJson());

      // Send FCM message to topic
      final String topic = targetRole == UserRole.admin ? 'all_users' : 'role_${targetRole.name}';
      
      // Note: Actual FCM sending would be done via Cloud Functions for security
      // This is just the client-side implementation
      print('Notification sent to topic: $topic');
      
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Get notifications for current user
  static Stream<List<NotificationModel>> getUserNotifications() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return <NotificationModel>[];

      final String userRole = userDoc.get('role') ?? 'other';
      
      // Get notifications for user's role and general notifications
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('targetRole', whereIn: [userRole, 'all_users'])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel.fromJson(data);
      }).toList();
    });
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('readNotifications')
          .doc(notificationId)
          .set({
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Check if notification is read
  static Future<bool> isNotificationRead(String notificationId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('readNotifications')
          .doc(notificationId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking read status: $e');
      return false;
    }
  }

  // Get unread notification count
  static Stream<int> getUnreadCount() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return 0;

      final String userRole = userDoc.get('role') ?? 'other';
      
      // Get all notifications for user
      final QuerySnapshot allNotifications = await _firestore
          .collection('notifications')
          .where('targetRole', whereIn: [userRole, 'all_users'])
          .get();

      // Get read notifications
      final QuerySnapshot readNotifications = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('readNotifications')
          .get();

      final Set<String> readIds = readNotifications.docs.map((doc) => doc.id).toSet();
      final int unreadCount = allNotifications.docs.where((doc) => !readIds.contains(doc.id)).length;

      return unreadCount;
    });
  }

  // Handle background messages
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    await _showLocalNotification(message);
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      await _showLocalNotification(message);
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'brimob_notifications',
      'Brimob Notifications',
      channelDescription: 'Notifications from Brimob Admin',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'Notifikasi Brimob',
      message.notification?.body ?? 'Anda memiliki pesan baru',
      platformChannelSpecifics,
      payload: message.data['notificationId'],
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    
    // Navigate to notification detail or relevant page
    if (message.data['notificationId'] != null) {
      // Navigate to notification history page
      // This would be handled by your app's navigation logic
    }
  }

  // Handle local notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      // Navigate to notification detail
      // This would be handled by your app's navigation logic
    }
  }

  // Get notification statistics (Admin function)
  static Future<NotificationStats> getNotificationStats() async {
    try {
      final QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final Map<String, int> byRole = {};
      final Map<String, int> byType = {};

      for (final doc in notifications.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String role = data['targetRole'] ?? 'unknown';
        final String type = data['type'] ?? 'general';

        byRole[role] = (byRole[role] ?? 0) + 1;
        byType[type] = (byType[type] ?? 0) + 1;
      }

      return NotificationStats(
        totalSent: notifications.docs.length,
        totalRead: 0, // Would need complex query to calculate
        totalUnread: 0, // Would need complex query to calculate
        byRole: byRole,
        byType: byType,
      );
    } catch (e) {
      print('Error getting notification stats: $e');
      return NotificationStats(
        totalSent: 0,
        totalRead: 0,
        totalUnread: 0,
        byRole: {},
        byType: {},
      );
    }
  }

  // Clear all notifications for current user
  static Future<void> clearAllNotifications() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final WriteBatch batch = _firestore.batch();
      
      // Get all user's read notifications
      final QuerySnapshot readNotifications = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('readNotifications')
          .get();

      for (final doc in readNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}