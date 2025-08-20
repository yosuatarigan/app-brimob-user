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
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching content: ${e.toString()}');
    }
  }

  // Method lama - untuk single content (deprecated)
  static Future<ContentModel?> getContentByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .where('category', isEqualTo: category)
          .where('isPublic', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
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

  // Method baru - untuk multiple content berdasarkan kategori
  static Future<List<ContentModel>> getContentsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .where('category', isEqualTo: category)
          .where('isPublic', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching content: ${e.toString()}');
    }
  }

  // Method untuk BINKAR content (memerlukan autentikasi)
  static Future<List<ContentModel>> getBinkarContentsByCategory(String category) async {
    try {
      // Cek apakah user memiliki akses BINKAR
      final hasAccess = await hasAccessToBinkar();
      if (!hasAccess) {
        throw Exception('Access denied: BINKAR access required');
      }

      final snapshot = await _firestore
          .collection('content')
          .where('category', isEqualTo: category)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching BINKAR content: ${e.toString()}');
    }
  }

  // Method untuk mendapatkan content berdasarkan ID
  static Future<ContentModel?> getContentById(String contentId) async {
    try {
      final doc = await _firestore
          .collection('content')
          .doc(contentId)
          .get();

      if (doc.exists) {
        return ContentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching content: ${e.toString()}');
    }
  }

  // Method untuk search content
  static Future<List<ContentModel>> searchContent(String query) async {
    try {
      // Search by title
      final titleSnapshot = await _firestore
          .collection('content')
          .where('isPublic', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      // Search by content (simple contains - note: ini tidak efisien untuk database besar)
      final contentSnapshot = await _firestore
          .collection('content')
          .where('isPublic', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .get();

      List<ContentModel> results = [];
      
      // Add title matches
      results.addAll(
        titleSnapshot.docs.map((doc) => ContentModel.fromMap(doc.data(), doc.id))
      );

      // Add content matches (filter manually)
      final contentResults = contentSnapshot.docs
          .where((doc) {
            final data = doc.data();
            final content = data['content']?.toString().toLowerCase() ?? '';
            return content.contains(query.toLowerCase()) && 
                   !results.any((r) => r.id == doc.id); // Avoid duplicates
          })
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id));

      results.addAll(contentResults);

      return results;
    } catch (e) {
      throw Exception('Error searching content: ${e.toString()}');
    }
  }

  // Method untuk mendapatkan content terbaru
  static Future<List<ContentModel>> getLatestContent({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('content')
          .where('isPublic', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching latest content: ${e.toString()}');
    }
  }

  // Method untuk increment view count
  static Future<void> incrementContentView(String contentId) async {
    try {
      await _firestore
          .collection('content')
          .doc(contentId)
          .update({
        'viewCount': FieldValue.increment(1),
        'lastViewed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore error - view count is not critical
      print('Error incrementing view count: ${e.toString()}');
    }
  }

  // Galeri Methods
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

  // Settings Methods
  static Future<Map<String, dynamic>?> getSettings(String key) async {
    try {
      final doc = await _firestore.collection('settings').doc(key).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Error fetching settings: ${e.toString()}');
    }
  }

  // User Methods
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

  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isLoggedIn) return null;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      return null;
    }
  }

  // Analytics Methods
  static Future<void> logUserActivity(String activity, Map<String, dynamic>? data) async {
    if (!isLoggedIn) return;
    
    try {
      await _firestore
          .collection('user_activity')
          .add({
        'userId': currentUser!.uid,
        'activity': activity,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore error - analytics is not critical
      print('Error logging user activity: ${e.toString()}');
    }
  }
}