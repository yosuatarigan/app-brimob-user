import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/admin_firebase_service.dart';
import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@polri.go.id');
  final _passwordController = TextEditingController(text: 'admin123');

  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background
            _buildBackground(),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AdminSizes.paddingL),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Card(
                              elevation: 20,
                              shadowColor: AdminColors.primaryBlue.withOpacity(
                                0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AdminSizes.radiusXL,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AdminSizes.radiusXL,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.95),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AdminSizes.paddingXL,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildHeader(),
                                      const SizedBox(
                                        height: AdminSizes.paddingXL,
                                      ),
                                      _buildLoginForm(),
                                      const SizedBox(
                                        height: AdminSizes.paddingXL,
                                      ),
                                      _buildLoginButton(),
                                      const SizedBox(
                                        height: AdminSizes.paddingL,
                                      ),
                                      _buildFooter(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Background image
        CachedNetworkImage(
          imageUrl: AdminImages.adminDashboard,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AdminColors.darkGradient,
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AdminColors.darkGradient,
                  ),
                ),
              ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AdminColors.primaryBlue.withOpacity(0.8),
                AdminColors.adminDark.withOpacity(0.9),
              ],
            ),
          ),
        ),

        // Animated background elements
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AdminColors.adminGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with animation
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AdminColors.primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AdminColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: CachedNetworkImage(
              imageUrl: AdminImages.polriLogo,
              fit: BoxFit.contain,
              placeholder:
                  (context, url) => const Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: Colors.white,
                  ),
              errorWidget:
                  (context, url, error) => const Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: Colors.white,
                  ),
            ),
          ),
        ),

        const SizedBox(height: AdminSizes.paddingL),

        // Admin badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminSizes.paddingL,
            vertical: AdminSizes.paddingS,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AdminColors.adminGold, Color(0xFFEA580C)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AdminColors.adminGold.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, color: Colors.white, size: 18),
              const SizedBox(width: AdminSizes.paddingS),
              Text(
                'ADMIN ACCESS',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AdminSizes.paddingL),

        // Title
        Text(
          'Admin Login',
          style: GoogleFonts.roboto(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminDark,
          ),
        ),

        const SizedBox(height: AdminSizes.paddingS),

        // Subtitle
        Text(
          'Masuk ke panel administrasi SDM Korbrimob',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: AdminColors.darkGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: AdminSizes.paddingL),
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Administrator',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AdminColors.adminDark,
          ),
        ),
        const SizedBox(height: AdminSizes.paddingS),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'admin@korbrimob.polri.go.id',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AdminColors.primaryBlue,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              borderSide: BorderSide(color: AdminColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              borderSide: BorderSide(color: AdminColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              borderSide: BorderSide(color: AdminColors.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: AdminColors.background,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AdminColors.adminDark,
          ),
        ),
        const SizedBox(height: AdminSizes.paddingS),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Masukkan password admin',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: AdminColors.primaryBlue,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AdminColors.darkGray,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              borderSide: BorderSide(color: AdminColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              borderSide: BorderSide(color: AdminColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              borderSide: BorderSide(color: AdminColors.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: AdminColors.background,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            if (value.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
          ),
          elevation: 8,
          shadowColor: AdminColors.primaryBlue.withOpacity(0.3),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 20),
                    const SizedBox(width: AdminSizes.paddingS),
                    Text(
                      'MASUK ADMIN PANEL',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          decoration: BoxDecoration(
            color: AdminColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
            border: Border.all(color: AdminColors.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_outlined, color: AdminColors.error, size: 20),
              const SizedBox(width: AdminSizes.paddingS),
              Expanded(
                child: Text(
                  'Akses terbatas untuk administrator berwenang',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AdminColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        Text(
          'Hubungi IT support jika mengalami kesulitan login',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(fontSize: 12, color: AdminColors.lightGray),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AdminFirebaseService.signInAsAdmin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const AdminDashboardPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: AdminSizes.paddingS),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AdminColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusS),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
