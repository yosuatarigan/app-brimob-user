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

  // Register with email and password (updated with photo support)
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
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
          rank: rank,
          role: role,
          status: UserStatus.pending, // Default status
          photoUrl: photoUrl, // Include photo URL
          dateOfBirth: dateOfBirth,
          militaryJoinDate: militaryJoinDate,
          createdAt: DateTime.now(),
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
}