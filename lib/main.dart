import 'package:app_brimob_user/libadmin/screens/main_admin.dart';
import 'package:app_brimob_user/percobaannotif/fcm_service.dart';
import 'package:app_brimob_user/screen/splash_page.dart';
import 'package:app_brimob_user/services/notification_helper.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_constants.dart';
import 'widgets/auth_wrapper.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationHelper.initialize();
  await FCMService.initialize();

  await FirebaseAppCheck.instance.activate(
    // Gunakan provider debug untuk pengembangan dan pengujian
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );      

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI PANALUAN KORBRIMOB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            textStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(color: AppColors.darkGray.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/auth': (context) => AuthWrapper(),
      },
    );
  }
}
