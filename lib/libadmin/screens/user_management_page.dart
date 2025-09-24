import 'package:app_brimob_user/create_user_page.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../admin_constant.dart';
import '../services/admin_firebase_service.dart';
import '../../models/user_model.dart';
import '../../constants/app_constants.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  String _selectedRole = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';
  
  // Track loading states for individual users
  Set<String> _loadingUsers = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await AdminFirebaseService.getAllUsersWithApproval();
      
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers =
          _allUsers.where((user) {
            final matchesRole =
                _selectedRole == 'all' || user.role.name == _selectedRole;
            final matchesStatus =
                _selectedStatus == 'all' || user.status.name == _selectedStatus;
            final matchesSearch =
                user.fullName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.nrp.toLowerCase().contains(_searchQuery.toLowerCase());

            return matchesRole && matchesStatus && matchesSearch;
          }).toList();
    });
  }

  // Navigate to create user page
  void _navigateToCreateUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateUserPage(),
      ),
    ).then((_) {
      // Reload users after returning from create page
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterSection(),
            _buildTabBar(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: AdminFloatingActionButton(
        icon: Icons.person_add,
        label: 'Tambah User',
        onPressed: _navigateToCreateUser, // Updated to navigate to page
      ),
    );
  }

  Widget _buildHeader() {
    final pendingCount =
        _allUsers.where((u) => u.status == UserStatus.pending).length;

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AdminColors.adminGradient),
      ),
      child: Stack(
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl: AdminImages.userManagement,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AdminColors.adminGradient),
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AdminColors.adminGradient),
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: AdminSizes.paddingS),
                    Expanded(
                      child: Text(
                        'User Management',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount pending',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                    const SizedBox(width: AdminSizes.paddingS),
                    IconButton(
                      onPressed: _loadUsers,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Kelola pengguna dan persetujuan pendaftaran',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AdminSizes.paddingM),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              _searchQuery = value;
              _filterUsers();
            },
            decoration: InputDecoration(
              hintText: 'Cari pengguna (nama, email, NRP)...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                borderSide: BorderSide(color: AdminColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                borderSide: BorderSide(color: AdminColors.borderColor),
              ),
              filled: true,
              fillColor: AdminColors.background,
            ),
          ),

          const SizedBox(height: AdminSizes.paddingM),

          // Filters
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Role: ',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.darkGray,
                        ),
                      ),
                      _buildRoleChip('all', 'Semua'),
                      ...UserRole.values.map(
                        (role) => _buildRoleChip(role.name, role.displayName),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AdminSizes.paddingS),

          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Status: ',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.darkGray,
                        ),
                      ),
                      _buildStatusChip('all', 'Semua'),
                      ...UserStatus.values.map(
                        (status) =>
                            _buildStatusChip(status.name, status.displayName),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String roleId, String title) {
    final isSelected = _selectedRole == roleId;
    return Padding(
      padding: const EdgeInsets.only(right: AdminSizes.paddingS),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedRole = roleId;
          });
          _filterUsers();
        },
        backgroundColor: Colors.white,
        selectedColor: AdminColors.primaryBlue.withOpacity(0.1),
        checkmarkColor: AdminColors.primaryBlue,
        labelStyle: GoogleFonts.roboto(
          color: isSelected ? AdminColors.primaryBlue : AdminColors.darkGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AdminColors.primaryBlue : AdminColors.borderColor,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statusId, String title) {
    final isSelected = _selectedStatus == statusId;
    return Padding(
      padding: const EdgeInsets.only(right: AdminSizes.paddingS),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = statusId;
          });
          _filterUsers();
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.green.withOpacity(0.1),
        checkmarkColor: AppColors.green,
        labelStyle: GoogleFonts.roboto(
          color: isSelected ? AppColors.green : AdminColors.darkGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.green : AdminColors.borderColor,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final pendingCount =
        _allUsers.where((u) => u.status == UserStatus.pending).length;
    final approvedCount =
        _allUsers.where((u) => u.status == UserStatus.approved).length;
    final rejectedCount =
        _allUsers.where((u) => u.status == UserStatus.rejected).length;

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AdminColors.primaryBlue,
        unselectedLabelColor: AdminColors.darkGray,
        indicatorColor: AdminColors.primaryBlue,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        isScrollable: true,
        tabs: [
          Tab(text: 'Semua (${_allUsers.length})'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pending'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(text: 'Approved ($approvedCount)'),
          Tab(text: 'Rejected ($rejectedCount)'),
          Tab(text: 'Recent'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const AdminLoadingWidget(message: 'Memuat users...');
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Users',
        message: _error!,
        onRetry: _loadUsers,
      );
    }

    if (_allUsers.isEmpty) {
      return AdminEmptyState(
        icon: Icons.people_outline,
        title: 'Belum Ada User',
        message: 'Tambah user pertama untuk aplikasi',
        actionText: 'Tambah User',
        onAction: _navigateToCreateUser,
      );
    }

    // Siapkan data untuk setiap tab
    final allUsers = _allUsers;
    final pendingUsers =
        _allUsers.where((u) => u.status == UserStatus.pending).toList();
    final approvedUsers =
        _allUsers.where((u) => u.status == UserStatus.approved).toList();
    final rejectedUsers =
        _allUsers.where((u) => u.status == UserStatus.rejected).toList();
    final recentUsers = List.from(_allUsers)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return TabBarView(
      controller: _tabController,
      children: [
        _buildUserList(allUsers),
        _buildUserList(pendingUsers),
        _buildUserList(approvedUsers),
        _buildUserList(rejectedUsers),
        _buildUserList(recentUsers.cast<UserModel>()),
      ],
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return AdminEmptyState(
        icon: Icons.people_outline,
        title: 'Tidak Ada Data',
        message: 'Tidak ada user untuk kategori ini',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: AdminSizes.paddingM),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                  backgroundImage:
                      user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : null,
                  child:
                      user.photoUrl == null || user.photoUrl!.isEmpty
                          ? Icon(
                            Icons.person,
                            size: 30,
                            color: _getRoleColor(user.role),
                          )
                          : null,
                ),

                const SizedBox(width: AdminSizes.paddingM),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.adminDark,
                        ),
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),
                      Text(
                        user.email,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AdminColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),
                      Text(
                        'NRP: ${user.nrp}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AdminColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),
                      Row(
                        children: [
                          _buildStatusChipWidget(
                            text: user.role.displayName,
                            color: _getRoleColor(user.role),
                          ),
                          const SizedBox(width: AdminSizes.paddingS),
                          _buildStatusChipWidget(
                            text: user.status.displayName,
                            color: _getStatusColor(user.status),
                            icon: _getStatusIcon(user.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(value, user),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 18),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        if (user.status == UserStatus.pending) ...[
                          const PopupMenuItem(
                            value: 'approve',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text('Approve'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'reject',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Reject'),
                              ],
                            ),
                          ),
                        ],
                        if (user.status == UserStatus.rejected) ...[
                          const PopupMenuItem(
                            value: 'approve',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text('Approve'),
                              ],
                            ),
                          ),
                        ],
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'reset_password',
                          child: Row(
                            children: [
                              Icon(Icons.lock_reset, size: 18),
                              SizedBox(width: 8),
                              Text('Reset Password'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: AdminSizes.paddingM),

            // User stats
            Container(
              padding: const EdgeInsets.all(AdminSizes.paddingM),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(AdminSizes.radiusS),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildUserStat('Umur', '${user.age} tahun', Icons.cake),
                  _buildUserStat(
                    'Masa Dinas',
                    '${user.yearsOfService} tahun',
                    Icons.military_tech,
                  ),
                  _buildUserStat(
                    'Tanggal Daftar',
                    _formatDate(user.createdAt),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),

            // Approval actions for pending users
            if (user.status == UserStatus.pending) ...[
              const SizedBox(height: AdminSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveUser(user),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AdminSizes.radiusS,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AdminSizes.paddingS),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectUser(user),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AdminSizes.radiusS,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChipWidget({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminSizes.paddingS,
        vertical: AdminSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminSizes.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AdminSizes.paddingXS),
          ],
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AdminColors.lightGray),
        const SizedBox(height: AdminSizes.paddingXS),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 10, color: AdminColors.lightGray),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AdminColors.darkGray,
          ),
        ),
      ],
    );
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'approve':
        _approveUser(user);
        break;
      case 'reject':
        _rejectUser(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'reset_password':
        _showResetPasswordDialog(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(user: user),
    );
  }

  Future<void> _approveUser(UserModel user) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AdminSizes.paddingM),
            Text(
              'Menyetujui user...',
              style: GoogleFonts.roboto(),
            ),
          ],
        ),
      ),
    );

    try {
      await AdminFirebaseService.approveUser(user.id);
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Refresh and show success
      if (mounted) {
        _loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${user.fullName} telah disetujui'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(UserModel user) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => RejectUserDialog(),
    );

    if (result != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext loadingContext) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AdminSizes.paddingM),
              Text(
                'Menolak user...',
                style: GoogleFonts.roboto(),
              ),
            ],
          ),
        ),
      );

      try {
        await AdminFirebaseService.rejectUser(user.id, result);
        
        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }
        
        // Refresh and show success
        if (mounted) {
          _loadUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${user.fullName} telah ditolak'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }
        
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showEditUserDialog(UserModel user) {
    // For now, navigate to create page with edit mode (could be enhanced later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature edit akan ditambahkan di versi selanjutnya'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResetPasswordDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Send password reset email to ${user.email}?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: AdminColors.darkGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AdminSizes.paddingM),
                      Text(
                        'Mengirim email reset...',
                        style: GoogleFonts.roboto(),
                      ),
                    ],
                  ),
                ),
              );

              try {
                await AdminFirebaseService.resetUserPassword(user.email);
                
                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context);
                }
                
                // Show success
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: AppColors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (mounted) {
                  Navigator.pop(context);
                }
                
                // Show error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryBlue,
            ),
            child: Text(
              'Send Email',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete User',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: AdminColors.darkGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUserSimple(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserSimple(UserModel user) async {
    // Set loading state for this user
    setState(() {
      _loadingUsers.add(user.id);
    });

    try {
      final result = await AdminFirebaseService.deleteUserCompletely(user.id);
      
      if (mounted) {
        // Clear loading state
        setState(() {
          _loadingUsers.remove(user.id);
        });
        
        if (result['success'] == true) {
          // Refresh user list
          await _loadUsers();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'User berhasil dihapus'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus user'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Clear loading state
        setState(() {
          _loadingUsers.remove(user.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _performDeleteUser(UserModel user) async {
    // Show loading dialog
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AdminSizes.paddingM),
              Text(
                'Menghapus user ${user.fullName}...',
                style: GoogleFonts.roboto(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      print('Starting delete operation for user: ${user.id}');
      final result = await AdminFirebaseService.deleteUserCompletely(user.id);
      print('Delete operation completed: ${result.toString()}');
      
      // Force close loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Small delay to ensure dialog is closed
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        if (result['success'] == true) {
          print('Delete successful, refreshing user list...');
          await _loadUsers(); // Refresh list
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'User berhasil dihapus'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          print('Delete failed: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus user'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Delete error: $e');
      
      // Force close loading dialog
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (navError) {
          print('Error closing dialog: $navError');
        }
      }
      
      // Small delay
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Helper methods untuk warna yang diperbaiki
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.purple;
      case UserRole.makoKor:
        return AppColors.red;
      case UserRole.pasPelopor:
        return AppColors.purple;
      case UserRole.pasGegana:
        return AppColors.green;
      case UserRole.pasbrimobI:
        return AppColors.orange;
      case UserRole.pasbrimobII:
        return AppColors.info;
      case UserRole.pasbrimobIII:
        return AppColors.teal;
      case UserRole.other:
        return AppColors.darkGray;
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.pending:
        return AppColors.goldYellow;
      case UserStatus.approved:
        return AppColors.green;
      case UserStatus.rejected:
        return AppColors.red;
    }
  }

  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.pending:
        return Icons.schedule;
      case UserStatus.approved:
        return Icons.check_circle;
      case UserStatus.rejected:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Keep existing dialogs for now (RejectUserDialog, UserDetailDialog)
// Dialog for rejecting user with reason
class RejectUserDialog extends StatefulWidget {
  @override
  State<RejectUserDialog> createState() => _RejectUserDialogState();
}

class _RejectUserDialogState extends State<RejectUserDialog> {
  final _reasonController = TextEditingController();
  final _predefinedReasons = [
    'Data tidak lengkap',
    'Dokumen tidak valid',
    'Informasi tidak sesuai',
    'Tidak memenuhi syarat',
    'Duplikasi akun',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Reject User',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih alasan penolakan:',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AdminSizes.paddingS),
          ..._predefinedReasons.map(
            (reason) => RadioListTile<String>(
              title: Text(reason, style: GoogleFonts.roboto(fontSize: 14)),
              value: reason,
              groupValue: _reasonController.text,
              onChanged: (value) {
                setState(() {
                  _reasonController.text = value!;
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          RadioListTile<String>(
            title: Text('Lainnya', style: GoogleFonts.roboto(fontSize: 14)),
            value: 'custom',
            groupValue:
                _reasonController.text.isEmpty
                    ? null
                    : _predefinedReasons.contains(_reasonController.text)
                    ? null
                    : 'custom',
            onChanged: (value) {
              setState(() {
                _reasonController.text = '';
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          if (!_predefinedReasons.contains(_reasonController.text)) ...[
            const SizedBox(height: AdminSizes.paddingS),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.roboto(color: AdminColors.darkGray),
          ),
        ),
        ElevatedButton(
          onPressed:
              _reasonController.text.isNotEmpty
                  ? () => Navigator.pop(context, _reasonController.text)
                  : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
          child: Text('Reject', style: GoogleFonts.roboto(color: Colors.white)),
        ),
      ],
    );
  }
}

// User Detail Dialog
class UserDetailDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      user.photoUrl != null
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : null,
                  child:
                      user.photoUrl == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.role.displayName,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AdminColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AdminSizes.paddingL),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('NRP', user.nrp),
            _buildDetailRow('Pangkat', user.rank),
            _buildDetailRow('Umur', '${user.age} tahun'),
            _buildDetailRow('Tanggal Lahir', user.formattedDateOfBirth),
            _buildDetailRow(
              'Tanggal Masuk Militer',
              user.formattedMilitaryJoinDate,
            ),
            _buildDetailRow('Masa Dinas', '${user.yearsOfService} tahun'),
            _buildDetailRow('Status', user.status.displayName),
            _buildDetailRow('Tanggal Daftar', user.formattedMilitaryJoinDate ),
            if (user.rejectionReason != null)
              _buildDetailRow('Alasan Penolakan', user.rejectionReason!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminSizes.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: AdminColors.darkGray,
              ),
            ),
          ),
          Text(' : '),
          Expanded(child: Text(value, style: GoogleFonts.roboto())),
        ],
      ),
    );
  }
}