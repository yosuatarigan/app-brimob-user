import 'package:app_brimob_user/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';
import 'login_page.dart';
import 'content_page.dart';
import 'galeri_page.dart';
import 'pedoman_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSizes.paddingL),
                // _buildHeroSection(),
                // const SizedBox(height: AppSizes.paddingXL),
                _buildSectionTitle('Menu Utama'),
                const SizedBox(height: AppSizes.paddingM),
                _buildMenuGrid(),
                const SizedBox(height: AppSizes.paddingXL),
                _buildQuickAccess(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      child: Image.asset(
        'assets/head.png',
        // fit: BoxFit.cover,
        height: 250,
        width: double.infinity,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 400,
            color: AppColors.primaryBlue,
            child: Center(
              child: Text(
                'Header Image',
                style: GoogleFonts.roboto(color: AppColors.white, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildHeroSection() {
  //   return const HeroSection(
  //     title: 'SELAMAT DATANG',
  //     subtitle: 'DI App SDM RORENMINOPS KORBRIMOB POLRI',
  //   );
  // }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkNavy,
      ),
    );
  }

  // Ganti method _buildMenuGrid() di DashboardPage dengan ini:

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'KORBRIMOB',
        'asset': 'assets/korbrimob.png',
        'id': 'korbrimob',
        'isProtected': false, // tambahkan field ini
      },
      {
        'title': 'BINKAR',
        'asset': 'assets/binkar.png',
        'id': 'binkar',
        'isProtected': true, // BINKAR biasanya protected
      },
      {
        'title': 'DALPERS',
        'asset': 'assets/dalpers.png',
        'id': 'dalpers',
        'isProtected': false,
      },
      {
        'title': 'WATPERS',
        'asset': 'assets/watpress.png',
        'id': 'watpers',
        'isProtected': false,
      },
      {
        'title': 'PSIKOLOGI',
        'asset': 'assets/psikologi.png',
        'id': 'psikologi',
        'isProtected': false,
      },
      {
        'title': 'PERDANKOR',
        'asset': 'assets/perdankor.png',
        'id': 'perdankor',
        'isProtected': false,
      },
      {
        'title': 'PERKAP',
        'asset': 'assets/perkap.png',
        'id': 'perkap',
        'isProtected': false,
      },
      {
        'title': 'OTHER',
        'asset': 'assets/other.png',
        'id': 'other',
        'isProtected': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.7,
          crossAxisSpacing: 3,
          mainAxisSpacing: 12,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final menu = menuItems[index];
          return _buildMenuItem(
            title: menu['title']!,
            assetPath: menu['asset']!,
            onTap: () => _handleMenuTap(menu), // pass seluruh menu object
          );
        },
      ),
    );
  }

  // Widget untuk setiap item menu
  Widget _buildMenuItem({
    required String title,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        print('Item tapped: $title'); // debug print
        onTap(); // panggil callback
      },
      behavior: HitTestBehavior.translucent, // tambahkan ini
      child: Container(
        // tambahkan container dengan padding untuk area tap lebih besar
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
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
            // Text
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 10,
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

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Akses Cepat'),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                'Galeri Satuan',
                Icons.photo_library,
                AppColors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryPage()),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildQuickAccessCard(
                'Pedoman',
                Icons.menu_book,
                AppColors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PedomanPage()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(icon, color: color, size: AppSizes.iconM),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _handleMenuTap(Map<String, dynamic> menu) async {
    // Debug print untuk cek apakah method dipanggil
    print('Menu tapped: ${menu['id']}');

    // Cek apakah menu protected, default false jika null
    bool isProtected = menu['isProtected'] ?? false;

    if (isProtected) {
      // Check if user is already logged in and has access
      if (FirebaseService.isLoggedIn) {
        final hasAccess = await FirebaseService.hasAccessToBinkar();
        if (hasAccess) {
          _navigateToContent(menu['id']);
        } else {
          _showAccessDeniedDialog();
        }
      } else {
        _navigateToLogin(menu['id']);
      }
    } else {
      // Langsung navigate ke content
      _navigateToContent(menu['id']);
    }
  }

  void _navigateToLogin(String targetMenu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(targetMenu: targetMenu),
      ),
    );
  }

  void _navigateToContent(String menuId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContentPage(category: menuId)),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Akses Ditolak'),
            content: const Text(
              'Anda tidak memiliki akses ke menu BINKAR. Silakan hubungi administrator.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseService.signOut();
                  setState(() {});
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
