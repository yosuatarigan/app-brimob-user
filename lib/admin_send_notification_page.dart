import 'package:app_brimob_user/notification_model.dart';
import 'package:app_brimob_user/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../libadmin/admin_constant.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class AdminSendNotificationPage extends StatefulWidget {
  const AdminSendNotificationPage({super.key});

  @override
  State<AdminSendNotificationPage> createState() => _AdminSendNotificationPageState();
}

class _AdminSendNotificationPageState extends State<AdminSendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;
  UserRole? _selectedRole;
  NotificationType _selectedType = NotificationType.general;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      _showSnackBar('Pilih target satuan terlebih dahulu', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        // Upload image logic here - would integrate with your existing upload service
        // imageUrl = await _uploadImage(_selectedImage!);
      }

      final bool success = await NotificationService.sendNotificationToRole(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        targetRole: _selectedRole!,
        imageUrl: imageUrl,
        type: _selectedType,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSnackBar('Notifikasi berhasil dikirim!', AdminColors.adminGreen);
        _resetForm();
      } else if (mounted) {
        _showSnackBar('Gagal mengirim notifikasi', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', Colors.red);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _selectedRole = null;
      _selectedType = NotificationType.general;
      _selectedImage = null;
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

  Future<void> _selectImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return AdminColors.primaryBlue;
      case NotificationType.urgent:
        return AdminColors.error;
      case NotificationType.announcement:
        return AdminColors.adminPurple;
      case NotificationType.reminder:
        return AdminColors.info;
      case NotificationType.event:
        return AdminColors.adminGreen;
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
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          'Kirim Notifikasi',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/admin-notification-history'),
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Notifikasi',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildFormCard(),
                const SizedBox(height: 16),
                _buildPreviewCard(),
                const SizedBox(height: 24),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AdminColors.primaryBlue, AdminColors.adminDark],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Broadcast Notifikasi',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Kirim pesan ke satuan tertentu',
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
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Notifikasi',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title field
            CustomTextField(
              controller: _titleController,
              labelText: 'Judul Notifikasi',
              prefixIcon: Icons.title,
              // maxLength: 100,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Judul tidak boleh kosong';
                if (value!.length < 5) return 'Judul minimal 5 karakter';
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Message field
            CustomTextField(
              controller: _messageController,
              labelText: 'Pesan',
              prefixIcon: Icons.message,
              maxLines: 4,
              // maxLength: 500,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Pesan tidak boleh kosong';
                if (value!.length < 10) return 'Pesan minimal 10 karakter';
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Target role dropdown
            CustomDropdown<UserRole>(
              value: _selectedRole,
              labelText: 'Target Satuan',
              prefixIcon: Icons.group,
              items: UserRole.values.where((role) => role != UserRole.admin).map((role) => 
                DropdownMenuItem(
                  value: role,
                  child: Text(role.displayName),
                )
              ).toList(),
              onChanged: (value) => setState(() => _selectedRole = value),
              validator: (value) {
                if (value == null) return 'Pilih target satuan';
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Notification type selection
            Text(
              'Jenis Notifikasi',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.adminDark,
              ),
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
            
            // Image attachment
            _buildImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lampiran Gambar (Opsional)',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.adminDark,
              ),
            ),
            TextButton.icon(
              onPressed: _selectImage,
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text('Pilih Gambar'),
              style: TextButton.styleFrom(
                foregroundColor: AdminColors.primaryBlue,
              ),
            ),
          ],
        ),
        
        if (_selectedImage != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.lightGray),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard() {
    if (_titleController.text.isEmpty && _messageController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: AdminColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preview Notifikasi',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.adminDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildNotificationPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getTypeColor(_selectedType).withOpacity(0.3)),
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
                  _titleController.text.isNotEmpty ? _titleController.text : 'Judul Notifikasi',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.adminDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          if (_messageController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _messageController.text,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AdminColors.darkGray,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.group,
                size: 14,
                color: AdminColors.darkGray,
              ),
              const SizedBox(width: 4),
              Text(
                _selectedRole?.displayName ?? 'Target Satuan',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AdminColors.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Sekarang',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: AdminColors.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _sendNotification,
      text: _isLoading ? 'Mengirim...' : 'KIRIM NOTIFIKASI',
      isLoading: _isLoading,
      icon: Icons.send,
    );
  }
}