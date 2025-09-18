// lib/models/notification_model.dart
import 'package:app_brimob_user/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


enum NotificationType {
  general,      // Notifikasi umum
  urgent,       // Urgent/penting
  announcement, // Pengumuman
  reminder,     // Pengingat
  event,        // Event/kegiatan
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final UserRole targetRole;
  final String senderName;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final String? actionData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.targetRole,
    required this.senderName,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.general,
    this.actionData,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      targetRole: UserRole.fromString(data['targetRole'] ?? 'other'),
      senderName: data['senderName'] ?? 'Admin',
      createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      actionData: data['actionData'],
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      targetRole: UserRole.fromString(json['targetRole'] ?? 'other'),
      senderName: json['senderName'] ?? 'Admin',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      actionData: json['actionData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'targetRole': targetRole.name,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'type': type.name,
      'actionData': actionData,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'targetRole': targetRole.name,
      'senderName': senderName,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'actionData': actionData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    UserRole? targetRole,
    String? senderName,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
    String? actionData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      targetRole: targetRole ?? this.targetRole,
      senderName: senderName ?? this.senderName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      actionData: actionData ?? this.actionData,
    );
  }
}

class NotificationStats {
  final int totalSent;
  final int totalRead;
  final int totalUnread;
  final Map<String, int> byRole;
  final Map<String, int> byType;

  NotificationStats({
    required this.totalSent,
    required this.totalRead,
    required this.totalUnread,
    required this.byRole,
    required this.byType,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalSent: json['totalSent'] ?? 0,
      totalRead: json['totalRead'] ?? 0,
      totalUnread: json['totalUnread'] ?? 0,
      byRole: Map<String, int>.from(json['byRole'] ?? {}),
      byType: Map<String, int>.from(json['byType'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSent': totalSent,
      'totalRead': totalRead,
      'totalUnread': totalUnread,
      'byRole': byRole,
      'byType': byType,
    };
  }
}