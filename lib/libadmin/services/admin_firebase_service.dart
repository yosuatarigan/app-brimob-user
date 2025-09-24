import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../models/admin_model.dart';
import '../../slide_show_model.dart';

class AdminFirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final CollectionReference _slideshowCollection = _firestore.collection('slideshow');

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
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        
        // Check for admin role - support both old system and new UserModel
        bool isAdmin = false;
        
        // Check old admin system
        if (userData['role'] == 'admin') {
          isAdmin = true;
        }
        
        // Check new UserModel system - admin emails
        final userModel = UserModel.fromFirestore(userDoc);
        if (userModel.email == 'admin@korbrimob.polri.go.id' || 
            userModel.email.endsWith('@admin.korbrimob.polri.go.id')) {
          isAdmin = true;
        }

        if (!isAdmin) {
          await _auth.signOut();
          throw Exception('Unauthorized: Admin access required');
        }

        // Update last login
        await userDoc.reference.update({
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
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

      // Count active users (approved status for UserModel, or active for old AdminUser)
      int activeUsers = 0;
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        // Check new UserModel system
        if (data.containsKey('status')) {
          if (data['status'] == 'approved') activeUsers++;
        }
        // Check old AdminUser system
        else if (data.containsKey('isActive')) {
          if (data['isActive'] == true) activeUsers++;
        }
      }

      // Count content by category
      Map<String, int> contentByCategory = {};
      for (var doc in contentSnapshot.docs) {
        final category = doc.data()['category'] ?? 'other';
        contentByCategory[category] = (contentByCategory[category] ?? 0) + 1;
      }

      // Count users by role
      Map<String, int> usersByRole = {};
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        String role = 'public';
        
        // Check new UserModel system
        if (data.containsKey('status')) {
          final userModel = UserModel.fromFirestore(doc);
          role = userModel.role.displayName;
        }
        // Check old AdminUser system
        else if (data.containsKey('role')) {
          role = data['role'] ?? 'public';
        }
        
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
        activeUsers: activeUsers,
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

  // User Management - Supporting both new UserModel and old AdminUser
  static Future<List<UserModel>> getAllUsersWithApproval() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching users: ${e.toString()}');
    }
  }

  // Legacy method for old AdminUser system
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

  // Get pending users only (UserModel system)
  static Future<List<UserModel>> getPendingUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching pending users: ${e.toString()}');
    }
  }

  // NEW: Create user dengan separate Firebase app instance (tidak mengganggu admin session)
  static Future<Map<String, dynamic>> createUserWithSeparateAuth({
    required String email,
    required String password,
    required String fullName,
    required String nrp,
    required String rank,
    required UserRole role,
    required DateTime dateOfBirth,
    required DateTime militaryJoinDate,
    String? photoUrl,
  }) async {
    FirebaseApp? tempApp;
    
    try {
      // Create temporary Firebase app instance
      tempApp = await Firebase.initializeApp(
        name: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      // Create user with temporary app instance
      final UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create UserModel document dengan status approved (admin created)
        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          fullName: fullName,
          nrp: nrp,
          rank: rank,
          role: role,
          status: UserStatus.approved, // Auto-approved for admin created users
          photoUrl: photoUrl,
          dateOfBirth: dateOfBirth,
          militaryJoinDate: militaryJoinDate,
          createdAt: DateTime.now(),
          approvedBy: currentUser?.uid,
          approvedAt: DateTime.now(),
        );

        // Save to Firestore using main app instance
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toFirestore());

        // Log admin action
        await _logAdminAction(
          'CREATE_USER',
          'Created user: $fullName ($email) with role: ${role.displayName}',
          'user',
          userCredential.user!.uid,
        );

        return {
          'success': true,
          'message': 'User $fullName berhasil dibuat dan disetujui',
          'user': newUser,
        };
      }

      return {
        'success': false,
        'message': 'Gagal membuat user',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah digunakan oleh akun lain';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Pendaftaran email/password tidak diizinkan';
          break;
        default:
          errorMessage = 'Error Firebase Auth: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    } finally {
      // Clean up: delete temporary app instance
      if (tempApp != null) {
        try {
          await tempApp.delete();
        } catch (e) {
          print('Error deleting temp app: $e');
        }
      }
    }
  }

  // Simple delete user - menghapus dari Auth dan Firestore
  static Future<void> deleteUserCompletely(String userId) async {
    FirebaseApp? tempApp;
    
    try {
      // Get user data first
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = userDoc.data()!;
      final userEmail = userData['email'] ?? '';
      final userPassword = userData['password_akun'] ?? userData['password'] ?? '';
      
      if (userEmail.isEmpty || userPassword.isEmpty) {
        throw Exception('Email or password not found for user deletion');
      }

      // Create Firebase app instance
      tempApp = await Firebase.initializeApp(
        name: userEmail,
        options: Firebase.app().options,
      );

      // Sign in as user
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Get current user and delete
      User usernya = FirebaseAuth.instanceFor(app: tempApp).currentUser!;
      await usernya.delete();

      // Delete from Firestore
      await userDoc.reference.delete();

      await _logAdminAction(
        'DELETE_USER_COMPLETELY',
        'Deleted user: $userEmail from Authentication and Firestore',
        'user',
        userId,
      );

    } catch (e) {
      throw Exception('Error deleting user: ${e.toString()}');
    } finally {
      // Clean up temp app
      if (tempApp != null) {
        try {
          await tempApp.delete();
        } catch (e) {
          print('Error cleaning up temp app: $e');
        }
      }
    }
  }



  // Alternative: Disable user account instead of delete from Auth
  static Future<void> disableUserAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.rejected.name,
        'rejectionReason': 'Account disabled by admin',
        'isActive': false,
        'disabledAt': Timestamp.fromDate(DateTime.now()),
        'disabledBy': currentUser?.uid,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await _logAdminAction(
        'DISABLE_USER',
        'Disabled user account (user cannot login but auth account remains)',
        'user',
        userId,
      );
    } catch (e) {
      throw Exception('Error disabling user: ${e.toString()}');
    }
  }

  // NEW: Helper method untuk check if user exists in Auth
  static Future<bool> checkUserExistsInAuth(String email) async {
    FirebaseApp? tempApp;
    
    try {
      tempApp = await Firebase.initializeApp(
        name: 'temp_check_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      
      // Try to send password reset email to check if user exists
      await tempAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      }
      // For other errors, assume user exists
      return true;
    } catch (e) {
      return false;
    } finally {
      if (tempApp != null) {
        try {
          await tempApp.delete();
        } catch (e) {
          print('Error deleting temp app: $e');
        }
      }
    }
  }

  // Approve user
  static Future<void> approveUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.approved.name,
        'approvedBy': currentUser?.uid,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'rejectionReason': null, // Clear any previous rejection reason
      });

      await _logAdminAction(
        'APPROVE_USER',
        'Approved user registration',
        'user',
        userId,
      );

      // Send approval notification email (optional)
      await _sendApprovalNotification(userId, true);
    } catch (e) {
      throw Exception('Error approving user: ${e.toString()}');
    }
  }

  // Reject user
  static Future<void> rejectUser(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.rejected.name,
        'rejectionReason': reason,
        'approvedBy': currentUser?.uid,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await _logAdminAction(
        'REJECT_USER',
        'Rejected user registration: $reason',
        'user',
        userId,
      );

      // Send rejection notification email (optional)
      await _sendApprovalNotification(userId, false, reason);
    } catch (e) {
      throw Exception('Error rejecting user: ${e.toString()}');
    }
  }

  // Bulk approve users
  static Future<void> bulkApproveUsers(List<String> userIds) async {
    try {
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      final adminId = currentUser?.uid;

      for (final userId in userIds) {
        batch.update(_firestore.collection('users').doc(userId), {
          'status': UserStatus.approved.name,
          'approvedBy': adminId,
          'approvedAt': now,
          'updatedAt': now,
          'rejectionReason': null,
        });
      }

      await batch.commit();

      await _logAdminAction(
        'BULK_APPROVE_USERS',
        'Bulk approved ${userIds.length} users',
        'user',
        null,
      );
    } catch (e) {
      throw Exception('Error bulk approving users: ${e.toString()}');
    }
  }

  // Bulk reject users
  static Future<void> bulkRejectUsers(List<String> userIds, String reason) async {
    try {
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      final adminId = currentUser?.uid;

      for (final userId in userIds) {
        batch.update(_firestore.collection('users').doc(userId), {
          'status': UserStatus.rejected.name,
          'rejectionReason': reason,
          'approvedBy': adminId,
          'approvedAt': now,
          'updatedAt': now,
        });
      }

      await batch.commit();

      await _logAdminAction(
        'BULK_REJECT_USERS',
        'Bulk rejected ${userIds.length} users: $reason',
        'user',
        null,
      );
    } catch (e) {
      throw Exception('Error bulk rejecting users: ${e.toString()}');
    }
  }

  // NEW: Batch delete users (with auth deletion)
  static Future<void> batchDeleteUsers(List<String> userIds) async {
    final List<String> failedDeletions = [];
    
    for (final userId in userIds) {
      try {
        await deleteUserCompletely(userId);
      } catch (e) {
        failedDeletions.add(userId);
        print('Failed to delete user $userId: $e');
      }
    }

    await _logAdminAction(
      'BATCH_DELETE_USERS',
      'Batch deleted ${userIds.length - failedDeletions.length}/${userIds.length} users',
      'user',
      null,
    );

    if (failedDeletions.isNotEmpty) {
      throw Exception('Failed to delete ${failedDeletions.length} users: ${failedDeletions.join(', ')}');
    }
  }

  // Get user by ID (UserModel)
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: ${e.toString()}');
    }
  }

  // Legacy create user method for AdminUser system
  static Future<void> createUser(
    String email,
    String password,
    String name,
    String role,
  ) async {
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

  // Update user (AdminUser system)
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

  // Update user (UserModel system)
  static Future<void> updateUserModel(String userId, UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updatedUser.toFirestore());

      await _logAdminAction(
        'UPDATE_USER',
        'Updated user: ${user.fullName}',
        'user',
        userId,
      );
    } catch (e) {
      throw Exception('Error updating user: ${e.toString()}');
    }
  }

  // Toggle user status (legacy AdminUser system)
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

  // Updated delete user method to use complete deletion
  static Future<void> deleteUser(String userId) async {
    await deleteUserCompletely(userId);
  }

  // Reset user password
  static Future<void> resetUserPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      await _logAdminAction(
        'RESET_PASSWORD',
        'Sent password reset email to: $email',
        'user',
        null,
      );
    } catch (e) {
      throw Exception('Error sending password reset email: ${e.toString()}');
    }
  }

  // Send approval/rejection notification
  static Future<void> _sendApprovalNotification(String userId, bool approved, [String? reason]) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return;

      // Here you can implement email notification
      // For now, we'll just log it
      final status = approved ? 'approved' : 'rejected';
      print('Notification sent to ${user.email}: Account $status');
      
      if (!approved && reason != null) {
        print('Rejection reason: $reason');
      }

      // You can integrate with email service like SendGrid, Firebase Functions, etc.
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Get approval statistics
  static Future<Map<String, dynamic>> getApprovalStatistics() async {
    try {
      final allUsers = await getAllUsersWithApproval();
      
      final totalUsers = allUsers.length;
      final pendingUsers = allUsers.where((u) => u.status == UserStatus.pending).length;
      final approvedUsers = allUsers.where((u) => u.status == UserStatus.approved).length;
      final rejectedUsers = allUsers.where((u) => u.status == UserStatus.rejected).length;

      // Statistics by role
      final usersByRole = <String, int>{};
      for (final role in UserRole.values) {
        usersByRole[role.displayName] = allUsers.where((u) => u.role == role).length;
      }

      // Recent registrations (last 7 days)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentRegistrations = allUsers
          .where((u) => u.createdAt.isAfter(sevenDaysAgo))
          .length;

      return {
        'totalUsers': totalUsers,
        'pendingUsers': pendingUsers,
        'approvedUsers': approvedUsers,
        'rejectedUsers': rejectedUsers,
        'usersByRole': usersByRole,
        'recentRegistrations': recentRegistrations,
        'approvalRate': totalUsers > 0 ? (approvedUsers / totalUsers * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Error getting approval statistics: ${e.toString()}');
    }
  }

  // NEW: Get user statistics with auth status
  static Future<Map<String, dynamic>> getUserStatisticsWithAuth() async {
    try {
      final allUsers = await getAllUsersWithApproval();
      final stats = await getApprovalStatistics();
      
      int authActiveUsers = 0;
      int orphanedUsers = 0;
      
      for (final user in allUsers) {
        final existsInAuth = await checkUserExistsInAuth(user.email);
        if (existsInAuth) {
          authActiveUsers++;
        } else {
          orphanedUsers++;
        }
      }

      return {
        ...stats,
        'authActiveUsers': authActiveUsers,
        'orphanedUsers': orphanedUsers,
        'authSyncStatus': orphanedUsers == 0 ? 'synced' : 'has_orphans',
      };
    } catch (e) {
      throw Exception('Error getting user statistics with auth: ${e.toString()}');
    }
  }

  // NEW: Clean up orphaned users (exists in Firestore but not in Auth)
  static Future<List<UserModel>> findOrphanedUsers() async {
    try {
      final allUsers = await getAllUsersWithApproval();
      final orphanedUsers = <UserModel>[];

      for (final user in allUsers) {
        final existsInAuth = await checkUserExistsInAuth(user.email);
        if (!existsInAuth) {
          orphanedUsers.add(user);
        }
      }

      return orphanedUsers;
    } catch (e) {
      throw Exception('Error finding orphaned users: ${e.toString()}');
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

  static Future<String> uploadMedia(
    File file,
    String fileName,
    String? description,
  ) async {
    try {
      final ref = _storage.ref().child(
        'media/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
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
      final snapshot = await _firestore.collection('galeri').orderBy('order').get();

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

  // Slideshow Management
  static Future<List<SlideshowItem>> getSlideshowItems() async {
    try {
      final querySnapshot = await _slideshowCollection.orderBy('order').get();

      return querySnapshot.docs
          .map(
            (doc) => SlideshowItem.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting slideshow items: $e');
      throw Exception('Failed to load slideshow items: $e');
    }
  }

  // Add new slideshow item
  static Future<void> addSlideshowItem(SlideshowItem item) async {
    try {
      // Get the next order number
      final existingItems = await getSlideshowItems();
      final maxOrder = existingItems.isEmpty
          ? 0
          : existingItems.map((e) => e.order).reduce((a, b) => a > b ? a : b);

      final newItem = item.copyWith(
        order: maxOrder + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _slideshowCollection.doc(item.id).set(newItem.toJson());
    } catch (e) {
      print('Error adding slideshow item: $e');
      throw Exception('Failed to add slideshow item: $e');
    }
  }

  // Update slideshow item
  static Future<void> updateSlideshowItem(SlideshowItem item) async {
    try {
      final updatedItem = item.copyWith(updatedAt: DateTime.now());
      await _slideshowCollection.doc(item.id).update(updatedItem.toJson());
    } catch (e) {
      print('Error updating slideshow item: $e');
      throw Exception('Failed to update slideshow item: $e');
    }
  }

  // Delete slideshow item
  static Future<void> deleteSlideshowItem(String itemId) async {
    try {
      // Get the item first to delete the image from storage if it's uploaded
      final doc = await _slideshowCollection.doc(itemId).get();
      if (doc.exists) {
        final item = SlideshowItem.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        // Delete image from storage if it's a Firebase Storage URL
        if (item.imageUrl.contains('firebasestorage.googleapis.com')) {
          try {
            await _storage.refFromURL(item.imageUrl).delete();
          } catch (e) {
            print('Error deleting image from storage: $e');
            // Continue with document deletion even if image deletion fails
          }
        }
      }

      await _slideshowCollection.doc(itemId).delete();

      // Reorder remaining items
      await _reorderAfterDeletion();
    } catch (e) {
      print('Error deleting slideshow item: $e');
      throw Exception('Failed to delete slideshow item: $e');
    }
  }

  // Update slideshow order
  static Future<void> updateSlideshowOrder(List<SlideshowItem> orderedItems) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < orderedItems.length; i++) {
        final item = orderedItems[i].copyWith(
          order: i,
          updatedAt: DateTime.now(),
        );
        batch.update(_slideshowCollection.doc(item.id), {
          'order': item.order,
          'updatedAt': item.updatedAt?.millisecondsSinceEpoch,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error updating slideshow order: $e');
      throw Exception('Failed to update slideshow order: $e');
    }
  }

  // Upload slideshow image
  static Future<String> uploadSlideshowImage(File imageFile) async {
    try {
      final fileName = 'slideshow_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('slideshow').child(fileName);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': 'admin',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading slideshow image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete slideshow image from storage
  static Future<void> deleteSlideshowImage(String imageUrl) async {
    try {
      if (imageUrl.contains('firebasestorage.googleapis.com')) {
        await _storage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      print('Error deleting slideshow image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  // Private method to reorder items after deletion
  static Future<void> _reorderAfterDeletion() async {
    try {
      final items = await getSlideshowItems();
      if (items.isNotEmpty) {
        await updateSlideshowOrder(items);
      }
    } catch (e) {
      print('Error reordering after deletion: $e');
    }
  }

  // Get slideshow analytics
  static Future<Map<String, dynamic>> getSlideshowAnalytics() async {
    try {
      final items = await getSlideshowItems();
      final activeCount = items.where((item) => item.isActive).length;
      final inactiveCount = items.length - activeCount;

      return {
        'totalItems': items.length,
        'activeItems': activeCount,
        'inactiveItems': inactiveCount,
        'lastUpdated': items.isNotEmpty
            ? items
                .where((item) => item.updatedAt != null)
                .map((item) => item.updatedAt!)
                .reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      };
    } catch (e) {
      print('Error getting slideshow analytics: $e');
      return {
        'totalItems': 0,
        'activeItems': 0,
        'inactiveItems': 0,
        'lastUpdated': null,
      };
    }
  }

  // Bulk update slideshow status
  static Future<void> bulkUpdateSlideshowStatus(
    List<String> itemIds,
    bool isActive,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final itemId in itemIds) {
        batch.update(_slideshowCollection.doc(itemId), {
          'isActive': isActive,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error bulk updating slideshow status: $e');
      throw Exception('Failed to bulk update slideshow status: $e');
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