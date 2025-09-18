import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloud_function_service.dart';

class CloudFunctionTestWidget extends StatefulWidget {
  @override
  _CloudFunctionTestWidgetState createState() => _CloudFunctionTestWidgetState();
}

class _CloudFunctionTestWidgetState extends State<CloudFunctionTestWidget> {
  String _status = 'Ready to test';
  bool _isLoading = false;
  Map<String, dynamic>? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(),
          SizedBox(height: 16),
          _buildTestButtons(),
          if (_lastResult != null) ...[
            SizedBox(height: 16),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildAuthInfo(),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthInfo() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Not authenticated',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Authenticated',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('UID: ${user.uid}'),
          Text('Email: ${user.email ?? 'No email'}'),
          Text('Verified: ${user.emailVerified}'),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _testAuthStatus,
          icon: Icon(Icons.person_search),
          label: Text('Check Auth Status'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _refreshAuth,
          icon: Icon(Icons.refresh),
          label: Text('Refresh Authentication'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _testFirestore,
          icon: Icon(Icons.cloud),
          label: Text('Test Firestore Function'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _testNotification,
          icon: Icon(Icons.notifications),
          label: Text('Test Send Notification'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        if (_isLoading) ...[
          SizedBox(height: 16),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }

  Widget _buildResultCard() {
    final isSuccess = _lastResult!['success'] == true;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Last Test Result',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatResult(_lastResult!),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    result.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }

  Future<void> _testAuthStatus() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking authentication status...';
    });

    try {
      final result = await CloudFunctionService.getAuthStatus();
      
      setState(() {
        _lastResult = result;
        _status = result['authenticated'] == true 
            ? 'Authentication OK' 
            : 'Authentication failed: ${result['error']}';
      });

      _showSnackBar(
        result['authenticated'] == true 
            ? 'Authentication verified' 
            : 'Authentication failed',
        result['authenticated'] == true ? Colors.green : Colors.red,
      );

    } catch (e) {
      setState(() {
        _lastResult = {'success': false, 'error': e.toString()};
        _status = 'Error checking auth: $e';
      });
      
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshAuth() async {
    setState(() {
      _isLoading = true;
      _status = 'Refreshing authentication...';
    });

    try {
      final success = await CloudFunctionService.refreshAuth();
      
      setState(() {
        _lastResult = {'success': success};
        _status = success 
            ? 'Authentication refreshed successfully' 
            : 'Failed to refresh authentication';
      });

      _showSnackBar(
        success ? 'Auth refreshed' : 'Refresh failed',
        success ? Colors.green : Colors.red,
      );

    } catch (e) {
      setState(() {
        _lastResult = {'success': false, 'error': e.toString()};
        _status = 'Error refreshing auth: $e';
      });
      
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirestore() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firestore connection...';
    });

    try {
      final result = await CloudFunctionService.testFirestore();
      
      setState(() {
        _lastResult = result ?? {'success': false, 'error': 'No result'};
        _status = result != null && result['success'] == true 
            ? 'Firestore test passed' 
            : 'Firestore test failed: ${result?['error']}';
      });

      final isSuccess = result != null && result['success'] == true;
      _showSnackBar(
        isSuccess ? 'Firestore test passed' : 'Firestore test failed',
        isSuccess ? Colors.green : Colors.red,
      );

    } catch (e) {
      setState(() {
        _lastResult = {'success': false, 'error': e.toString()};
        _status = 'Error testing Firestore: $e';
      });
      
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing notification sending...';
    });

    try {
      final success = await CloudFunctionService.sendNotification(
        title: 'Test Notification',
        message: 'This is a test notification from Flutter app',
        targetRole: UserRole.makoKor,
        type: NotificationType.general,
      );
      
      setState(() {
        _lastResult = {'success': success};
        _status = success 
            ? 'Notification sent successfully' 
            : 'Failed to send notification';
      });

      _showSnackBar(
        success ? 'Notification sent' : 'Send failed',
        success ? Colors.green : Colors.red,
      );

    } catch (e) {
      setState(() {
        _lastResult = {'success': false, 'error': e.toString()};
        _status = 'Error sending notification: $e';
      });
      
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Helper untuk membuat test page
class CloudFunctionTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Function Tests'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: CloudFunctionTestWidget(),
      ),
    );
  }
}