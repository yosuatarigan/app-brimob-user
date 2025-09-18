// lib/pages/admin_send_notification_page.dart
import 'package:app_brimob_user/models/user_model.dart';
import 'package:app_brimob_user/notification_model.dart';
import 'package:app_brimob_user/notification_service.dart';
import 'package:flutter/material.dart';

class AdminSendNotificationPage extends StatefulWidget {
  const AdminSendNotificationPage({super.key});

  @override
  State<AdminSendNotificationPage> createState() => _AdminSendNotificationPageState();
}

class _AdminSendNotificationPageState extends State<AdminSendNotificationPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;
  UserRole? _selectedRole;
  bool _isBroadcast = false;
  NotificationType _selectedType = NotificationType.general;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty || 
        _messageController.text.trim().isEmpty) {
      _showSnackBar('Harap isi judul dan pesan', Colors.red);
      return;
    }

    if (!_isBroadcast && _selectedRole == null) {
      _showSnackBar('Pilih target satuan atau aktifkan broadcast', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success;
      
      if (_isBroadcast) {
        // Send to all users
        success = await NotificationService.sendBroadcastNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          type: _selectedType,
        );
      } else {
        // Send to specific role
        success = await NotificationService.sendNotificationToRole(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          targetRole: _selectedRole!,
          type: _selectedType,
        );
      }

      if (success) {
        _showSnackBar('Notifikasi berhasil dikirim!', Colors.green);
        _resetForm();
      } else {
        _showSnackBar('Gagal mengirim notifikasi', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _selectedRole = null;
      _isBroadcast = false;
      _selectedType = NotificationType.general;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationHistoryPage(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Form Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kirim Notifikasi',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            
                            // Title Input
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Judul Notifikasi',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.title),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Message Input
                            TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                labelText: 'Pesan',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.message),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            
                            // Notification Type Selection
                            const Text(
                              'Jenis Notifikasi',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            
                            Wrap(
                              spacing: 8,
                              children: NotificationType.values.map((type) {
                                final bool isSelected = _selectedType == type;
                                return FilterChip(
                                  selected: isSelected,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getTypeIcon(type),
                                        size: 16,
                                        color: isSelected ? Colors.white : _getTypeColor(type),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(_getTypeLabel(type)),
                                    ],
                                  ),
                                  selectedColor: _getTypeColor(type),
                                  checkmarkColor: Colors.white,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedType = type);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Broadcast Toggle
                            Row(
                              children: [
                                Checkbox(
                                  value: _isBroadcast,
                                  onChanged: (value) {
                                    setState(() {
                                      _isBroadcast = value ?? false;
                                      if (_isBroadcast) _selectedRole = null;
                                    });
                                  },
                                ),
                                const Expanded(
                                  child: Text('Kirim ke semua satuan (Broadcast)'),
                                ),
                              ],
                            ),
                            
                            // Role Dropdown (only show if not broadcast)
                            if (!_isBroadcast) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<UserRole>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Target Satuan',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.group),
                                ),
                                items: UserRole.values
                                    // .where((role) => role != UserRole.)
                                    .map((role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.displayName),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedRole = value);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Preview Card
                    if (_titleController.text.isNotEmpty || _messageController.text.isNotEmpty)
                      Card(
                        color: _getTypeColor(_selectedType).withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.preview,
                                    color: _getTypeColor(_selectedType),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Preview Notifikasi',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getTypeColor(_selectedType).withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _getTypeColor(_selectedType),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            _getTypeIcon(_selectedType),
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _titleController.text.isNotEmpty 
                                                ? _titleController.text 
                                                : 'Judul Notifikasi',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    if (_messageController.text.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(_messageController.text),
                                    ],
                                    
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.group, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isBroadcast 
                                              ? 'Semua Satuan'
                                              : (_selectedRole?.displayName ?? 'Target Satuan'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Text(
                                          'Sekarang',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Info Card
                    Card(
                      color: Colors.blue.withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Notifikasi akan dikirim secara real-time ke satuan yang dipilih',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Send Button (Fixed at bottom)
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTypeColor(_selectedType),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text('Mengirim...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_getTypeIcon(_selectedType)),
                          const SizedBox(width: 8),
                          const Text(
                            'KIRIM NOTIFIKASI',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// History Page
class NotificationHistoryPage extends StatelessWidget {
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService.getNotificationHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Terjadi kesalahan'),
                  Text('${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat notifikasi',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.message),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification.targetRole.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
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
}