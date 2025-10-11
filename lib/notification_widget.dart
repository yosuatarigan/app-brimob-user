// lib/widgets/notification_widget.dart
import 'package:app_brimob_user/admin_send_notification_page.dart';
import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/notification_model.dart';
import 'package:app_brimob_user/notification_service.dart';
import 'package:app_brimob_user/percobaannotif/user_notifikasi_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class NotificationWidget extends StatelessWidget {
  final UserRole? userRole;

  const NotificationWidget({super.key, this.userRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PLB BRIMOB',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserNotificationPage(userRole: userRole),
                    ),
                  );
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userRole != null 
                ? 'Menampilkan untuk: ${userRole!.displayName}'
                : 'Pilih satuan BRIMOB untuk melihat notifikasi',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class RecentNotificationsWidget extends StatefulWidget {
  final int limit;
  final UserRole? userRole;

  const RecentNotificationsWidget({
    super.key,
    this.limit = 3,
    this.userRole,
  });

  @override
  State<RecentNotificationsWidget> createState() => _RecentNotificationsWidgetState();
}

class _RecentNotificationsWidgetState extends State<RecentNotificationsWidget> {
  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.urgent:
        return Colors.red;
      case NotificationType.announcement:
        return Colors.purple;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.event:
        return Colors.green;
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.person_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih Satuan BRIMOB',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Pilih satuan di menu utama untuk melihat notifikasi yang sesuai',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService.getAllUserNotifications(widget.userRole!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading notifications',
                    style: GoogleFonts.roboto(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        final notifications = (snapshot.data ?? []).take(widget.limit).toList();

        if (notifications.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum Ada Notifikasi',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Notifikasi untuk ${widget.userRole!.displayName} akan muncul di sini',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: notifications.map((notification) {
            final isBroadcast = true; // Using admin as broadcast indicator
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTypeColor(notification.type).withOpacity(0.1),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 20,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: GoogleFonts.roboto(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isBroadcast 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isBroadcast ? 'Broadcast' : notification.targetRole.displayName,
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              color: isBroadcast ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                dense: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserNotificationPage(userRole: widget.userRole),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Quick Access Widget untuk tombol cepat ke admin panel
class NotificationQuickAccessWidget extends StatelessWidget {
  const NotificationQuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.blue.shade50,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSendNotificationPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.roboto(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              color: Colors.green.shade50,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserNotificationPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Semua Notifikasi',
                        style: GoogleFonts.roboto(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}