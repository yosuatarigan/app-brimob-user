import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/models/admin_model.dart';
import 'package:app_brimob_user/libadmin/screens/content_managament_page.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/admin_firebase_service.dart';
import 'user_management_page.dart';
import 'media_library_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  AppAnalytics? _analytics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDashboardData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final analytics = await AdminFirebaseService.getAnalytics();
      
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: AdminLoadingWidget(message: 'Memuat dashboard...'),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Dashboard',
        message: _error!,
        onRetry: _loadDashboardData,
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildStatsSection(),
                  _buildQuickActionsSection(),
                  _buildAnalyticsSection(),
                  _buildRecentActivitySection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AdminColors.adminGradient,
        ),
      ),
      child: Stack(
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl: AdminImages.adminDashboard,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AdminColors.adminGradient,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AdminColors.adminGradient,
                ),
              ),
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AdminColors.primaryBlue.withOpacity(0.8),
                  AdminColors.adminDark.withOpacity(0.9),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AdminSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CachedNetworkImage(
                          imageUrl: AdminImages.polriLogo,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Icon(
                            Icons.admin_panel_settings,
                            color: AdminColors.primaryBlue,
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.admin_panel_settings,
                            color: AdminColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminSizes.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'SDM Korbrimob Management',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Welcome message
                Text(
                  'Selamat datang, Administrator',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AdminSizes.paddingS),
                Text(
                  'Kelola dan pantau aplikasi SDM Rorenminops Korbrimob Polri',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: AdminSizes.paddingM),
                
                // Quick stats
                if (_analytics != null)
                  Row(
                    children: [
                      _buildQuickStat('Total Users', '${_analytics!.totalUsers}'),
                      const SizedBox(width: AdminSizes.paddingL),
                      _buildQuickStat('Content', '${_analytics!.totalContent}'),
                      const SizedBox(width: AdminSizes.paddingL),
                      _buildQuickStat('Media Files', '${_analytics!.totalMedia}'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminGold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    if (_analytics == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AdminSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Aplikasi',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminColors.adminDark,
            ),
          ),
          const SizedBox(height: AdminSizes.paddingM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: AdminSizes.paddingM,
              mainAxisSpacing: AdminSizes.paddingM,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final stats = [
                {
                  'title': 'Total Konten',
                  'value': '${_analytics!.totalContent}',
                  'icon': Icons.article,
                  'color': AdminColors.primaryBlue,
                  'change': '+12%',
                },
                {
                  'title': 'Total Users',
                  'value': '${_analytics!.totalUsers}',
                  'icon': Icons.people,
                  'color': AdminColors.adminGreen,
                  'change': '+8%',
                },
                {
                  'title': 'Media Files',
                  'value': '${_analytics!.totalMedia}',
                  'icon': Icons.perm_media,
                  'color': AdminColors.adminPurple,
                  'change': '+15%',
                },
                {
                  'title': 'Storage',
                  'value': _formatFileSize(_analytics!.storageUsed),
                  'icon': Icons.storage,
                  'color': AdminColors.adminGold,
                  'change': '+5%',
                },
              ];

              final stat = stats[index];
              return AdminStatsCard(
                title: stat['title'] as String,
                value: stat['value'] as String,
                icon: stat['icon'] as IconData,
                color: stat['color'] as Color,
                change: stat['change'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.all(AdminSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Utama',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminColors.adminDark,
            ),
          ),
          const SizedBox(height: AdminSizes.paddingM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: AdminSizes.paddingM,
              mainAxisSpacing: AdminSizes.paddingM,
            ),
            itemCount: AdminMenus.adminMenus.length,
            itemBuilder: (context, index) {
              final menu = AdminMenus.adminMenus[index];
              return AdminMenuCard(
                title: menu['title'],
                subtitle: menu['subtitle'],
                icon: menu['icon'],
                color: menu['color'],
                imageUrl: menu['imageUrl'],
                onTap: () => _handleMenuTap(menu['id']),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    if (_analytics == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AdminSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminColors.adminDark,
            ),
          ),
          const SizedBox(height: AdminSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildUserRoleChart(),
              ),
              const SizedBox(width: AdminSizes.paddingM),
              Expanded(
                child: _buildContentCategoryChart(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleChart() {
    final usersByRole = _analytics!.usersByRole;
    final total = usersByRole.values.fold(0, (sum, count) => sum + count);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users by Role',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingM),
            SizedBox(
              height: 120,
              child: PieChart(
                PieChartData(
                  sections: usersByRole.entries.map((entry) {
                    final percentage = total > 0 ? (entry.value / total) * 100 : 0;
                    return PieChartSectionData(
                      color: _getRoleColor(entry.key),
                      value: percentage.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AdminSizes.paddingM),
            ...usersByRole.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: AdminSizes.paddingXS),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getRoleColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AdminSizes.paddingS),
                  Text(
                    '${entry.key}: ${entry.value}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AdminColors.darkGray,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCategoryChart() {
    final contentByCategory = _analytics!.contentByCategory;
    final total = contentByCategory.values.fold(0, (sum, count) => sum + count);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content by Category',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingM),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: contentByCategory.values.isNotEmpty 
                      ? contentByCategory.values.reduce((a, b) => a > b ? a : b).toDouble() + 1
                      : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final categories = contentByCategory.keys.toList();
                          if (value.toInt() < categories.length) {
                            return Text(
                              categories[value.toInt()].toUpperCase(),
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                color: AdminColors.darkGray,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: contentByCategory.entries.toList().asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: _getCategoryColor(entry.value.key),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Padding(
      padding: const EdgeInsets.all(AdminSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.adminDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to logs page
                },
                child: Text(
                  'View All Logs',
                  style: GoogleFonts.roboto(
                    color: AdminColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: AdminActionButton(
                  title: 'Tambah Konten',
                  subtitle: 'Buat konten baru',
                  icon: Icons.add_circle,
                  color: AdminColors.adminGreen,
                  onTap: () => _handleMenuTap('content_management'),
                ),
              ),
              const SizedBox(width: AdminSizes.paddingM),
              Expanded(
                child: AdminActionButton(
                  title: 'Kelola User',
                  subtitle: 'Tambah/edit user',
                  icon: Icons.person_add,
                  color: AdminColors.primaryBlue,
                  onTap: () => _handleMenuTap('user_management'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: AdminActionButton(
                  title: 'Upload Media',
                  subtitle: 'Kelola file',
                  icon: Icons.cloud_upload,
                  color: AdminColors.adminPurple,
                  onTap: () => _handleMenuTap('media_library'),
                ),
              ),
              const SizedBox(width: AdminSizes.paddingM),
              Expanded(
                child: AdminActionButton(
                  title: 'Pengaturan',
                  subtitle: 'Konfigurasi app',
                  icon: Icons.settings,
                  color: AdminColors.adminGold,
                  onTap: () => _handleMenuTap('settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(String menuId) {
    switch (menuId) {
      case 'content_management':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContentManagementPage(),
          ),
        );
        break;
      case 'user_management':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserManagementPage(),
          ),
        );
        break;
      case 'media_library':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MediaLibraryPage(),
          ),
        );
        break;
      // Add other cases as needed
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feature "$menuId" coming soon!'),
            backgroundColor: AdminColors.info,
          ),
        );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari panel admin?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.roboto(
                color: AdminColors.darkGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AdminFirebaseService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AdminColors.error;
      case 'binkar':
        return AdminColors.adminPurple;
      case 'public':
        return AdminColors.adminGreen;
      default:
        return AdminColors.lightGray;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'korbrimob':
        return AdminColors.primaryBlue;
      case 'binkar':
        return AdminColors.adminPurple;
      case 'dalpers':
        return AdminColors.adminRed;
      case 'watpers':
        return AdminColors.adminGreen;
      case 'psikologi':
        return AdminColors.info;
      default:
        return AdminColors.lightGray;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}