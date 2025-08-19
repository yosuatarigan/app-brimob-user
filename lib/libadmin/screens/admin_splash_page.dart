import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'admin_login_page.dart';

class AdminSplashPage extends StatefulWidget {
  const AdminSplashPage({super.key});

  @override
  State<AdminSplashPage> createState() => _AdminSplashPageState();
}

class _AdminSplashPageState extends State<AdminSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _backgroundOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
    _navigateToLogin();
  }

  void _initAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Background animations
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    // Text animations
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Background animation
    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimationSequence() async {
    // Start background animation immediately
    _backgroundController.forward();
    
    // Start logo animation after a delay
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const AdminLoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(  
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero, 
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _textController,
          _backgroundController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Background image with animation
                AnimatedBuilder(
                  animation: _backgroundOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _backgroundOpacity.value,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AdminColors.darkGradient,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: AdminImages.adminDashboard,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AdminColors.darkGradient,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AdminColors.darkGradient,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AdminColors.adminDark.withOpacity(0.8),
                        AdminColors.primaryBlue.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                
                // Animated background elements
                Positioned(
                  top: -100,
                  right: -100,
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _backgroundController.value * 0.5,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            color: AdminColors.adminGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                Positioned(
                  bottom: -150,
                  left: -100,
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -_backgroundController.value * 0.3,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Main content
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo section with animation
                        ScaleTransition(
                          scale: _logoScale,
                          child: RotationTransition(
                            turns: _logoRotation,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AdminColors.adminGold.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: CachedNetworkImage(
                                  imageUrl: AdminImages.polriLogo,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Icon(
                                    Icons.admin_panel_settings,
                                    size: 80,
                                    color: AdminColors.primaryBlue,
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.admin_panel_settings,
                                    size: 80,
                                    color: AdminColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AdminSizes.paddingXXL),
                        
                        // Text section with animation
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Column(
                              children: [
                                // Admin badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AdminSizes.paddingL,
                                    vertical: AdminSizes.paddingS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AdminColors.adminGold,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AdminColors.adminGold.withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.security,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AdminSizes.paddingS),
                                      Text(
                                        'ADMIN PANEL',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: AdminSizes.paddingL),
                                
                                // Main title
                                Text(
                                  'SDM KORBRIMOB',
                                  style: GoogleFonts.roboto(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: AdminSizes.paddingM),
                                
                                // Subtitle
                                Text(
                                  'ADMIN DASHBOARD',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AdminColors.adminGold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                
                                const SizedBox(height: AdminSizes.paddingL),
                                
                                // Description
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AdminSizes.paddingXL,
                                  ),
                                  child: Text(
                                    'Panel Administrasi untuk mengelola konten, pengguna, dan pengaturan aplikasi SDM Rorenminops Korbrimob Polri',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: AdminSizes.paddingXXL),
                                
                                // Loading indicator
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AdminColors.adminGold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AdminSizes.paddingM),
                                    Text(
                                      'Memuat Panel Admin...',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom branding
                Positioned(
                  bottom: AdminSizes.paddingL,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      'Rorenminops Korbrimob Polri',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}