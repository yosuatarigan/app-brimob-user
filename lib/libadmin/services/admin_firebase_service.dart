import 'package:app_brimob_user/libadmin/models/admin_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AdminFirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<UserCredential?> signInAsAdmin(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify admin role
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        if (userData['role'] != 'admin') {
          await _auth.signOut();
          throw Exception('Unauthorized: Admin access required');
        }
        
        // Update last login
        await userDoc.reference.update({
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
        });
        
        return credential;
      } else {
        await _auth.signOut();
        throw Exception('User data not found');
      }
    } catch (e) {
      throw Exception('Admin login failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Analytics & Dashboard
  static Future<AppAnalytics> getAnalytics() async {
    try {
      // Get counts from collections
      final usersSnapshot = await _firestore.collection('users').get();
      final contentSnapshot = await _firestore.collection('content').get();
      final mediaSnapshot = await _firestore.collection('media').get();
      
      // Count active users (logged in within last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activeUsersSnapshot = await _firestore
          .collection('users')
          .where('lastLogin', isGreaterThan: thirtyDaysAgo.millisecondsSinceEpoch)
          .get();

      // Count content by category
      Map<String, int> contentByCategory = {};
      for (var doc in contentSnapshot.docs) {
        final category = doc.data()['category'] ?? 'other';
        contentByCategory[category] = (contentByCategory[category] ?? 0) + 1;
      }

      // Count users by role
      Map<String, int> usersByRole = {};
      for (var doc in usersSnapshot.docs) {
        final role = doc.data()['role'] ?? 'public';
        usersByRole[role] = (usersByRole[role] ?? 0) + 1;
      }

      // Calculate storage usage (estimate)
      int storageUsed = 0;
      for (var doc in mediaSnapshot.docs) {
        storageUsed += (doc.data()['fileSize'] ?? 0) as int;
      }

      return AppAnalytics(
        id: 'analytics_${DateTime.now().millisecondsSinceEpoch}',
        totalUsers: usersSnapshot.docs.length,
        totalContent: contentSnapshot.docs.length,
        totalMedia: mediaSnapshot.docs.length,
        activeUsers: activeUsersSnapshot.docs.length,
        storageUsed: storageUsed,
        contentByCategory: contentByCategory,
        usersByRole: usersByRole,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error fetching analytics: ${e.toString()}');
    }
  }

  // Content Management
  static Future<List<ContentItem>> getAllContent() async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContentItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching content: ${e.toString()}');
    }
  }

  static Future<void> createContent(ContentItem content) async {
    try {
      await _firestore.collection('content').add(content.toMap());
      await _logAdminAction(
        'CREATE_CONTENT',
        'Created content: ${content.title}',
        'content',
        null,
      );
    } catch (e) {
      throw Exception('Error creating content: ${e.toString()}');
    }
  }

  static Future<void> updateContent(String contentId, ContentItem content) async {
    try {
      await _firestore
          .collection('content')
          .doc(contentId)
          .update(content.toMap());
      
      await _logAdminAction(
        'UPDATE_CONTENT',
        'Updated content: ${content.title}',
        'content',
        contentId,
      );
    } catch (e) {
      throw Exception('Error updating content: ${e.toString()}');
    }
  }

  static Future<void> deleteContent(String contentId) async {
    try {
      final doc = await _firestore.collection('content').doc(contentId).get();
      final title = doc.data()?['title'] ?? 'Unknown';
      
      await _firestore.collection('content').doc(contentId).delete();
      
      await _logAdminAction(
        'DELETE_CONTENT',
        'Deleted content: $title',
        'content',
        contentId,
      );
    } catch (e) {
      throw Exception('Error deleting content: ${e.toString()}');
    }
  }

  // User Management
  static Future<List<AdminUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AdminUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching users: ${e.toString()}');
    }
  }

  static Future<void> createUser(String email, String password, String name, String role) async {
    try {
      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      final user = AdminUser(
        uid: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      await _logAdminAction(
        'CREATE_USER',
        'Created user: $name ($email) with role: $role',
        'user',
        credential.user!.uid,
      );
    } catch (e) {
      throw Exception('Error creating user: ${e.toString()}');
    }
  }

  static Future<void> updateUser(String userId, AdminUser user) async {
    try {
      await _firestore.collection('users').doc(userId).update(user.toMap());
      
      await _logAdminAction(
        'UPDATE_USER',
        'Updated user: ${user.name}',
        'user',
        userId,
      );
    } catch (e) {
      throw Exception('Error updating user: ${e.toString()}');
    }
  }

  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      await _logAdminAction(
        'TOGGLE_USER_STATUS',
        'User status changed to: ${isActive ? "Active" : "Inactive"}',
        'user',
        userId,
      );
    } catch (e) {
      throw Exception('Error updating user status: ${e.toString()}');
    }
  }

  // Media Management
  static Future<List<MediaFile>> getAllMedia() async {
    try {
      final snapshot = await _firestore
          .collection('media')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MediaFile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching media: ${e.toString()}');
    }
  }

  static Future<String> uploadMedia(File file, String fileName, String? description) async {
    try {
      final ref = _storage.ref().child('media/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save media info to Firestore
      final mediaFile = MediaFile(
        id: '',
        fileName: fileName,
        fileUrl: downloadUrl,
        fileType: _getFileType(fileName),
        fileSize: await file.length(),
        uploadedAt: DateTime.now(),
        uploadedBy: currentUser!.uid,
        description: description,
        tags: [],
        isUsed: false,
      );

      await _firestore.collection('media').add(mediaFile.toMap());

      await _logAdminAction(
        'UPLOAD_MEDIA',
        'Uploaded media: $fileName',
        'media',
        null,
      );

      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading media: ${e.toString()}');
    }
  }

  static Future<void> deleteMedia(String mediaId, String fileUrl) async {
    try {
      // Delete from Storage
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();

      // Delete from Firestore
      await _firestore.collection('media').doc(mediaId).delete();

      await _logAdminAction(
        'DELETE_MEDIA',
        'Deleted media file',
        'media',
        mediaId,
      );
    } catch (e) {
      throw Exception('Error deleting media: ${e.toString()}');
    }
  }

  // Gallery Management
  static Future<List<GalleryItem>> getAllGallery() async {
    try {
      final snapshot = await _firestore
          .collection('galeri')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => GalleryItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching gallery: ${e.toString()}');
    }
  }

  static Future<void> createGalleryItem(GalleryItem item) async {
    try {
      await _firestore.collection('galeri').add(item.toMap());
      
      await _logAdminAction(
        'CREATE_GALLERY',
        'Created gallery item: ${item.name}',
        'gallery',
        null,
      );
    } catch (e) {
      throw Exception('Error creating gallery item: ${e.toString()}');
    }
  }

  static Future<void> updateGalleryItem(String itemId, GalleryItem item) async {
    try {
      await _firestore.collection('galeri').doc(itemId).update(item.toMap());
      
      await _logAdminAction(
        'UPDATE_GALLERY',
        'Updated gallery item: ${item.name}',
        'gallery',
        itemId,
      );
    } catch (e) {
      throw Exception('Error updating gallery item: ${e.toString()}');
    }
  }

  // Settings Management
  static Future<void> updateAppSetting(String key, Map<String, dynamic> value) async {
    try {
      await _firestore.collection('settings').doc(key).set(value);
      
      await _logAdminAction(
        'UPDATE_SETTINGS',
        'Updated app setting: $key',
        'settings',
        key,
      );
    } catch (e) {
      throw Exception('Error updating settings: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>?> getAppSetting(String key) async {
    try {
      final doc = await _firestore.collection('settings').doc(key).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Error fetching setting: ${e.toString()}');
    }
  }

  // Admin Logs
  static Future<void> _logAdminAction(
    String action,
    String description,
    String targetType,
    String? targetId,
  ) async {
    try {
      if (!isLoggedIn) return;

      final log = AdminLog(
        id: '',
        action: action,
        description: description,
        adminId: currentUser!.uid,
        adminName: currentUser!.email ?? 'Unknown',
        targetType: targetType,
        targetId: targetId,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('admin_logs').add(log.toMap());
    } catch (e) {
      // Don't throw error for logging failures
      print('Error logging admin action: $e');
    }
  }

  static Future<List<AdminLog>> getAdminLogs({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AdminLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching admin logs: ${e.toString()}');
    }
  }

  // Helper methods
  static String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'video';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'document';
      default:
        return 'file';
    }
  }
}