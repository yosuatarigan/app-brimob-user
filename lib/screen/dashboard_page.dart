// lib/pages/dashboard_page.dart
import 'package:app_brimob_user/notification_widget.dart';
import 'package:app_brimob_user/percobaannotif/fcm_service.dart';
import 'package:app_brimob_user/profile_section_widget.dart';
import 'package:app_brimob_user/services/auth_service.dart';
import 'package:app_brimob_user/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import existing
import '../slide_show_model.dart';
import '../widget/menu_card.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';
import 'content_page.dart';
import 'galeri_page.dart';
import 'pedoman_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  bool _isFCMInitialized = false;

  // Current user data
  UserModel? _currentUser;
  final AuthService _authService = AuthService();

  // Slideshow variables
  final PageController _pageController = PageController();
  List<SlideshowItem> _slideshowImages = [];
  int _currentSlide = 0;
  bool _isLoadingSlideshow = true;

  @override
  void initState() {
    super.initState();
    _loadSlideshowImages();
    _loadCurrentUserAndInitializeFCM();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper method untuk info card
  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk konfirmasi logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[600], size: 24),
              const SizedBox(width: 12),
              Text(
                'Konfirmasi Keluar',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.roboto(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Keluar',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method untuk handle logout
  Future<void> _handleLogout() async {
    try {
      // Show loading

      // Sign out
      await _authService.signOut();

      // Close loading dialog
      //
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal keluar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper methods untuk warna
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.pending:
        return Colors.orange[600]!;
      case UserStatus.approved:
        return Colors.green[600]!;
      case UserStatus.rejected:
        return Colors.red[600]!;
    }
  }

 
  Future<void> _loadCurrentUserAndInitializeFCM() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);

        if (_currentUser != null) {
          await FCMService.initialize(userRole: _currentUser!.role);
          setState(() => _isFCMInitialized = true);
        } else {
          await FCMService.initialize();
          setState(() => _isFCMInitialized = true);
        }
      } else {
        await FCMService.initialize();
        setState(() => _isFCMInitialized = true);
      }
    } catch (e) {
      try {
        await FCMService.initialize();
        setState(() => _isFCMInitialized = true);
      } catch (fallbackError) {
        print('FCM fallback also failed: $fallbackError');
      }
    }
  }

  Future<void> _loadSlideshowImages() async {
    try {
      setState(() => _isLoadingSlideshow = true);
      final images = await FirebaseService.getSlideshowImages();
      setState(() {
        _slideshowImages = images;
        _isLoadingSlideshow = false;
      });

      if (_slideshowImages.isNotEmpty) {
        _startAutoSlide();
      }
    } catch (e) {
      print('Error loading slideshow images: $e');
      setState(() => _isLoadingSlideshow = false);
      _slideshowImages = [
        SlideshowItem(
          id: 'default',
          imageUrl: 'assets/head.png',
          isActive: true,
          order: 0,
        ),
      ];
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _slideshowImages.length > 1) {
        final nextSlide = (_currentSlide + 1) % _slideshowImages.length;
        _pageController.animateToPage(
          nextSlide,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      } else if (mounted && _slideshowImages.length == 1) {
        _startAutoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/welcome.png'),
                _buildSlideshowHeader(),
                _buildGaleriSatuan(),
                _buildMenuGrid(),
                _buildPedomanSection(),
                ProfileSectionWidget(
                  currentUser: _currentUser!,
                  onLogout: () {
                    // Handle logout logic
                    _authService.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Clean notification section - hanya riwayat notifikasi
  Widget _buildNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOTIFIKASI',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Riwayat pemberitahuan sistem',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Status FCM
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isFCMInitialized ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isFCMInitialized
                          ? Icons.check_circle
                          : Icons.access_time,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isFCMInitialized ? 'Aktif' : 'Loading',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notification Content
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Notification Widget Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kirim Notifikasi',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      NotificationWidget(),
                    ],
                  ),
                ),

                // Divider
                Divider(height: 1, color: Colors.grey[200]),

                // Recent Notifications Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.green[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Riwayat Notifikasi',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '5 Terbaru',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RecentNotificationsWidget(limit: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Footer info
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Swipe untuk refresh • Notifikasi realtime aktif',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideshowHeader() {
    if (_isLoadingSlideshow) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF6D4C41), AppColors.primaryBlue],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Slideshow...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_slideshowImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        color: AppColors.primaryBlue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library,
                color: Colors.white.withOpacity(0.7),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No Slideshow Images Available',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Contact administrator to add slideshow images',
                style: GoogleFonts.roboto(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: _slideshowImages.length,
            itemBuilder: (context, index) {
              final slide = _slideshowImages[index];
              return _buildSlideItem(slide);
            },
          ),

          if (_slideshowImages.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slideshowImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentSlide == index ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:
                          _currentSlide == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                      boxShadow:
                          _currentSlide == index
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                  ),
                ),
              ),
            ),

          if (_slideshowImages.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    final prevSlide =
                        _currentSlide == 0
                            ? _slideshowImages.length - 1
                            : _currentSlide - 1;
                    _pageController.animateToPage(
                      prevSlide,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    final nextSlide =
                        (_currentSlide + 1) % _slideshowImages.length;
                    _pageController.animateToPage(
                      nextSlide,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],

          if (_slideshowImages.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                child: Text(
                  '${_currentSlide + 1} / ${_slideshowImages.length}',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlideItem(SlideshowItem slide) {
    return Container(
      width: double.infinity,
      height: 250,
      child:
          slide.imageUrl.startsWith('http')
              ? CachedNetworkImage(
                imageUrl: slide.imageUrl,
                fit: BoxFit.fill,
                placeholder:
                    (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            const Color(0xFF6D4C41),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Loading image...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: AppColors.primaryBlue,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white.withOpacity(0.7),
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load image',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              )
              : Image.asset(
                slide.imageUrl,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryBlue,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.white.withOpacity(0.7),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'SDM Korbrimob Polri',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sistem Data Manajemen',
                            style: GoogleFonts.roboto(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGaleriSatuan() {
    final List<Map<String, dynamic>> galeriItems = [
      {
        'id': 'mako_kor',
        'name': 'MAKO KOR',
        'color': const Color(0xFF1565C0),
        'logo': 'assets/newgalerisatuan/MAKO KORBRIMOB.png',
      },
      {
        'id': 'pas_pelopor',
        'name': 'PAS PELOPOR',
        'color': const Color(0xFFD32F2F),
        'logo': 'assets/newgalerisatuan/pelopor terbaru.png',
      },
      {
        'id': 'pas_gegana',
        'name': 'PAS GEGANA',
        'color': const Color(0xFF388E3C),
        'logo': 'assets/newgalerisatuan/gegana.png',
      },
      {
        'id': 'pasbrimob_i',
        'name': 'PASBRIMOB I',
        'color': const Color(0xFFF57C00),
        'logo': 'assets/newgalerisatuan/PASBRIMOB 1.png',
      },
      {
        'id': 'pasbrimob_ii',
        'name': 'PASBRIMOB II',
        'color': const Color(0xFF7B1FA2),
        'logo': 'assets/newgalerisatuan/PASBRIMOB 2.png',
      },
      {
        'id': 'pasbrimob_iii',
        'name': 'PASBRIMOB III',
        'color': const Color(0xFF00796B),
        'logo': 'assets/newgalerisatuan/PASBRIMOB 3.png',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF6D4C41)),
      child: Column(
        children: [
          Text(
            'GALERI SATUAN',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 30,
              mainAxisSpacing: 0,
            ),
            itemCount: galeriItems.length,
            itemBuilder: (context, index) {
              final item = galeriItems[index];
              return _buildGaleriItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGaleriItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _navigateToGalleryCategory(item),
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              child: Image.asset(
                item['logo'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['name'],
              style: GoogleFonts.roboto(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'KORBRIMOB',
        'asset': 'assets/korbrimob.png',
        'id': 'korbrimob',
      },
      {'title': 'BINKAR', 'asset': 'assets/binkar.png', 'id': 'binkar'},
      {'title': 'DALPERS', 'asset': 'assets/dalpers.png', 'id': 'dalpers'},
      {'title': 'WATPERS', 'asset': 'assets/watpress.png', 'id': 'watpers'},
      {
        'title': 'PSIKOLOGI',
        'asset': 'assets/psikologi.png',
        'id': 'psikologi',
      },
      {
        'title': 'PERDANKOR',
        'asset': 'assets/perdankor.png',
        'id': 'perdankor',
      },
      {'title': 'PERKAP', 'asset': 'assets/perkap.png', 'id': 'perkap'},
      {'title': 'OTHER', 'asset': 'assets/other.png', 'id': 'other'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final menu = menuItems[index];
          return _buildMenuItem(
            title: menu['title']!,
            assetPath: menu['asset']!,
            onTap: () => _handleMenuTap(menu),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedomanSection() {
    final List<Map<String, String>> pedomanItems = [
      {
        'title': 'Tri Brata',
        'description': 'Pedoman hidup anggota Polri',
        'id': 'tri_brata',
        'assetPath': 'assets/tribrata.png',
        'imageContent': 'assets/dc/tribrata.png',
      },
      {
        'title': 'Catur Prasetya',
        'description': 'Empat janji kerja anggota Polri',
        'id': 'catur_prasetya',
        'assetPath': 'assets/tribrata.png',
        'imageContent': 'assets/dc/catutprasetya.png',
      },
      {
        'title': 'Panca Prasetya',
        'description': 'Lima prinsip khusus Korbrimob',
        'id': 'panca_prasetya',
        'assetPath': 'assets/brimob.png',
        'imageContent': 'assets/dc/panca.png',
      },
      {
        'title': 'Etika Profesi',
        'description': 'Etika profesi Brimob',
        'id': 'etika_profesi',
        'assetPath': 'assets/brimob.png',
        'imageContent': 'assets/dc/etika.png',
      },
      {
        'title': 'Ikrar Brimob',
        'description': 'Ikrar anggota Brimob',
        'id': 'ikrar_brimob',
        'assetPath': 'assets/brimob.png',
        'imageContent': 'assets/dc/ikrar.png',
      },
      {
        'title': 'Jati Diri Brimob',
        'description': 'Jati diri Korbrimob Polri',
        'id': 'jati_diri',
        'assetPath': 'assets/korpri.png',
        'imageContent': 'assets/dc/jatidiri.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.primaryBlue),
          child: Column(
            children: [
              _buildSectionTitle('Pedoman, Falsafah & Doktrin Korbrimob Polri'),
              const SizedBox(height: AppSizes.paddingM),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 32,
                  mainAxisSpacing: 12,
                ),
                itemCount: pedomanItems.length,
                itemBuilder: (context, index) {
                  final item = pedomanItems[index];
                  return _buildPedomanItem(item);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPedomanItem(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _navigateToPedomanDetail(item),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getPedomanColor(item['id']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Image.asset(
                    item['assetPath']!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                item['title']!,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToGalleryCategory(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryGalleryPage(category: category),
      ),
    );
  }

  void _navigateToPedomanDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PedomanDetailPage(
              title: item['title']!,
              content: item['imageContent']!,
              icon: _getPedomanIcon(item['id']!),
              assetPath: item['assetPath']!,
              isImageContent: true,
            ),
      ),
    );
  }

  Color _getPedomanColor(String id) {
    switch (id) {
      case 'tri_brata':
        return AppColors.primaryBlue;
      case 'catur_prasetya':
        return AppColors.red;
      case 'panca_prasetya':
        return AppColors.green;
      case 'etika_profesi':
        return AppColors.orange;
      case 'ikrar_brimob':
        return AppColors.purple;
      case 'jati_diri':
        return AppColors.indigo;
      default:
        return AppColors.darkGray;
    }
  }

  IconData _getPedomanIcon(String id) {
    switch (id) {
      case 'tri_brata':
        return Icons.star;
      case 'catur_prasetya':
        return Icons.favorite;
      case 'panca_prasetya':
        return Icons.security;
      case 'etika_profesi':
        return Icons.school;
      case 'ikrar_brimob':
        return Icons.military_tech;
      case 'jati_diri':
        return Icons.badge;
      default:
        return Icons.book;
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await _loadSlideshowImages();
    await _loadCurrentUserAndInitializeFCM();
    setState(() => _isLoading = false);
  }

  Future<void> _handleMenuTap(Map<String, dynamic> menu) async {
    _navigateToContent(menu['id']);
  }

  void _navigateToContent(String menuId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContentPage(category: menuId)),
    );
  }
}
