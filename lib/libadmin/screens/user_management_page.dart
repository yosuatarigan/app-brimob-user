import 'dart:io';

import 'package:app_brimob_user/create_user_page.dart';
import 'package:app_brimob_user/edit_profile_page.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:app_brimob_user/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  bool _isExporting = false;
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

  void _exportToPdf(UserModel user) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Generate PDF
      final pdfData = await PdfService.generateCvPdf(user);

      // Buat nama file
      final fileName =
          'CV_${user.fullName.replaceAll(' ', '_')}_${user.nrp}.pdf';

      // Save ke temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfData);

      // Langsung share file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'CV ${user.fullName} - ${user.nrp}',
        subject: 'Curriculum Vitae',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('CV siap dibagikan!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gagal membuat CV: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
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
                user.nrp.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (user.jabatan.isNotEmpty &&
                    user.jabatan.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    )) ||
                (user.rank.isNotEmpty &&
                    user.rank.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ));

            return matchesRole && matchesStatus && matchesSearch;
          }).toList();
    });
  }

  // Navigate to create user page
  void _navigateToCreateUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateUserPage()),
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
        onPressed: _navigateToCreateUser,
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
                        'Manajemen Personel Brimob',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
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
                  'Kelola data personel dan persetujuan pendaftaran',
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
              hintText: 'Cari personel (nama, email, NRP, jabatan, pangkat)...',
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
                        'Satuan: ',
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
    return const AdminLoadingWidget(message: 'Memuat data personel...');
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
        title: 'Belum Ada Personel',
        message: 'Tambah data personel pertama untuk aplikasi',
        actionText: 'Tambah Personel',
        onAction: _navigateToCreateUser,
      );
    }

    // Gunakan _filteredUsers sebagai basis, lalu filter lagi berdasarkan tab
    final allUsers = _filteredUsers;
    final pendingUsers =
        _filteredUsers.where((u) => u.status == UserStatus.pending).toList();
    final approvedUsers =
        _filteredUsers.where((u) => u.status == UserStatus.approved).toList();
    final rejectedUsers =
        _filteredUsers.where((u) => u.status == UserStatus.rejected).toList();
    final recentUsers = List<UserModel>.from(_filteredUsers)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return TabBarView(
      controller: _tabController,
      children: [
        _buildUserList(allUsers),
        _buildUserList(pendingUsers),
        _buildUserList(approvedUsers),
        _buildUserList(rejectedUsers),
        _buildUserList(recentUsers),
      ],
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return AdminEmptyState(
        icon: Icons.people_outline,
        title: 'Tidak Ada Data',
        message: 'Tidak ada personel untuk kategori ini',
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
                  radius: 35,
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                  backgroundImage:
                      user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : null,
                  child:
                      user.photoUrl == null || user.photoUrl!.isEmpty
                          ? Icon(
                            Icons.person,
                            size: 35,
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
                        user.fullName,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.adminDark,
                        ),
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),

                      // Pangkat & Jabatan
                      if (user.rank.isNotEmpty || user.jabatan.isNotEmpty)
                        Text(
                          [
                            user.rank,
                            user.jabatan,
                          ].where((s) => s.isNotEmpty).join(' • '),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AdminColors.darkGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      const SizedBox(height: AdminSizes.paddingXS),

                      Text(
                        user.email,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
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

                      const SizedBox(height: AdminSizes.paddingS),

                      Row(
                        children: [
                          _buildStatusChipWidget(
                            text: user.role.displayName,
                            color: _getRoleColor(user.role),
                            icon: Icons.group,
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
                              Text('Lihat Detail'),
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
                                Text('Setujui'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'reject',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Tolak'),
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
                                Text('Setujui'),
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
                          value: 'export',
                          child: Row(
                            children: [
                              Icon(
                                Icons.import_export,
                                size: 18,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Export',
                                style: TextStyle(color: Colors.red),
                              ),
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
                                'Hapus',
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

            // Additional Info Card
            Container(
              padding: const EdgeInsets.all(AdminSizes.paddingM),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(AdminSizes.radiusS),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildUserStat(
                        'Umur',
                        user.dateOfBirth != null ? '${user.age} thn' : '-',
                        Icons.cake,
                      ),
                      _buildUserStat(
                        'Masa Dinas',
                        user.militaryJoinDate != null
                            ? '${user.yearsOfService} thn'
                            : '-',
                        Icons.military_tech,
                      ),
                      _buildUserStat(
                        'Daftar',
                        _formatDate(user.createdAt),
                        Icons.calendar_today,
                      ),
                    ],
                  ),

                  // Additional info row
                  if (user.tempatLahir != null ||
                      user.agama != null ||
                      user.statusPersonel != null) ...[
                    const SizedBox(height: AdminSizes.paddingS),
                    const Divider(height: 1),
                    const SizedBox(height: AdminSizes.paddingS),
                    Row(
                      children: [
                        if (user.tempatLahir != null)
                          Expanded(
                            child: _buildInfoItem(
                              'Tempat Lahir',
                              user.tempatLahir!,
                              Icons.location_on,
                            ),
                          ),
                        if (user.agama != null)
                          Expanded(
                            child: _buildInfoItem(
                              'Agama',
                              user.agama!,
                              Icons.mosque,
                            ),
                          ),
                        if (user.statusPersonel != null)
                          Expanded(
                            child: _buildInfoItem(
                              'Status',
                              user.statusPersonel!,
                              Icons.person_pin,
                            ),
                          ),
                      ],
                    ),
                  ],
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
                      label: const Text('Setujui'),
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
                      label: const Text('Tolak'),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 14, color: AdminColors.lightGray),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 9, color: AdminColors.lightGray),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AdminColors.darkGray,
          ),
          textAlign: TextAlign.center,
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
      case 'export':
        _exportToPdf(user);
        // Implement export functionality here
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
      builder:
          (BuildContext loadingContext) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AdminSizes.paddingM),
                Text('Menyetujui personel...', style: GoogleFonts.roboto()),
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
            content: Text('Personel ${user.fullName} telah disetujui'),
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
        builder:
            (BuildContext loadingContext) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AdminSizes.paddingM),
                  Text('Menolak personel...', style: GoogleFonts.roboto()),
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
              content: Text('Personel ${user.fullName} telah ditolak'),
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
    Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentUser: user, isAdmin: true),
      ),
    );
  }

  void _showResetPasswordDialog(UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Reset Password',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Kirim email reset password ke ${user.email}?',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
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
                    builder:
                        (BuildContext loadingContext) => AlertDialog(
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
                          content: Text('Email reset password telah dikirim!'),
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
                  'Kirim Email',
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
      builder:
          (context) => AlertDialog(
            title: Text(
              'Hapus Personel',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Yakin ingin menghapus ${user.fullName}? Tindakan ini tidak dapat dibatalkan.',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
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
                  'Hapus',
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
              content: Text(result['message'] ?? 'Personel berhasil dihapus'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus personel'),
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
      case UserRole.satlatihan:
        return AppColors.lightBlue;
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
        'Alasan Penolakan',
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
            'Batal',
            style: GoogleFonts.roboto(color: AdminColors.darkGray),
          ),
        ),
        ElevatedButton(
          onPressed:
              _reasonController.text.isNotEmpty
                  ? () => Navigator.pop(context, _reasonController.text)
                  : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
          child: Text('Tolak', style: GoogleFonts.roboto(color: Colors.white)),
        ),
      ],
    );
  }
}

