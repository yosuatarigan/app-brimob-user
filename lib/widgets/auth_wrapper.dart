import 'package:app_brimob_user/screen/dashboard_page.dart';
import 'package:app_brimob_user/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../screens/pending_approval_page.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is not logged in, show login page
        if (snapshot.data == null) {
          return const LoginPage();
        }

        // If user is logged in, check their status
        return FutureBuilder<UserModel?>(
          future: _authService.getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            // Show loading while fetching user data
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // If user data not found, redirect to login
            if (userSnapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _authService.signOut();
              });
              return const LoginPage();
            }

            UserModel user = userSnapshot.data!;

            // Check user status and redirect accordingly
            switch (user.status) {
              case UserStatus.pending:
                return PendingApprovalPage(user: user);
              case UserStatus.approved:
                return const DashboardPage();
              case UserStatus.rejected:
                // Sign out and redirect to login with message
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _authService.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun Anda ditolak oleh admin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
                return const LoginPage();
            }
          },
        );
      },
    );
  }
}