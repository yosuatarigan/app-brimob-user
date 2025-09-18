import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/screens/admin_dashboard_page.dart';
import 'package:app_brimob_user/libadmin/screens/admin_login_page.dart';
import 'package:app_brimob_user/libadmin/screens/admin_splash_page.dart';
import 'package:app_brimob_user/percobaannotif/admin_notification_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const AdminApp());
// }

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDM Korbrimob Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminColors.primaryBlue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AdminColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryBlue,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            elevation: 4,
            shadowColor: AdminColors.primaryBlue.withOpacity(0.3),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminColors.primaryBlue,
            side: const BorderSide(color: AdminColors.primaryBlue),
            textStyle: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: AdminColors.primaryBlue.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            borderSide: const BorderSide(color: AdminColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            borderSide: const BorderSide(color: AdminColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            borderSide: const BorderSide(
              color: AdminColors.primaryBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            borderSide: const BorderSide(color: AdminColors.error),
          ),
          filled: true,
          fillColor: AdminColors.background,
          labelStyle: GoogleFonts.roboto(
            color: AdminColors.darkGray,
          ),
          hintStyle: GoogleFonts.roboto(
            color: AdminColors.lightGray,
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusL),
          ),
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminDark,
          ),
          contentTextStyle: GoogleFonts.roboto(
            fontSize: 14,
            color: AdminColors.darkGray,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
          ),
          contentTextStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AdminColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusL),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AdminColors.background,
          selectedColor: AdminColors.primaryBlue.withOpacity(0.1),
          labelStyle: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusL),
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: AdminColors.primaryBlue,
          unselectedLabelColor: AdminColors.darkGray,
          indicatorColor: AdminColors.primaryBlue,
          labelStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AdminSplashPage(),
        '/login': (context) => const AdminLoginPage(),
        '/dashboard': (context) => const AdminDashboardPage(),
      },
    );
  }
}