// Enhanced User Detail Dialog with complete personnel information
class UserDetailDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AdminSizes.paddingL),
              decoration: BoxDecoration(
                color: AdminColors.primaryBlue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AdminSizes.radiusM),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                    child:
                        user.photoUrl == null || user.photoUrl!.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 30,
                              color: AdminColors.primaryBlue,
                            )
                            : null,
                  ),
                  const SizedBox(width: AdminSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (user.rank.isNotEmpty || user.jabatan.isNotEmpty)
                          Text(
                            [
                              user.rank,
                              user.jabatan,
                            ].where((s) => s.isNotEmpty).join(' • '),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        Text(
                          user.role.displayName,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AdminSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSection('Data Dasar', [
                      _buildDetailRow('Email', user.email),
                      //no hp
                      _buildDetailRow("No. Hp", user.phoneNumber ?? '-'),

                      _buildDetailRow('NRP', user.nrp),
                      if (user.statusPersonel != null)
                        _buildDetailRow(
                          'Status Personel',
                          user.statusPersonel!,
                        ),
                      _buildDetailRow('Status Akun', user.status.displayName),
                      if (user.rejectionReason != null)
                        _buildDetailRow(
                          'Alasan Penolakan',
                          user.rejectionReason!,
                        ),
                    ]),

                    const SizedBox(height: AdminSizes.paddingL),

                    // Personal Information
                    if (user.tempatLahir != null ||
                        user.dateOfBirth != null ||
                        user.agama != null)
                      _buildSection('Data Personal', [
                        if (user.tempatTanggalLahir.isNotEmpty)
                          _buildDetailRow(
                            'Tempat, Tanggal Lahir',
                            user.tempatTanggalLahir,
                          ),
                        if (user.dateOfBirth != null)
                          _buildDetailRow('Umur', '${user.age} tahun'),
                        if (user.agama != null)
                          _buildDetailRow('Agama', user.agama!),
                        if (user.suku != null)
                          _buildDetailRow('Suku', user.suku!),
                        if (user.bloodType != null)
                          _buildDetailRow('Golongan Darah', user.bloodType!),
                        if (user.maritalStatus != null)
                          _buildDetailRow(
                            'Status Pernikahan',
                            user.maritalStatus!,
                          ),
                      ]),

                    const SizedBox(height: AdminSizes.paddingL),

                    // Military Service Information
                    if (user.militaryJoinDate != null ||
                        user.jabatanTmt != null)
                      _buildSection('Data Dinas', [
                        if (user.militaryJoinDate != null) ...[
                          _buildDetailRow(
                            'TMT Masuk Polri ',
                            _formatDate(user.militaryJoinDate),
                          ),
                          _buildDetailRow(
                            'Masa Dinas',
                            '${user.yearsOfService} tahun',
                          ),
                        ],
                        if (user.jabatanTmt != null) ...[
                          _buildDetailRow(
                            'TMT Jabatan',
                            user.formattedJabatanTmt,
                          ),
                          _buildDetailRow('Lama Jabatan', user.lamaJabatan),
                        ],
                      ]),

                    const SizedBox(height: AdminSizes.paddingL),

                    // Contact Information
                    if (user.phoneNumber != null ||
                        user.address != null ||
                        user.emergencyContact != null)
                      _buildSection('Informasi Kontak', [
                        if (user.phoneNumber != null)
                          _buildDetailRow('Telepon', user.phoneNumber!),
                        if (user.address != null)
                          _buildDetailRow('Alamat', user.address!),
                        if (user.emergencyContact != null)
                          _buildDetailRow(
                            'Kontak Darurat',
                            user.emergencyContact!,
                          ),
                      ]),

                    const SizedBox(height: AdminSizes.paddingL),

                    // Complex Data Sections
                    if (user.pendidikanKepolisian.isNotEmpty)
                      _buildComplexSection(
                        'Pendidikan Kepolisian',
                        user.pendidikanKepolisian
                            .map((e) => '${e.tingkat} (${e.tahun})')
                            .toList(),
                      ),

                    if (user.pendidikanUmum.isNotEmpty)
                      _buildComplexSection(
                        'Pendidikan Umum',
                        user.pendidikanUmum
                            .map(
                              (e) =>
                                  '${e.tingkat} - ${e.namaInstitusi} (${e.tahun})',
                            )
                            .toList(),
                      ),

                    if (user.riwayatPangkat.isNotEmpty)
                      _buildComplexSection(
                        'Riwayat Pangkat',
                        user.riwayatPangkat
                            .map((e) => '${e.pangkat} - ${_formatDate(e.tmt)}')
                            .toList(),
                      ),

                    if (user.riwayatJabatan.isNotEmpty)
                      _buildComplexSection(
                        'Riwayat Jabatan',
                        user.riwayatJabatan
                            .map((e) => '${e.jabatan} - ${_formatDate(e.tmt)}')
                            .toList(),
                      ),

                    if (user.pendidikanPelatihan.isNotEmpty)
                      _buildComplexSection(
                        'Pendidikan & Pelatihan',
                        user.pendidikanPelatihan
                            .map((e) => '${e.dikbang} - ${_formatDate(e.tmt)}')
                            .toList(),
                      ),

                    if (user.tandaKehormatan.isNotEmpty)
                      _buildComplexSection(
                        'Tanda Kehormatan',
                        user.tandaKehormatan
                            .map(
                              (e) =>
                                  '${e.tandaKehormatan} - ${_formatDate(e.tmt)}',
                            )
                            .toList(),
                      ),

                    if (user.kemampuanBahasa.isNotEmpty)
                      _buildComplexSection(
                        'Kemampuan Bahasa',
                        user.kemampuanBahasa
                            .map((e) => '${e.bahasa} (${e.status})')
                            .toList(),
                      ),

                    if (user.penugasanLuarStruktur.isNotEmpty)
                      _buildComplexSection(
                        'Penugasan Luar Struktur',
                        user.penugasanLuarStruktur
                            .map((e) => '${e.penugasan} - ${e.lokasi}')
                            .toList(),
                      ),

                    const SizedBox(height: AdminSizes.paddingL),

                    // System Information
                    _buildSection('Informasi Sistem', [
                      _buildDetailRow(
                        'Tanggal Daftar',
                        _formatDate(user.createdAt),
                      ),
                      if (user.updatedAt != null)
                        _buildDetailRow(
                          'Terakhir Diupdate',
                          _formatDate(user.updatedAt),
                        ),
                      if (user.approvedBy != null)
                        _buildDetailRow('Disetujui Oleh', user.approvedBy!),
                      if (user.approvedAt != null)
                        _buildDetailRow(
                          'Tanggal Persetujuan',
                          _formatDate(user.approvedAt),
                        ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminSizes.paddingM,
            vertical: AdminSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: AdminColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
          ),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AdminColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: AdminSizes.paddingM),
        ...children,
      ],
    );
  }

  Widget _buildComplexSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminSizes.paddingM,
            vertical: AdminSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: AdminColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
          ),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AdminColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: AdminSizes.paddingM),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
            border: Border.all(color: AdminColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AdminColors.primaryBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  color: AdminColors.darkGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: AdminSizes.paddingL),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminSizes.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: AdminColors.darkGray,
                fontSize: 13,
              ),
            ),
          ),
          Text(' : '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AdminColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
