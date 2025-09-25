import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto(File imageFile, String userId) async {
    try {
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('profile_photos').child(fileName);
      
      // Compress and upload image
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal mengupload foto profil: ${e.toString()}');
    }
  }

  // Delete profile photo from Firebase Storage
  Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      if (photoUrl.contains('firebasestorage.googleapis.com')) {
        await _storage.refFromURL(photoUrl).delete();
      }
    } catch (e) {
      print('Error deleting profile photo: $e');
      // Don't throw error for deletion failures
    }
  }

  // Register with email and password (updated with complete personnel data)
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String nrp,
    
    // Basic info
    String? rank,
    String? jabatan,
    DateTime? jabatanTmt,
    UserRole? role,
    String? photoUrl,
    
    // Personal data
    String? tempatLahir,
    DateTime? dateOfBirth,
    String? agama,
    String? suku,
    String? statusPersonel,
    DateTime? militaryJoinDate,
    
    // Contact info
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? bloodType,
    String? maritalStatus,
    
    // Complex data arrays
    List<PendidikanKepolisian>? pendidikanKepolisian,
    List<PendidikanUmum>? pendidikanUmum,
    List<RiwayatPangkat>? riwayatPangkat,
    List<RiwayatJabatan>? riwayatJabatan,
    List<PendidikanPelatihan>? pendidikanPelatihan,
    List<TandaKehormatan>? tandaKehormatan,
    List<KemampuanBahasa>? kemampuanBahasa,
    List<PenugasanLuarStruktur>? penugasanLuarStruktur,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        UserModel userModel = UserModel(
          id: user.uid,
          email: email,
          fullName: fullName,
          nrp: nrp,
          rank: rank ?? '',
          jabatan: jabatan ?? '',
          jabatanTmt: jabatanTmt,
          role: role ?? UserRole.other,
          status: UserStatus.pending, // Default status
          photoUrl: photoUrl,
          
          // Personal data
          tempatLahir: tempatLahir,
          dateOfBirth: dateOfBirth,
          agama: agama,
          suku: suku,
          statusPersonel: statusPersonel,
          militaryJoinDate: militaryJoinDate,
          
          // Contact info
          phoneNumber: phoneNumber,
          address: address,
          emergencyContact: emergencyContact,
          bloodType: bloodType,
          maritalStatus: maritalStatus,
          
          // System fields
          createdAt: DateTime.now(),
          
          // Complex arrays (default empty if not provided)
          pendidikanKepolisian: pendidikanKepolisian ?? [],
          pendidikanUmum: pendidikanUmum ?? [],
          riwayatPangkat: riwayatPangkat ?? [],
          riwayatJabatan: riwayatJabatan ?? [],
          pendidikanPelatihan: pendidikanPelatihan ?? [],
          tandaKehormatan: tandaKehormatan ?? [],
          kemampuanBahasa: kemampuanBahasa ?? [],
          penugasanLuarStruktur: penugasanLuarStruktur ?? [],
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());

        return {
          'success': true,
          'message': 'Pendaftaran berhasil. Silahkan tunggu persetujuan admin.',
          'user': userModel,
        };
      }

      return {
        'success': false,
        'message': 'Gagal membuat akun',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah digunakan';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Get user data from Firestore
        UserModel? userData = await getUserData(user.uid);
        
        if (userData != null) {
          // Check if user is approved
          if (userData.status == UserStatus.approved) {
            return {
              'success': true,
              'message': 'Login berhasil',
              'user': userData,
            };
          } else if (userData.status == UserStatus.pending) {
            await _auth.signOut(); // Sign out user
            return {
              'success': false,
              'message': 'Akun Anda masih menunggu persetujuan admin',
              'isPending': true,
            };
          } else {
            await _auth.signOut(); // Sign out user
            return {
              'success': false,
              'message': 'Akun Anda ditolak oleh admin',
            };
          }
        }
      }

      return {
        'success': false,
        'message': 'Data pengguna tidak ditemukan',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Pengguna tidak ditemukan';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          errorMessage = 'Akun telah dinonaktifkan';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Email reset password telah dikirim',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Update user profile photo
  Future<Map<String, dynamic>> updateProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Get current user data
      final userData = await getUserData(userId);
      if (userData == null) {
        return {
          'success': false,
          'message': 'Data pengguna tidak ditemukan',
        };
      }

      // Delete old photo if exists
      if (userData.photoUrl != null) {
        await deleteProfilePhoto(userData.photoUrl!);
      }

      // Upload new photo
      final newPhotoUrl = await uploadProfilePhoto(imageFile, userId);

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': newPhotoUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return {
        'success': true,
        'message': 'Foto profil berhasil diperbarui',
        'photoUrl': newPhotoUrl,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui foto profil: ${e.toString()}',
      };
    }
  }

  // Update user profile data
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    UserModel? updatedUser,
    Map<String, dynamic>? updates,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (updatedUser != null) {
        updateData = updatedUser.toFirestore();
      } else if (updates != null) {
        updateData = updates;
      }

      updateData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore.collection('users').doc(userId).update(updateData);

      return {
        'success': true,
        'message': 'Data berhasil diperbarui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui data: ${e.toString()}',
      };
    }
  }

  // Get all users for admin
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Get users by status
  Stream<List<UserModel>> getUsersByStatus(UserStatus status) {
    return _firestore
        .collection('users')
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Search by name
      final nameQuery = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query.toUpperCase())
          .where('fullName', isLessThanOrEqualTo: query.toUpperCase() + '\uf8ff')
          .get();

      // Search by NRP
      final nrpQuery = await _firestore
          .collection('users')
          .where('nrp', isGreaterThanOrEqualTo: query)
          .where('nrp', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Combine results and remove duplicates
      Set<String> seenIds = {};
      List<UserModel> results = [];

      for (var doc in nameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(UserModel.fromFirestore(doc));
        }
      }

      for (var doc in nrpQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(UserModel.fromFirestore(doc));
        }
      }

      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Approve user
  Future<Map<String, dynamic>> approveUser(String userId, String adminId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.approved.name,
        'approvedBy': adminId,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return {
        'success': true,
        'message': 'User berhasil disetujui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menyetujui user: ${e.toString()}',
      };
    }
  }

  // Reject user
  Future<Map<String, dynamic>> rejectUser(String userId, String adminId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.rejected.name,
        'approvedBy': adminId,
        'rejectionReason': reason,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return {
        'success': true,
        'message': 'User berhasil ditolak',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menolak user: ${e.toString()}',
      };
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      // Get user data first to delete photo
      final userData = await getUserData(userId);
      if (userData?.photoUrl != null) {
        await deleteProfilePhoto(userData!.photoUrl!);
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      return {
        'success': true,
        'message': 'User berhasil dihapus',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus user: ${e.toString()}',
      };
    }
  }
}