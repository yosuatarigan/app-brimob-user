class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String targetRole;
  final String senderName;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
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
    this.imageUrl,
    this.type = NotificationType.general,
    this.actionData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      targetRole: json['targetRole'] ?? '',
      senderName: json['senderName'] ?? 'Admin',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      actionData: json['actionData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'targetRole': targetRole,
      'senderName': senderName,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'type': type.name,
      'actionData': actionData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? targetRole,
    String? senderName,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      actionData: actionData ?? this.actionData,
    );
  }
}

enum NotificationType {
  general,      // Notifikasi umum
  urgent,       // Urgent/penting
  announcement, // Pengumuman
  reminder,     // Pengingat
  event,        // Event/kegiatan
}

enum UserRole {
  admin,
  binkar,
  dalpers,
  watpers,
  psikologi,
  perdankor,
  perkap,
  mako_kor,
  pas_pelopor,
  pas_gegana,
  pasbrimob_i,
  pasbrimob_ii,
  pasbrimob_iii,
  other;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.binkar:
        return 'BINKAR';
      case UserRole.dalpers:
        return 'DALPERS';
      case UserRole.watpers:
        return 'WATPERS';
      case UserRole.psikologi:
        return 'PSIKOLOGI';
      case UserRole.perdankor:
        return 'PERDANKOR';
      case UserRole.perkap:
        return 'PERKAP';
      case UserRole.mako_kor:
        return 'MAKO KOR';
      case UserRole.pas_pelopor:
        return 'PAS PELOPOR';
      case UserRole.pas_gegana:
        return 'PAS GEGANA';
      case UserRole.pasbrimob_i:
        return 'PASBRIMOB I';
      case UserRole.pasbrimob_ii:
        return 'PASBRIMOB II';
      case UserRole.pasbrimob_iii:
        return 'PASBRIMOB III';
      case UserRole.other:
        return 'OTHER';
    }
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
}