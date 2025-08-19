import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth Methods
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Content Methods
  static Future<List<ContentModel>> getPublicContent() async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching content: ${e.toString()}');
    }
  }

  static Future<ContentModel?> getContentByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ContentModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching content: ${e.toString()}');
    }
  }

  static Future<List<GaleriModel>> getGaleriSatuan() async {
    try {
      final snapshot = await _firestore
          .collection('galeri')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => GaleriModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching galeri: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>?> getSettings(String key) async {
    try {
      final doc = await _firestore.collection('settings').doc(key).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Error fetching settings: ${e.toString()}');
    }
  }

  // Check user role for BINKAR access
  static Future<bool> hasAccessToBinkar() async {
    if (!isLoggedIn) return false;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return userData['role'] == 'binkar' || userData['role'] == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}