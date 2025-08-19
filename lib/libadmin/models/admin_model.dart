class AdminUser {
  final String uid;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? profileImageUrl;

  AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.lastLogin,
    this.profileImageUrl,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map, String uid) {
    return AdminUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'public',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(map['lastLogin'] ?? 0),
      profileImageUrl: map['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class ContentItem {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> images;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final bool isPublished;
  final int viewCount;

  ContentItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.images,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.isPublished,
    required this.viewCount,
  });

  factory ContentItem.fromMap(Map<String, dynamic> map, String id) {
    return ContentItem(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isPublic: map['isPublic'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      createdBy: map['createdBy'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      isPublished: map['isPublished'] ?? false,
      viewCount: map['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'images': images,
      'isPublic': isPublic,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isPublished': isPublished,
      'viewCount': viewCount,
    };
  }
}

class MediaFile {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String? description;
  final List<String> tags;
  final bool isUsed;

  MediaFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    required this.uploadedBy,
    this.description,
    required this.tags,
    required this.isUsed,
  });

  factory MediaFile.fromMap(Map<String, dynamic> map, String id) {
    return MediaFile(
      id: id,
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'] ?? 0),
      uploadedBy: map['uploadedBy'] ?? '',
      description: map['description'],
      tags: List<String>.from(map['tags'] ?? []),
      isUsed: map['isUsed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'uploadedBy': uploadedBy,
      'description': description,
      'tags': tags,
      'isUsed': isUsed,
    };
  }
}

class GalleryItem {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final String logoUrl;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  GalleryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.logoUrl,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> map, String id) {
    return GalleryItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      logoUrl: map['logoUrl'] ?? '',
      order: map['order'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      createdBy: map['createdBy'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'images': images,
      'logoUrl': logoUrl,
      'order': order,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }
}

class AppAnalytics {
  final String id;
  final int totalUsers;
  final int totalContent;
  final int totalMedia;
  final int activeUsers;
  final int storageUsed; // in bytes
  final Map<String, int> contentByCategory;
  final Map<String, int> usersByRole;
  final DateTime lastUpdated;

  AppAnalytics({
    required this.id,
    required this.totalUsers,
    required this.totalContent,
    required this.totalMedia,
    required this.activeUsers,
    required this.storageUsed,
    required this.contentByCategory,
    required this.usersByRole,
    required this.lastUpdated,
  });

  factory AppAnalytics.fromMap(Map<String, dynamic> map, String id) {
    return AppAnalytics(
      id: id,
      totalUsers: map['totalUsers'] ?? 0,
      totalContent: map['totalContent'] ?? 0,
      totalMedia: map['totalMedia'] ?? 0,
      activeUsers: map['activeUsers'] ?? 0,
      storageUsed: map['storageUsed'] ?? 0,
      contentByCategory: Map<String, int>.from(map['contentByCategory'] ?? {}),
      usersByRole: Map<String, int>.from(map['usersByRole'] ?? {}),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalContent': totalContent,
      'totalMedia': totalMedia,
      'activeUsers': activeUsers,
      'storageUsed': storageUsed,
      'contentByCategory': contentByCategory,
      'usersByRole': usersByRole,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}

class AdminLog {
  final String id;
  final String action;
  final String description;
  final String adminId;
  final String adminName;
  final String targetType; // 'user', 'content', 'media', etc.
  final String? targetId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AdminLog({
    required this.id,
    required this.action,
    required this.description,
    required this.adminId,
    required this.adminName,
    required this.targetType,
    this.targetId,
    required this.timestamp,
    this.metadata,
  });

  factory AdminLog.fromMap(Map<String, dynamic> map, String id) {
    return AdminLog(
      id: id,
      action: map['action'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      targetType: map['targetType'] ?? '',
      targetId: map['targetId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'description': description,
      'adminId': adminId,
      'adminName': adminName,
      'targetType': targetType,
      'targetId': targetId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }
}