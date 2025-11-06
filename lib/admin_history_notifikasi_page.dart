// lib/libadmin/screens/notification_history_page.dart
import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:app_brimob_user/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../notification_model.dart';

class AdminNotificationHistoryPage extends StatefulWidget {
  const AdminNotificationHistoryPage({super.key});

  @override
  State<AdminNotificationHistoryPage> createState() =>
      _AdminNotificationHistoryPageState();
}

class _AdminNotificationHistoryPageState
    extends State<AdminNotificationHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  NotificationStats? _stats;
  bool _isLoading = true;
  String? _error;
  String _selectedType = 'all';
  String _selectedTarget = 'all';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
    _loadStats();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Listen to notification history stream
      NotificationService.getNotificationHistory().listen((notifications) {
        setState(() {
          _allNotifications = notifications;
          _filteredNotifications = notifications;
          _isLoading = false;
        });
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await NotificationService.getNotificationStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Error loading notification stats: $e');
    }
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AdminColors.error,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hapus Semua Notifikasi?',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anda akan menghapus SEMUA notifikasi (${_allNotifications.length} notifikasi) secara permanen.',
                  style: GoogleFonts.roboto(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AdminColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AdminColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tindakan ini tidak dapat dibatalkan!',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AdminColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.roboto(
                    color: AdminColors.darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteAllNotifications();
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Hapus Semua'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Tambahkan method _deleteAllNotifications
  Future<void> _deleteAllNotifications() async {
    try {
      // Show loading
      if (!mounted) return;

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Menghapus semua notifikasi...',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      );

      // Delete from Firebase
      bool success = await NotificationService.deleteAllNotifications();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      if (success) {
        // Clear local lists
        setState(() {
          _allNotifications.clear();
          _filteredNotifications.clear();
        });

        // Reload stats
        await _loadStats();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Semua notifikasi berhasil dihapus'),
              ],
            ),
            backgroundColor: AdminColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Gagal menghapus notifikasi'),
              ],
            ),
            backgroundColor: AdminColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AdminColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredNotifications =
          _allNotifications.where((notification) {
            // Type filter
            final matchesType =
                _selectedType == 'all' ||
                notification.type.name == _selectedType;

            // Target filter
            final matchesTarget =
                _selectedTarget == 'all' ||
                notification.targetRole.name == _selectedTarget;

            // Search filter
            final matchesSearch =
                _searchQuery.isEmpty ||
                notification.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                notification.message.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                notification.senderName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );

            // Date filter
            bool matchesDate = true;
            if (_selectedDateRange != null) {
              matchesDate =
                  notification.createdAt.isAfter(_selectedDateRange!.start) &&
                  notification.createdAt.isBefore(
                    _selectedDateRange!.end.add(const Duration(days: 1)),
                  );
            }

            return matchesType && matchesTarget && matchesSearch && matchesDate;
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
      appBar: AppBar(
        title: Text(
          'Riwayat Notifikasi',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        actions: [
       
          if (_filteredNotifications.isNotEmpty)
            IconButton(
              onPressed: _confirmDeleteAll,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua',
            ),
          IconButton(
            onPressed: () {
              _loadNotifications();
              _loadStats();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: AdminColors.background,
      body:
          _isLoading
              ? const AdminLoadingWidget(
                message: 'Memuat riwayat notifikasi...',
              )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Notifications',
        message: _error!,
        onRetry: _loadNotifications,
      );
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [_buildStatsSection(), _buildFilterSection()],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
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
                  Tab(text: 'Semua (${_filteredNotifications.length})'),
                  Tab(text: 'Hari Ini (${_getTodayCount()})'),
                  Tab(text: 'Minggu Ini (${_getWeekCount()})'),
                  Tab(text: 'Bulan Ini (${_getMonthCount()})'),
                ],
              ),
            ),
          ),
        ];
      },
      body:
          _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationList(_filteredNotifications),
                  _buildNotificationList(
                    _getNotificationsForTimeRange(TimeRange.today),
                  ),
                  _buildNotificationList(
                    _getNotificationsForTimeRange(TimeRange.week),
                  ),
                  _buildNotificationList(
                    _getNotificationsForTimeRange(TimeRange.month),
                  ),
                ],
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AdminEmptyState(
        icon: Icons.notifications_off,
        title: 'Belum Ada Notifikasi',
        message:
            'Belum ada notifikasi yang dikirim atau tidak ada yang sesuai filter',
        actionText: 'Kirim Notifikasi',
        onAction: () {
          Navigator.pushNamed(context, '/admin/send_notification');
        },
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AdminSizes.paddingM),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Notifikasi',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdminColors.adminDark,
            ),
          ),
          const SizedBox(height: AdminSizes.paddingM),
          Row(
            children: [
              // By Type
              Expanded(
                child: _buildStatsCard(
                  title: 'Berdasarkan Jenis',
                  stats: _stats!.byType,
                  getColor: _getTypeColor,
                ),
              ),
              const SizedBox(width: AdminSizes.paddingM),
              // By Role
              Expanded(
                child: _buildStatsCard(
                  title: 'Berdasarkan Target',
                  stats: _stats!.byRole,
                  getColor: _getRoleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required Map<String, int> stats,
    required Color Function(String) getColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingS),
            ...stats.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: getColor(entry.key),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: AdminColors.darkGray,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.adminDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
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
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Cari notifikasi (judul, pesan, pengirim)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _applyFilters();
                        },
                        icon: const Icon(Icons.clear),
                      )
                      : null,
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

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Type filter
                Text(
                  'Jenis: ',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: AdminColors.darkGray,
                  ),
                ),
                _buildTypeChip('all', 'Semua'),
                ...NotificationType.values.map(
                  (type) => _buildTypeChip(type.name, _getTypeLabel(type)),
                ),

                const SizedBox(width: AdminSizes.paddingL),

                // Target filter
                Text(
                  'Target: ',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: AdminColors.darkGray,
                  ),
                ),
                _buildTargetChip('all', 'Semua'),
                _buildTargetChip('broadcast', 'Broadcast'),
                ...UserRole.values
                    .where((role) => role != UserRole.admin)
                    .map(
                      (role) => _buildTargetChip(role.name, role.displayName),
                    ),

                const SizedBox(width: AdminSizes.paddingL),

                // Date filter
                OutlinedButton.icon(
                  onPressed: _showDateRangePicker,
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _selectedDateRange == null
                        ? 'Pilih Tanggal'
                        : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                    style: GoogleFonts.roboto(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.primaryBlue,
                    side: BorderSide(color: AdminColors.borderColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),

                if (_selectedDateRange != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    style: IconButton.styleFrom(
                      foregroundColor: AdminColors.darkGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String typeId, String title) {
    final isSelected = _selectedType == typeId;
    return Padding(
      padding: const EdgeInsets.only(right: AdminSizes.paddingS),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = typeId;
          });
          _applyFilters();
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

  Widget _buildTargetChip(String targetId, String title) {
    final isSelected = _selectedTarget == targetId;
    return Padding(
      padding: const EdgeInsets.only(right: AdminSizes.paddingS),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedTarget = targetId;
          });
          _applyFilters();
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

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadNotifications();
        await _loadStats();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AdminSizes.paddingM),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        onTap: () => _showNotificationDetail(notification),
        child: Padding(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(
                        notification.type.name,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                    ),
                    child: Icon(
                      _getTypeIcon(notification.type),
                      color: _getTypeColor(notification.type.name),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AdminSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.adminDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AdminStatusChip(
                              text: _getTypeLabel(notification.type),
                              color: _getTypeColor(notification.type.name),
                            ),
                            const SizedBox(width: AdminSizes.paddingS),
                            AdminStatusChip(
                              text: notification.targetRole.displayName,
                              color: _getRoleColor(
                                notification.targetRole.name,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AdminColors.darkGray,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AdminSizes.paddingM),

              // Message
              Text(
                notification.message,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AdminColors.darkGray,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AdminSizes.paddingM),

              // Footer
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AdminColors.lightGray),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Dikirim oleh: ${notification.senderName}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AdminColors.lightGray,
                      ),
                    ),
                  ),
                  // Tombol Delete
                  IconButton(
                    onPressed: () => _confirmDelete(notification),
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    color: AdminColors.error,
                    tooltip: 'Hapus',
                  ),
                  IconButton(
                    onPressed: () => _showNotificationDetail(notification),
                    icon: const Icon(Icons.more_vert),
                    iconSize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  int _getTodayCount() => _getNotificationsForTimeRange(TimeRange.today).length;
  int _getWeekCount() => _getNotificationsForTimeRange(TimeRange.week).length;
  int _getMonthCount() => _getNotificationsForTimeRange(TimeRange.month).length;

  List<NotificationModel> _getNotificationsForTimeRange(TimeRange range) {
    final now = DateTime.now();
    DateTime startDate;

    switch (range) {
      case TimeRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeRange.week:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimeRange.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    return _filteredNotifications.where((notification) {
      return notification.createdAt.isAfter(startDate);
    }).toList();
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AdminColors.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    showDialog(
      context: context,
      builder:
          (context) => NotificationDetailDialog(
            notification: notification,
            onDelete: _confirmDelete,
          ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Export Riwayat Notifikasi',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Fitur export akan segera tersedia. Anda akan dapat mengekspor riwayat notifikasi dalam format CSV atau PDF.',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.roboto(color: AdminColors.primaryBlue),
                ),
              ),
            ],
          ),
    );
  }

  // Konfirmasi Delete
  void _confirmDelete(NotificationModel notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AdminColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Hapus Notifikasi?',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Notifikasi "${notification.title}" akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
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
                  Navigator.pop(context);
                  await _deleteNotification(notification);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  // Delete Notification
  // Delete Notification - PERBAIKAN
  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Menghapus notifikasi...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Determine if broadcast or role-specific
      bool isBroadcast = notification.isBroadcast;

      // Delete from Firebase
      bool success = await NotificationService.deleteNotification(
        notification.id,
        isBroadcast,
      );

      if (!mounted) return;

      if (success) {
        // TAMBAHAN: Hapus dari list lokal untuk update UI langsung
        setState(() {
          _allNotifications.removeWhere((n) => n.id == notification.id);
          _filteredNotifications.removeWhere((n) => n.id == notification.id);
        });

        // Reload stats after delete
        await _loadStats();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Notifikasi berhasil dihapus'),
              ],
            ),
            backgroundColor: AdminColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Gagal menghapus notifikasi'),
              ],
            ),
            backgroundColor: AdminColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AdminColors.error,
        ),
      );
    }
  }

  // Utility methods
  Color _getTypeColor(String type) {
    switch (type) {
      case 'general':
        return AdminColors.primaryBlue;
      case 'urgent':
        return AdminColors.error;
      case 'announcement':
        return AdminColors.adminPurple;
      case 'reminder':
        return AdminColors.warning;
      case 'event':
        return AdminColors.success;
      default:
        return AdminColors.darkGray;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'makoKor':
        return AdminColors.primaryBlue;
      case 'pasPelopor':
        return AdminColors.error;
      case 'pasGegana':
        return AdminColors.success;
      case 'pasbrimobI':
        return AdminColors.warning;
      case 'pasbrimobII':
        return AdminColors.adminPurple;
      case 'pasbrimobIII':
        return AdminColors.info;
      default:
        return AdminColors.darkGray;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.urgent:
        return Icons.priority_high;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.event:
        return Icons.event;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'Umum';
      case NotificationType.urgent:
        return 'Urgent';
      case NotificationType.announcement:
        return 'Pengumuman';
      case NotificationType.reminder:
        return 'Pengingat';
      case NotificationType.event:
        return 'Event';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum TimeRange { today, week, month }

// Sticky TabBar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

// Notification Detail Dialog
class NotificationDetailDialog extends StatelessWidget {
  final NotificationModel notification;
  final Function(NotificationModel)? onDelete;

  const NotificationDetailDialog({
    super.key,
    required this.notification,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      notification.type.name,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type.name),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: Text(
                    'Detail Notifikasi',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.adminDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: AdminSizes.paddingL),

            // Content
            _buildDetailRow('Judul', notification.title),
            _buildDetailRow('Pesan', notification.message),
            _buildDetailRow('Jenis', _getTypeLabel(notification.type)),
            _buildDetailRow('Target', notification.targetRole.displayName),
            _buildDetailRow('Pengirim', notification.senderName),
            _buildDetailRow(
              'Tanggal Kirim',
              _formatDetailDate(notification.createdAt),
            ),
            _buildDetailRow(
              'Status',
              notification.isRead ? 'Sudah Dibaca' : 'Belum Dibaca',
            ),

            const SizedBox(height: AdminSizes.paddingL),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onDelete != null) {
                        onDelete!(notification);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.error,
                      side: BorderSide(color: AdminColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminSizes.paddingS),
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
          const Text(' : '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(color: AdminColors.adminDark),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTypeColor(String type) {
    switch (type) {
      case 'general':
        return AdminColors.primaryBlue;
      case 'urgent':
        return AdminColors.error;
      case 'announcement':
        return AdminColors.adminPurple;
      case 'reminder':
        return AdminColors.warning;
      case 'event':
        return AdminColors.success;
      default:
        return AdminColors.darkGray;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.urgent:
        return Icons.priority_high;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.event:
        return Icons.event;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'Umum';
      case NotificationType.urgent:
        return 'Urgent';
      case NotificationType.announcement:
        return 'Pengumuman';
      case NotificationType.reminder:
        return 'Pengingat';
      case NotificationType.event:
        return 'Event';
    }
  }

  String _formatDetailDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
