import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/services/admin_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';
import '../../constants/app_constants.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _rankController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isAdmin = false; // Toggle for admin/regular user
  
  UserRole _selectedRole = UserRole.makoKor;
  DateTime? _dateOfBirth;
  DateTime? _militaryJoinDate;
  File? _selectedImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nrpController.dispose();
    _rankController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation for non-admin users
    if (!_isAdmin) {
      if (_dateOfBirth == null) {
        _showError('Pilih tanggal lahir terlebih dahulu');
        return;
      }
      if (_militaryJoinDate == null) {
        _showError('Pilih tanggal masuk militer terlebih dahulu');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl;
      
      // Upload photo if selected
      if (_selectedImage != null) {
        photoUrl = await AdminFirebaseService.uploadSlideshowImage(_selectedImage!);
      }

      Map<String, dynamic> result;

      if (_isAdmin) {
        // Create admin user with minimal fields
        result = await AdminFirebaseService.createAdminUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          photoUrl: photoUrl,
        );
      } else {
        // Create regular user with complete fields
        result = await AdminFirebaseService.createUserWithSeparateAuth(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          nrp: _nrpController.text.trim(),
          rank: _rankController.text.trim(),
          role: _selectedRole,
          dateOfBirth: _dateOfBirth!,
          militaryJoinDate: _militaryJoinDate!,
          photoUrl: photoUrl,
        );
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success']) {
          _showSuccessDialog(result['message']);
        } else {
          _showError(result['message']);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: AdminSizes.paddingM),
            Text(
              'Berhasil!',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to user management
            },
            child: Text(
              'Tutup',
              style: GoogleFonts.roboto(color: AdminColors.darkGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetForm(); // Reset form for new user
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminSizes.radiusS),
              ),
            ),
            child: Text(
              'Tambah Lagi',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _nrpController.clear();
      _rankController.clear();
      _selectedRole = UserRole.makoKor;
      _dateOfBirth = null;
      _militaryJoinDate = null;
      _selectedImage = null;
      _isAdmin = false;
    });
  }

  Future<void> _selectProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AdminColors.darkGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AdminSizes.paddingM),
            Text(
              'Pilih Foto Profil',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingL),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: _buildPhotoOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: AdminSizes.paddingM),
              SizedBox(
                width: double.infinity,
                child: _buildPhotoOption(
                  icon: Icons.delete,
                  label: 'Hapus Foto',
                  onTap: _removePhoto,
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: AdminSizes.paddingL),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        decoration: BoxDecoration(
          border: Border.all(color: AdminColors.borderColor),
          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color ?? AdminColors.primaryBlue),
            const SizedBox(height: AdminSizes.paddingS),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? AdminColors.adminDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memilih foto: ${e.toString()}');
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime firstDate = DateTime(1960);
    final DateTime lastDate = DateTime.now().subtract(const Duration(days: 365 * 17));
    DateTime initialDate;
    
    if (_dateOfBirth != null) {
      initialDate = _dateOfBirth!;
    } else {
      initialDate = DateTime(1990, 1, 1);
      if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Pilih Tanggal Lahir',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AdminColors.adminDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _selectMilitaryJoinDate() async {
    final DateTime firstDate = DateTime(1980);
    final DateTime lastDate = DateTime.now();
    DateTime initialDate;
    
    if (_militaryJoinDate != null) {
      initialDate = _militaryJoinDate!;
    } else {
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 5));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Pilih Tanggal Masuk Militer',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AdminColors.adminDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _militaryJoinDate) {
      setState(() {
        _militaryJoinDate = picked;
      });
    }
  }

  Widget _buildDatePicker({
    required String labelText,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AdminSizes.paddingM,
          vertical: AdminSizes.paddingM + 2,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AdminColors.borderColor),
          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AdminColors.primaryBlue, size: 20),
            const SizedBox(width: AdminSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AdminColors.darkGray,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : 'Pilih tanggal',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: selectedDate != null
                          ? AdminColors.adminDark
                          : AdminColors.darkGray.withOpacity(0.6),
                      fontWeight: selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AdminColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AdminColors.adminGradient),
              ),
              child: Stack(
                children: [
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
                                'Tambah User Baru',
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Buat akun ${_isAdmin ? 'admin' : 'pengguna'} baru untuk aplikasi',
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
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AdminSizes.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Type Toggle
                      Container(
                        padding: const EdgeInsets.all(AdminSizes.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isAdmin ? Icons.admin_panel_settings : Icons.person,
                              color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                            ),
                            const SizedBox(width: AdminSizes.paddingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tipe Akun',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: AdminColors.darkGray,
                                    ),
                                  ),
                                  Text(
                                    _isAdmin ? 'Administrator' : 'Pengguna Biasa',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AdminColors.adminDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isAdmin,
                              onChanged: (value) {
                                setState(() {
                                  _isAdmin = value;
                                  if (_isAdmin) {
                                    _selectedRole = UserRole.admin;
                                  } else {
                                    _selectedRole = UserRole.makoKor;
                                  }
                                });
                              },
                              activeColor: AppColors.purple,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AdminSizes.paddingL),

                      // Profile Photo Section
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _selectProfilePhoto,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isAdmin ? AppColors.purple : AdminColors.primaryBlue).withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _selectedImage != null
                                          ? Image.file(
                                              _selectedImage!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 120,
                                              height: 120,
                                              color: AdminColors.background,
                                              child: Icon(
                                                _isAdmin ? Icons.admin_panel_settings : Icons.person,
                                                size: 60,
                                                color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AdminSizes.paddingS),
                            Text(
                              'Foto Profil',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AdminColors.adminDark,
                              ),
                            ),
                            Text(
                              'Tap untuk ${_selectedImage != null ? 'mengubah' : 'menambah'} foto',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: AdminColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AdminSizes.paddingL),

                      // Basic Information
                      Text(
                        'Informasi Dasar',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.adminDark,
                        ),
                      ),
                      const SizedBox(height: AdminSizes.paddingM),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Nama tidak boleh kosong';
                          if (value!.length < 3) return 'Nama minimal 3 karakter';
                          return null;
                        },
                      ),

                      const SizedBox(height: AdminSizes.paddingM),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AdminSizes.paddingM),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Password tidak boleh kosong';
                          if (value!.length < 6) return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),

                      // Additional fields for non-admin users
                      if (!_isAdmin) ...[
                        const SizedBox(height: AdminSizes.paddingL),

                        Text(
                          'Data Militer',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.adminDark,
                          ),
                        ),
                        const SizedBox(height: AdminSizes.paddingM),

                        TextFormField(
                          controller: _nrpController,
                          decoration: InputDecoration(
                            labelText: 'NRP (Nomor Registrasi Pokok)',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'NRP tidak boleh kosong';
                            if (value!.length < 8) return 'NRP minimal 8 digit';
                            return null;
                          },
                        ),

                        const SizedBox(height: AdminSizes.paddingM),

                        DropdownButtonFormField<String>(
                          value: _rankController.text.isEmpty ? null : _rankController.text,
                          decoration: InputDecoration(
                            labelText: 'Pangkat',
                            prefixIcon: const Icon(Icons.military_tech_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: MenuData.militaryRanks.map((rank) => DropdownMenuItem(
                            value: rank,
                            child: Text(rank),
                          )).toList(),
                          onChanged: (value) => setState(() => _rankController.text = value ?? ''),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Pilih pangkat';
                            return null;
                          },
                        ),

                        const SizedBox(height: AdminSizes.paddingM),

                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Satuan',
                            prefixIcon: const Icon(Icons.group_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: UserRole.values.where((role) => role != UserRole.admin).map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.displayName),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedRole = value!),
                          validator: (value) {
                            if (value == null) return 'Pilih satuan';
                            return null;
                          },
                        ),

                        const SizedBox(height: AdminSizes.paddingM),

                        _buildDatePicker(
                          labelText: 'Tanggal Lahir',
                          selectedDate: _dateOfBirth,
                          onTap: _selectDateOfBirth,
                        ),

                        const SizedBox(height: AdminSizes.paddingM),

                        _buildDatePicker(
                          labelText: 'Tanggal Masuk Militer',
                          selectedDate: _militaryJoinDate,
                          onTap: _selectMilitaryJoinDate,
                        ),
                      ],

                      const SizedBox(height: AdminSizes.paddingXL),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                            ),
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
                                  _isLoading ? 'Membuat...' : 'BUAT ${_isAdmin ? 'ADMIN' : 'USER'}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: AdminSizes.paddingM),

                      // Info Container
                      Container(
                        padding: const EdgeInsets.all(AdminSizes.paddingM),
                        decoration: BoxDecoration(
                          color: (_isAdmin ? AppColors.purple : AdminColors.primaryBlue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: AdminSizes.paddingS),
                            Expanded(
                              child: Text(
                                _isAdmin 
                                    ? 'Admin akan langsung aktif dan memiliki akses penuh ke sistem.'
                                    : 'User akan langsung disetujui dan dapat menggunakan aplikasi.',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}