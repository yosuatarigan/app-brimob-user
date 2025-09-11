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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await AdminFirebaseService.getAllUsersWithApproval();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchesRole = _selectedRole == 'all' || user.role.name == _selectedRole;
        final matchesStatus = _selectedStatus == 'all' || user.status.name == _selectedStatus;
        final matchesSearch =
            user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.nrp.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesRole && matchesStatus && matchesSearch;
      }).toList();
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
        onPressed: _showCreateUserDialog,
      ),
    );
  }

  Widget _buildHeader() {
    final pendingCount = _allUsers.where((u) => u.status == UserStatus.pending).length;
    final approvedCount = _allUsers.where((u) => u.status == UserStatus.approved).length;
    final rejectedCount = _allUsers.where((u) => u.status == UserStatus.rejected).length;

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
            placeholder: (context, url) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AdminColors.adminGradient),
              ),
            ),
            errorWidget: (context, url, error) => Container(
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
                const SizedBox(height: AdminSizes.paddingS),
                Row(
                  children: [
                    _buildQuickStat('Total Users', '${_allUsers.length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Pending', '$pendingCount', color: AppColors.goldYellow),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Approved', '$approvedCount', color: AppColors.green),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Rejected', '$rejectedCount', color: AppColors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? AdminColors.adminGold,
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
                      ...UserRole.values.map((role) => 
                        _buildRoleChip(role.name, role.displayName)
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
                      ...UserStatus.values.map((status) => 
                        _buildStatusChip(status.name, status.displayName)
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
        selectedColor: AdminColors.success.withOpacity(0.1),
        checkmarkColor: AdminColors.success,
        labelStyle: GoogleFonts.roboto(
          color: isSelected ? AdminColors.success : AdminColors.darkGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AdminColors.success : AdminColors.borderColor,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final pendingCount = _allUsers.where((u) => u.status == UserStatus.pending).length;
    final approvedCount = _allUsers.where((u) => u.status == UserStatus.approved).length;
    final rejectedCount = _allUsers.where((u) => u.status == UserStatus.rejected).length;

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AdminColors.primaryBlue,
        unselectedLabelColor: AdminColors.darkGray,
        indicatorColor: AdminColors.primaryBlue,
        labelStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _filteredUsers = _allUsers;
                break;
              case 1:
                _filteredUsers = _allUsers.where((u) => u.status == UserStatus.pending).toList();
                break;
              case 2:
                _filteredUsers = _allUsers.where((u) => u.status == UserStatus.approved).toList();
                break;
              case 3:
                _filteredUsers = _allUsers.where((u) => u.status == UserStatus.rejected).toList();
                break;
              case 4:
                _filteredUsers = List.from(_allUsers)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                break;
            }
          });
        },
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

    if (_filteredUsers.isEmpty) {
      return AdminEmptyState(
        icon: Icons.people_outline,
        title: 'Belum Ada User',
        message: 'Tambah user pertama untuk aplikasi',
        actionText: 'Tambah User',
        onAction: _showCreateUserDialog,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildUserList(_filteredUsers),
        _buildUserList(_allUsers.where((u) => u.status == UserStatus.pending).toList()),
        _buildUserList(_allUsers.where((u) => u.status == UserStatus.approved).toList()),
        _buildUserList(_allUsers.where((u) => u.status == UserStatus.rejected).toList()),
        _buildUserList(
          List.from(_allUsers)..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
      ],
    );
  }

  Widget _buildUserList(List<UserModel> users) {
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
                  backgroundImage: user.photoUrl != null
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
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
                          AdminStatusChip(
                            text: user.role.displayName,
                            color: _getRoleColor(user.role),
                            // fontSize: 10,
                          ),
                          const SizedBox(width: AdminSizes.paddingS),
                          AdminStatusChip(
                            text: user.status.displayName,
                            color: _getStatusColor(user.status),
                            icon: _getStatusIcon(user.status),
                            // fontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(value, user),
                  itemBuilder: (context) => [
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
                            Icon(Icons.check_circle, size: 18, color: Colors.green),
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
                            Icon(Icons.check_circle, size: 18, color: Colors.green),
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
                          Text('Delete', style: TextStyle(color: Colors.red)),
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
                  _buildUserStat('Masa Dinas', '${user.yearsOfService} tahun', Icons.military_tech),
                  _buildUserStat('Tanggal Daftar', _formatDate(user.createdAt), Icons.calendar_today),
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
                          borderRadius: BorderRadius.circular(AdminSizes.radiusS),
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
                          borderRadius: BorderRadius.circular(AdminSizes.radiusS),
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

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        onUserCreated: () {
          _loadUsers();
        },
      ),
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
    try {
      await AdminFirebaseService.approveUser(user.id);
      _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${user.fullName} telah disetujui'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.red,
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
      try {
        await AdminFirebaseService.rejectUser(user.id, result);
        _loadUsers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${user.fullName} telah ditolak'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    }
  }

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onUserUpdated: () {
          _loadUsers();
        },
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
              Navigator.pop(context);
              try {
                await AdminFirebaseService.resetUserPassword(user.email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: AdminColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AdminColors.error,
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AdminFirebaseService.deleteUser(user.id);
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: AdminColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AdminColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.makoKor:
        return AdminColors.error;
      case UserRole.pasPelopor:
        return AdminColors.adminPurple;
      case UserRole.pasGegana:
        return AdminColors.success;
      case UserRole.pasbrimobI:
        return AdminColors.warning;
      case UserRole.pasbrimobII:
        return AdminColors.info;
      case UserRole.pasbrimobIII:
        return Colors.teal;
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
          ..._predefinedReasons.map((reason) => RadioListTile<String>(
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
          )),
          RadioListTile<String>(
            title: Text('Lainnya', style: GoogleFonts.roboto(fontSize: 14)),
            value: 'custom',
            groupValue: _reasonController.text.isEmpty ? null : 
                      _predefinedReasons.contains(_reasonController.text) ? null : 'custom',
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
          onPressed: _reasonController.text.isNotEmpty
              ? () => Navigator.pop(context, _reasonController.text)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
          ),
          child: Text(
            'Reject',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
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
                  backgroundImage: user.photoUrl != null
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
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
            _buildDetailRow('Tanggal Masuk Militer', user.formattedMilitaryJoinDate),
            _buildDetailRow('Masa Dinas', '${user.yearsOfService} tahun'),
            _buildDetailRow('Status', user.status.displayName),
            _buildDetailRow('Tanggal Daftar', user.formattedDateOfBirth),
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
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(),
            ),
          ),
        ],
      ),
    );
  }
}

// Simplified Create and Edit dialogs can be added here
class CreateUserDialog extends StatefulWidget {
  final VoidCallback onUserCreated;

  const CreateUserDialog({super.key, required this.onUserCreated});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  UserRole _selectedRole = UserRole.makoKor;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Create New User',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role/Satuan',
                prefixIcon: Icon(Icons.security),
              ),
              items: UserRole.values.map((role) => DropdownMenuItem(
                value: role,
                child: Text(role.displayName),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.roboto(color: AdminColors.darkGray),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryBlue,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Create',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
        ),
      ],
    );
  }

  void _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create user with UserModel system (approved by default when created by admin)
      final userModel = UserModel(
        id: '', // Will be set by Firestore
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        nrp: 'AUTO-${DateTime.now().millisecondsSinceEpoch}', // Auto generate for admin-created users
        rank: 'BHARADA', // Default rank
        role: _selectedRole,
        status: UserStatus.approved, // Admin-created users are approved by default
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default age 25
        militaryJoinDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // Default 2 years service
        createdAt: DateTime.now(),
      );

      // This would need a new method in AdminFirebaseService for creating UserModel directly
      // For now, show message that this feature needs implementation
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Direct user creation feature coming soon. Users should register through app.'),
          backgroundColor: AdminColors.warning,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AdminColors.error,
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

class EditUserDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback onUserUpdated;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _rankController = TextEditingController();

  late UserRole _selectedRole;
  late UserStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.fullName;
    _nrpController.text = widget.user.nrp;
    _rankController.text = widget.user.rank;
    _selectedRole = widget.user.role;
    _selectedStatus = widget.user.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit User',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            TextFormField(
              controller: _nrpController,
              decoration: const InputDecoration(
                labelText: 'NRP',
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NRP is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            DropdownButtonFormField<String>(
              value: _rankController.text.isEmpty ? MenuData.militaryRanks.first : _rankController.text,
              decoration: const InputDecoration(
                labelText: 'Rank',
                prefixIcon: Icon(Icons.military_tech),
              ),
              items: MenuData.militaryRanks.map((rank) => DropdownMenuItem(
                value: rank,
                child: Text(rank),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _rankController.text = value!;
                });
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role/Satuan',
                prefixIcon: Icon(Icons.group),
              ),
              items: UserRole.values.map((role) => DropdownMenuItem(
                value: role,
                child: Text(role.displayName),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            DropdownButtonFormField<UserStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.check_circle),
              ),
              items: UserStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.roboto(color: AdminColors.darkGray),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryBlue,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Update',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
        ),
      ],
    );
  }

  void _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        fullName: _nameController.text.trim(),
        nrp: _nrpController.text.trim(),
        rank: _rankController.text.trim(),
        role: _selectedRole,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      await AdminFirebaseService.updateUserModel(widget.user.id, updatedUser);

      if (mounted) {
        Navigator.pop(context);
        widget.onUserUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully!'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AdminColors.error,
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