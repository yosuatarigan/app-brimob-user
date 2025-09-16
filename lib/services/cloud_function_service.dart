import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notification_model.dart';

class CloudFunctionService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get fresh ID token for authentication
  static Future<String?> _getIdToken() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No current user for token');
        return null;
      }
      
      final String? token = await currentUser.getIdToken(true); // Force refresh
      print('Got ID token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  /// Test koneksi Cloud Functions dengan proper auth
  static Future<Map<String, dynamic>?> testConnection() async {
    try {
      print('Testing Cloud Functions connection...');
      
      // Ensure user is authenticated and get token
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User not authenticated');
        return null;
      }
      
      // Get fresh ID token
      final String? token = await _getIdToken();
      if (token == null) {
        print('Failed to get ID token');
        return null;
      }
      
      print('Making authenticated call...');
      
      // Make authenticated call
      final HttpsCallable callable = _functions.httpsCallable('testFirestore');
      final HttpsCallableResult result = await callable.call();
      
      print('Test connection result: ${result.data}');
      return result.data;
    } catch (e) {
      print('Test connection error: $e');
      if (e is FirebaseFunctionsException) {
        print('Functions Exception Code: ${e.code}');
        print('Functions Exception Message: ${e.message}');
      }
      return null;
    }
  }

  /// Test Firestore connection via Cloud Functions dengan auth fix
  static Future<Map<String, dynamic>?> testFirestore() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User not authenticated for Firestore test');
        return null;
      }

      print('Testing Firestore via Cloud Functions...');
      print('Current user ID: ${currentUser.uid}');

      // Get fresh ID token to ensure authentication
      final String? token = await _getIdToken();
      if (token == null) {
        print('Failed to get ID token');
        return {'success': false, 'error': 'Failed to get authentication token'};
      }

      print('Making authenticated testFirestore call...');

      final HttpsCallable callable = _functions.httpsCallable('testFirestore');
      final HttpsCallableResult result = await callable.call();
      
      print('Test Firestore result: ${result.data}');
      return result.data;
    } catch (e) {
      print('Test Firestore error: $e');
      if (e is FirebaseFunctionsException) {
        print('Functions Exception Code: ${e.code}');
        print('Functions Exception Message: ${e.message}');
        print('Functions Exception Details: ${e.details}');
        
        // Return error info for debugging
        return {
          'success': false,
          'error': e.message,
          'code': e.code,
          'details': e.details?.toString(),
        };
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Send notification via Cloud Functions dengan auth fix
  static Future<bool> sendNotification({
    required String title,
    required String message,
    required UserRole targetRole,
    String? imageUrl,
    NotificationType type = NotificationType.general,
    String? actionData,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User not authenticated for sending notification');
        return false;
      }

      print('Calling sendNotification Cloud Function...');
      print('Data: title="$title", targetRole="${targetRole.name}", type="${type.name}"');

      // Get fresh ID token
      final String? token = await _getIdToken();
      if (token == null) {
        print('Failed to get ID token for sendNotification');
        return false;
      }

      final HttpsCallable callable = _functions.httpsCallable('sendNotification');
      
      final HttpsCallableResult result = await callable.call({
        'title': title,
        'message': message,
        'targetRole': targetRole.name,
        'imageUrl': imageUrl,
        'type': type.name,
        'actionData': actionData,
      });

      print('Cloud Function sendNotification response: ${result.data}');
      
      final bool success = result.data['success'] == true;
      if (success) {
        print('✅ Notification sent successfully!');
        print('Notification ID: ${result.data['notificationId']}');
        print('FCM Message ID: ${result.data['messageId']}');
        print('Topic: ${result.data['topic']}');
      }
      
      return success;
      
    } catch (e) {
      print('❌ Error calling sendNotification Cloud Function: $e');
      
      if (e is FirebaseFunctionsException) {
        print('Functions Exception Code: ${e.code}');
        print('Functions Exception Message: ${e.message}');
        print('Functions Exception Details: ${e.details}');
        
        // Handle specific error codes
        switch (e.code) {
          case 'unauthenticated':
            print('❌ Error: User not authenticated - trying to refresh token');
            break;
          case 'permission-denied':
            print('❌ Error: User not admin or permission denied');
            break;
          case 'not-found':
            print('❌ Error: User document not found in Firestore');
            break;
          case 'invalid-argument':
            print('❌ Error: Missing required fields (title, message, targetRole)');
            break;
          default:
            print('❌ Error: ${e.message}');
        }
      }
      
      return false;
    }
  }

  /// Get notification statistics (Admin only)
  static Future<Map<String, dynamic>?> getNotificationStats() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      print('Getting notification stats...');

      // Get fresh ID token
      final String? token = await _getIdToken();
      if (token == null) {
        print('Failed to get ID token for stats');
        return null;
      }

      final HttpsCallable callable = _functions.httpsCallable('getNotificationStats');
      final HttpsCallableResult result = await callable.call();
      
      print('Notification stats result: ${result.data}');
      return result.data;
    } catch (e) {
      print('Error getting notification stats: $e');
      if (e is FirebaseFunctionsException) {
        print('Functions Exception: ${e.code} - ${e.message}');
      }
      return null;
    }
  }

  /// Force refresh user authentication
  static Future<bool> refreshAuth() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      await currentUser.reload();
      final String? token = await currentUser.getIdToken(true);
      print('Auth refreshed successfully');
      return true;
    } catch (e) {
      print('Error refreshing auth: $e');
      return false;
    }
  }

  /// Get current user info for debugging
  static String? getCurrentUserId() {
    final User? currentUser = _auth.currentUser;
    return currentUser?.uid;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }
}