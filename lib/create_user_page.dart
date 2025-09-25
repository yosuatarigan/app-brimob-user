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
  final PageController _pageController = PageController();
  
  // Basic controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _rankController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _sukuController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isAdmin = false;
  int _currentStep = 0;
  
  // Dropdowns
  UserRole _selectedRole = UserRole.makoKor;
  String? _selectedAgama;
  String? _selectedBloodType;
  String? _selectedMaritalStatus;
  String? _selectedStatusPersonel;
  
  // Dates
  DateTime? _dateOfBirth;
  DateTime? _militaryJoinDate;
  DateTime? _jabatanTmt;
  
  File? _selectedImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nrpController.dispose();
    _rankController.dispose();
    _jabatanController.dispose();
    _tempatLahirController.dispose();
    _sukuController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _pageController.dispose();
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
        photoUrl = await AdminFirebaseService.uploadUserPhoto(_selectedImage!);
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
          // Additional fields
          jabatan: _jabatanController.text.trim().isEmpty ? null : _jabatanController.text.trim(),
          jabatanTmt: _jabatanTmt,
          tempatLahir: _tempatLahirController.text.trim().isEmpty ? null : _tempatLahirController.text.trim(),
          agama: _selectedAgama,
          suku: _sukuController.text.trim().isEmpty ? null : _sukuController.text.trim(),
          statusPersonel: _selectedStatusPersonel,
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
          bloodType: _selectedBloodType,
          maritalStatus: _selectedMaritalStatus,
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
      _jabatanController.clear();
      _tempatLahirController.clear();
      _sukuController.clear();
      _phoneController.clear();
      _addressController.clear();
      _emergencyContactController.clear();
      _selectedRole = UserRole.makoKor;
      _selectedAgama = null;
      _selectedBloodType = null;
      _selectedMaritalStatus = null;
      _selectedStatusPersonel = null;
      _dateOfBirth = null;
      _militaryJoinDate = null;
      _jabatanTmt = null;
      _selectedImage = null;
      _isAdmin = false;
      _currentStep = 0;
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

  Future<void> _selectDate({required String type}) async {
    final DateTime firstDate = DateTime(1960);
    final DateTime lastDate = DateTime.now();
    DateTime initialDate;
    
    switch(type) {
      case 'dateOfBirth':
        initialDate = _dateOfBirth ?? DateTime(1990, 1, 1);
        if (initialDate.isAfter(lastDate)) {
          initialDate = lastDate.subtract(const Duration(days: 365 * 17));
        }
        break;
      case 'militaryJoinDate':
        initialDate = _militaryJoinDate ?? DateTime.now().subtract(const Duration(days: 365 * 5));
        break;
      case 'jabatanTmt':
        initialDate = _jabatanTmt ?? DateTime.now();
        break;
      default:
        initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: _getDatePickerTitle(type),
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

    if (picked != null) {
      setState(() {
        switch(type) {
          case 'dateOfBirth':
            _dateOfBirth = picked;
            break;
          case 'militaryJoinDate':
            _militaryJoinDate = picked;
            break;
          case 'jabatanTmt':
            _jabatanTmt = picked;
            break;
        }
      });
    }
  }

  String _getDatePickerTitle(String type) {
    switch(type) {
      case 'dateOfBirth':
        return 'Pilih Tanggal Lahir';
      case 'militaryJoinDate':
        return 'Pilih Tanggal Masuk Militer';
      case 'jabatanTmt':
        return 'Pilih TMT Jabatan';
      default:
        return 'Pilih Tanggal';
    }
  }

  Widget _buildDatePicker({
    required String labelText,
    required DateTime? selectedDate,
    required String type,
  }) {
    return InkWell(
      onTap: () => _selectDate(type: type),
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

  Widget _buildStep1() {
    return Column(
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
                      _isAdmin ? 'Administrator' : 'Personel Brimob',
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
                      width: 100,
                      height: 100,
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
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: AdminColors.background,
                                child: Icon(
                                  _isAdmin ? Icons.admin_panel_settings : Icons.person,
                                  size: 50,
                                  color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AdminSizes.paddingS),
              Text(
                'Foto Profil (Opsional)',
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
            labelText: 'Nama Lengkap *',
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
            labelText: 'Email *',
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
            labelText: 'Password *',
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
      ],
    );
  }

  Widget _buildStep2() {
    if (_isAdmin) {
      return Container(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        ),
        child: Column(
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: AppColors.purple,
            ),
            const SizedBox(height: AdminSizes.paddingM),
            Text(
              'Akun Administrator',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingS),
            Text(
              'Admin akan langsung aktif dengan akses penuh ke sistem.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AdminColors.darkGray,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Kepangkatan & Jabatan',
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
            labelText: 'NRP (Nomor Registrasi Pokok) *',
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
            return null;
          },
        ),

        const SizedBox(height: AdminSizes.paddingM),

        DropdownButtonFormField<String>(
          value: _rankController.text.isEmpty ? null : _rankController.text,
          decoration: InputDecoration(
            labelText: 'Pangkat *',
            prefixIcon: const Icon(Icons.military_tech_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: MilitaryRank.ranks.map((rank) => DropdownMenuItem(
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

        TextFormField(
          controller: _jabatanController,
          decoration: InputDecoration(
            labelText: 'Jabatan',
            prefixIcon: const Icon(Icons.work_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        _buildDatePicker(
          labelText: 'TMT Jabatan',
          selectedDate: _jabatanTmt,
          type: 'jabatanTmt',
        ),

        const SizedBox(height: AdminSizes.paddingM),

        DropdownButtonFormField<UserRole>(
          value: _selectedRole,
          decoration: InputDecoration(
            labelText: 'Satuan *',
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

        DropdownButtonFormField<String>(
          value: _selectedStatusPersonel,
          decoration: InputDecoration(
            labelText: 'Status Personel',
            prefixIcon: const Icon(Icons.person_pin_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: MilitaryRank.statusPersonel.map((status) => DropdownMenuItem(
            value: status,
            child: Text(status),
          )).toList(),
          onChanged: (value) => setState(() => _selectedStatusPersonel = value),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        _buildDatePicker(
          labelText: 'Tanggal Masuk Militer *',
          selectedDate: _militaryJoinDate,
          type: 'militaryJoinDate',
        ),
      ],
    );
  }

  Widget _buildStep3() {
    if (_isAdmin) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Personal',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminDark,
          ),
        ),
        const SizedBox(height: AdminSizes.paddingM),

        TextFormField(
          controller: _tempatLahirController,
          decoration: InputDecoration(
            labelText: 'Tempat Lahir',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        _buildDatePicker(
          labelText: 'Tanggal Lahir *',
          selectedDate: _dateOfBirth,
          type: 'dateOfBirth',
        ),

        const SizedBox(height: AdminSizes.paddingM),

        DropdownButtonFormField<String>(
          value: _selectedAgama,
          decoration: InputDecoration(
            labelText: 'Agama',
            prefixIcon: const Icon(Icons.mosque_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: MilitaryRank.religions.map((religion) => DropdownMenuItem(
            value: religion,
            child: Text(religion),
          )).toList(),
          onChanged: (value) => setState(() => _selectedAgama = value),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        TextFormField(
          controller: _sukuController,
          decoration: InputDecoration(
            labelText: 'Suku',
            prefixIcon: const Icon(Icons.people_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        DropdownButtonFormField<String>(
          value: _selectedBloodType,
          decoration: InputDecoration(
            labelText: 'Golongan Darah',
            prefixIcon: const Icon(Icons.bloodtype_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: MilitaryRank.bloodTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: (value) => setState(() => _selectedBloodType = value),
        ),

        const SizedBox(height: AdminSizes.paddingM),

        DropdownButtonFormField<String>(
          value: _selectedMaritalStatus,
          decoration: InputDecoration(
            labelText: 'Status Pernikahan',
            prefixIcon: const Icon(Icons.family_restroom_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: MilitaryRank.maritalStatuses.map((status) => DropdownMenuItem(
            value: status,
            child: Text(status),
          )).toList(),
          onChanged: (value) => setState(() => _selectedMaritalStatus = value),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    if (_isAdmin) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Kontak',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminDark,
          ),
        ),
        const SizedBox(height: AdminSizes.paddingM),

        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Nomor Telepon',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: AdminSizes.paddingM),

        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Alamat Lengkap',
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
        ),

        const SizedBox(height: AdminSizes.paddingM),

        TextFormField(
          controller: _emergencyContactController,
          decoration: InputDecoration(
            labelText: 'Kontak Darurat',
            prefixIcon: const Icon(Icons.contact_emergency_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: AdminSizes.paddingL),

        Container(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          decoration: BoxDecoration(
            color: AdminColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AdminColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: AdminSizes.paddingS),
              Expanded(
                child: Text(
                  'Personel dapat melengkapi data riwayat pendidikan, jabatan, dan informasi lainnya setelah akun dibuat.',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AdminColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = _isAdmin ? 2 : 4;
    
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
                                'Tambah ${_isAdmin ? 'Admin' : 'Personel'} Baru',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Buat akun ${_isAdmin ? 'administrator' : 'personel'} baru untuk aplikasi',
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

            // Step indicator
            if (!_isAdmin || _currentStep > 0) ...[
              Container(
                margin: const EdgeInsets.all(AdminSizes.paddingM),
                child: Row(
                  children: List.generate(totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                          right: index < totalSteps - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
                              ? (_isAdmin ? AppColors.purple : AdminColors.primaryBlue)
                              : AdminColors.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              Text(
                'Langkah ${_currentStep + 1} dari $totalSteps',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AdminColors.darkGray,
                ),
              ),
            ],

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AdminSizes.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Step content
                      if (_currentStep == 0) _buildStep1(),
                      if (_currentStep == 1) _buildStep2(),
                      if (_currentStep == 2) _buildStep3(),
                      if (_currentStep == 3) _buildStep4(),

                      const SizedBox(height: AdminSizes.paddingXL),

                      // Navigation buttons
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _currentStep--),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                                  ),
                                ),
                                child: Text(
                                  'SEBELUMNYA',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          
                          if (_currentStep > 0) const SizedBox(width: AdminSizes.paddingM),
                          
                          Expanded(
                            child: _currentStep < totalSteps - 1
                                ? ElevatedButton(
                                    onPressed: () {
                                      if (_currentStep == 0) {
                                        if (!_formKey.currentState!.validate()) return;
                                      }
                                      setState(() => _currentStep++);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                                      ),
                                    ),
                                    child: Text(
                                      'SELANJUTNYA',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _isLoading ? null : _createUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isAdmin ? AppColors.purple : AdminColors.primaryBlue,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                                            'BUAT ${_isAdmin ? 'ADMIN' : 'PERSONEL'}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                          ),
                        ],
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