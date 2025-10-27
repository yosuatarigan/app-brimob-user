// lib/services/notification_service.dart
import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification to specific role
  static Future<bool> sendNotificationToRole({
    required String title,
    required String message,
    required UserRole targetRole,
    NotificationType type = NotificationType.general,
    String senderName = 'Admin',
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        title: title,
        message: message,
        targetRole: targetRole,
        senderName: senderName,
        createdAt: DateTime.now(),
        type: type,
      );

      // Save to Firestore - Cloud Function akan auto trigger
      await _firestore.collection('role_notifications').add(
        notification.toMap()..['targetTopic'] = targetRole.topicName,
      );

      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Get notification history - DIPERBAIKI: Ambil dari kedua collection
  static Stream<List<NotificationModel>> getNotificationHistory() {
    return _firestore
        .collection('role_notifications')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .asyncMap((roleSnapshot) async {
      // Ambil role notifications
      final roleNotifications = roleSnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      // Ambil broadcast notifications
      final broadcastSnapshot = await _firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      final broadcastNotifications = broadcastSnapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          targetRole: UserRole.makoKor, // Broadcast ke semua
          senderName: data['senderName'] ?? 'Admin',
          createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          type: NotificationType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => NotificationType.general,
          ),
          isRead: data['isRead'] ?? false,
        );
      }).toList();

      // Gabungkan dan sort berdasarkan waktu terbaru
      final allNotifications = [...roleNotifications, ...broadcastNotifications];
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allNotifications.take(50).toList();
    });
  }

  // Send to all users (broadcast)
  static Future<bool> sendBroadcastNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    String senderName = 'Admin',
  }) async {
    try {
      // Send to general notifications collection (all users)
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'senderName': senderName,
        'type': type.name,
        'targetTopic': 'all_users',
      });

      return true;
    } catch (e) {
      print('Error sending broadcast: $e');
      return false;
    }
  }

  // Get user notifications (for specific role)
  static Stream<List<NotificationModel>> getUserNotifications(UserRole userRole) {
    return _firestore
        .collection('role_notifications')
        .where('targetRole', isEqualTo: userRole.name)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all notifications (broadcast + role specific)
  static Stream<List<NotificationModel>> getAllUserNotifications(UserRole userRole) {
    // Combine broadcast notifications and role-specific notifications
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .asyncMap((broadcastSnapshot) async {
      // Get broadcast notifications
      final broadcastNotifications = broadcastSnapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          targetRole: UserRole.makoKor, // Broadcast doesn't have specific role
          senderName: data['senderName'] ?? 'Admin',
          createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          type: NotificationType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => NotificationType.general,
          ),
        );
      }).toList();

      // Get role-specific notifications
      final roleSnapshot = await _firestore
          .collection('role_notifications')
          .where('targetRole', isEqualTo: userRole.name)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final roleNotifications = roleSnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      // Combine and sort by timestamp
      final allNotifications = [...broadcastNotifications, ...roleNotifications];
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allNotifications.take(30).toList();
    });
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId, String collection) async {
    try {
      await _firestore.collection(collection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get notification stats
  static Future<NotificationStats> getNotificationStats() async {
    try {
      // Get role notifications
      final roleSnapshot = await _firestore.collection('role_notifications').get();
      final broadcastSnapshot = await _firestore.collection('notifications').get();
      
      int totalSent = roleSnapshot.docs.length + broadcastSnapshot.docs.length;
      int totalRead = 0;
      Map<String, int> byRole = {};
      Map<String, int> byType = {};

      // Process role notifications
      for (var doc in roleSnapshot.docs) {
        final data = doc.data();
        if (data['isRead'] == true) totalRead++;
        
        String role = data['targetRole'] ?? 'other';
        byRole[role] = (byRole[role] ?? 0) + 1;
        
        String type = data['type'] ?? 'general';
        byType[type] = (byType[type] ?? 0) + 1;
      }

      // Process broadcast notifications
      for (var doc in broadcastSnapshot.docs) {
        final data = doc.data();
        String type = data['type'] ?? 'general';
        byType[type] = (byType[type] ?? 0) + 1;
        
        // Count broadcast as sent to all roles
        byRole['broadcast'] = (byRole['broadcast'] ?? 0) + 1;
      }

      return NotificationStats(
        totalSent: totalSent,
        totalRead: totalRead,
        totalUnread: totalSent - totalRead,
        byRole: byRole,
        byType: byType,
      );
    } catch (e) {
      print('Error getting stats: $e');
      return NotificationStats(
        totalSent: 0,
        totalRead: 0,
        totalUnread: 0,
        byRole: {},
        byType: {},
      );
    }
  }
}