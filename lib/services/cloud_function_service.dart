import 'package:app_brimob_user/models/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notification_model.dart';

class CloudFunctionService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize dengan configurasi region jika diperlukan
  static void initialize({String region = 'us-central1'}) {
    // Set region jika diperlukan
    // _functions = FirebaseFunctions.instanceFor(region: region);
  }

  /// Get fresh ID token dengan retry mechanism
  static Future<String?> _getIdToken() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No current user for token');
        return null;
      }

      // Reload user untuk ensure latest state
      await currentUser.reload();
      
      // Force refresh token
      final String? token = await currentUser.getIdToken(true);
      print('✅ Got fresh ID token: ${token?.substring(0, 30)}...');
      
      return token;
    } catch (e) {
      print('❌ Error getting ID token: $e');
      return null;
    }
  }

  /// Test koneksi Cloud Functions dengan improved auth
  static Future<Map<String, dynamic>?> testConnection() async {
    try {
      print('🔄 Testing Cloud Functions connection...');

      // Check user authentication
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ User not authenticated');
        return {
          'success': false,
          'error': 'User not authenticated'
        };
      }

      print('✅ User authenticated: ${currentUser.uid}');
      print('📧 User email: ${currentUser.email}');

      // Get fresh token
      final String? token = await _getIdToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Failed to get authentication token'
        };
      }

      // Configure function dengan timeout
      final HttpsCallable callable = _functions.httpsCallable(
        'testFirestore',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      print('🚀 Making authenticated call...');

      // Make call
      final HttpsCallableResult result = await callable.call();

      print('✅ Test connection result: ${result.data}');
      return result.data;

    } catch (e) {
      print('❌ Test connection error: $e');
      return _handleFunctionError(e);
    }
  }

  /// Test Firestore connection dengan improved error handling
  static Future<Map<String, dynamic>?> testFirestore() async {
    try {
      // Pre-flight checks
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ User not authenticated for Firestore test');
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }

      print('🔄 Testing Firestore via Cloud Functions...');
      print('👤 Current user ID: ${currentUser.uid}');
      print('📧 User email: ${currentUser.email}');
      print('🔐 Email verified: ${currentUser.emailVerified}');

      // Ensure fresh token
      final String? token = await _getIdToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Failed to get fresh authentication token',
        };
      }

      // Make function call dengan retry
      return await _callFunctionWithRetry('testFirestore', {});

    } catch (e) {
      print('❌ Test Firestore error: $e');
      return _handleFunctionError(e);
    }
  }

  /// Send notification dengan improved auth handling
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
        print('❌ User not authenticated for sending notification');
        return false;
      }

      print('🔄 Calling sendNotification Cloud Function...');
      print('📋 Data: title="$title", targetRole="${targetRole.name}", type="${type.name}"');

      // Ensure fresh authentication
      final String? token = await _getIdToken();
      if (token == null) {
        print('❌ Failed to get ID token for sendNotification');
        return false;
      }

      // Prepare data
      final Map<String, dynamic> data = {
        'title': title,
        'message': message,
        'targetRole': targetRole.name,
        'imageUrl': imageUrl,
        'type': type.name,
        'actionData': actionData,
      };

      // Call function dengan retry
      final result = await _callFunctionWithRetry('sendNotification', data);

      if (result != null && result['success'] == true) {
        print('✅ Notification sent successfully!');
        print('📨 Notification ID: ${result['notificationId']}');
        print('📡 FCM Message ID: ${result['messageId']}');
        print('🎯 Topic: ${result['topic']}');
        return true;
      } else {
        print('❌ Failed to send notification: ${result?['error']}');
        return false;
      }

    } catch (e) {
      print('❌ Error calling sendNotification Cloud Function: $e');
      return false;
    }
  }

  /// Get notification statistics
  static Future<Map<String, dynamic>?> getNotificationStats() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      print('🔄 Getting notification stats...');

      final String? token = await _getIdToken();
      if (token == null) {
        print('❌ Failed to get ID token for stats');
        return null;
      }

      return await _callFunctionWithRetry('getNotificationStats', {});

    } catch (e) {
      print('❌ Error getting notification stats: $e');
      return null;
    }
  }

  /// Call function dengan retry mechanism
  static Future<Map<String, dynamic>?> _callFunctionWithRetry(
    String functionName,
    Map<String, dynamic> data, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 Attempt $attempt/$maxRetries for $functionName');

        // Configure callable dengan options
        final HttpsCallable callable = _functions.httpsCallable(
          functionName,
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 30),
          ),
        );

        final HttpsCallableResult result = await callable.call(data);
        print('✅ $functionName success on attempt $attempt');
        
        return result.data is Map<String, dynamic> 
            ? result.data as Map<String, dynamic>
            : {'data': result.data};

      } catch (e) {
        print('❌ $functionName attempt $attempt failed: $e');

        if (attempt == maxRetries) {
          return _handleFunctionError(e);
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: attempt));

        // Refresh auth before retry
        if (attempt < maxRetries) {
          await refreshAuth();
        }
      }
    }

    return null;
  }

  /// Handle function errors dengan detailed info
  static Map<String, dynamic> _handleFunctionError(dynamic error) {
    if (error is FirebaseFunctionsException) {
      print('🔥 Functions Exception:');
      print('   Code: ${error.code}');
      print('   Message: ${error.message}');
      print('   Details: ${error.details}');

      return {
        'success': false,
        'error': error.message ?? 'Unknown Firebase Functions error',
        'code': error.code,
        'details': error.details?.toString(),
      };
    }

    return {
      'success': false,
      'error': error.toString(),
    };
  }

  /// Force refresh user authentication
  static Future<bool> refreshAuth() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      print('🔄 Refreshing authentication...');
      
      await currentUser.reload();
      await currentUser.getIdToken(true);
      
      print('✅ Auth refreshed successfully');
      return true;
    } catch (e) {
      print('❌ Error refreshing auth: $e');
      return false;
    }
  }

  /// Check authentication status dengan detail
  static Future<Map<String, dynamic>> getAuthStatus() async {
    final User? currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      return {
        'authenticated': false,
        'error': 'No current user'
      };
    }

    try {
      // Try to get fresh token
      final token = await currentUser.getIdToken(false);
      
      return {
        'authenticated': true,
        'uid': currentUser.uid,
        'email': currentUser.email,
        'emailVerified': currentUser.emailVerified,
        'hasToken': token != null,
      };
    } catch (e) {
      return {
        'authenticated': false,
        'uid': currentUser.uid,
        'error': e.toString(),
      };
    }
  }

  /// Utility methods
  static String? getCurrentUserId() => _auth.currentUser?.uid;
  
  static bool isAuthenticated() => _auth.currentUser != null;
  
  static User? getCurrentUser() => _auth.currentUser;
}