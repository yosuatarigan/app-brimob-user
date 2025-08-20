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
                _buildHeroSection(),
                const SizedBox(height: AppSizes.paddingXL),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingS),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: const Icon(
            Icons.security,
            color: AppColors.white,
            size: AppSizes.iconL,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SDM KORBRIMOB',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                'Rorenminops Polri',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
        if (FirebaseService.isLoggedIn) ...[
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout, color: AppColors.darkGray),
          ),
        ],
      ],
    );
  }

  Widget _buildHeroSection() {
    return const HeroSection(
      title: 'SELAMAT DATANG',
      subtitle: 'DI App SDM RORENMINOPS KORBRIMOB POLRI',
    );
  }

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

  Widget _buildMenuGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
      ),
      itemCount: MenuData.mainMenus.length,
      itemBuilder: (context, index) {
        final menu = MenuData.mainMenus[index];
        return MenuCard(
          title: menu['title'],
          icon: menu['icon'],
          imageUrl: menu['imageUrl'],
          description: menu['description'],
          color: menu['color'],
          isProtected: menu['isProtected'],
          onTap: () => _handleMenuTap(menu),
        );
      },
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
                  MaterialPageRoute(builder: (context) =>  GalleryPage()),
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
    if (menu['isProtected']) {
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
