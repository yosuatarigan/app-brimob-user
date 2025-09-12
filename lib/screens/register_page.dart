import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _rankController = TextEditingController();
  
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  UserRole? _selectedRole;
  DateTime? _dateOfBirth;
  DateTime? _militaryJoinDate;
  File? _selectedImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _nrpController.dispose();
    _rankController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih satuan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal lahir terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_militaryJoinDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal masuk militer terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? photoUrl;

    try {
      // Upload photo to Firebase Storage if selected
      if (_selectedImage != null) {
        photoUrl = await _uploadProfilePhoto(_selectedImage!);
      }

      final result = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        nrp: _nrpController.text.trim(),
        rank: _rankController.text.trim(),
        role: _selectedRole!,
        dateOfBirth: _dateOfBirth!,
        militaryJoinDate: _militaryJoinDate!,
        photoUrl: photoUrl,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadProfilePhoto(File imageFile) async {
    try {
      // Use AuthService to upload photo
      final photoUrl = await _authService.uploadProfilePhoto(
        imageFile, 
        'temp_${DateTime.now().millisecondsSinceEpoch}' // Temporary ID for upload
      );
      return photoUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      throw Exception('Gagal mengupload foto profil');
    }
  }

  Future<void> _selectProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Pilih Foto Profil',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
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
              const SizedBox(height: AppSizes.paddingM),
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
            const SizedBox(height: AppSizes.paddingL),
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
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? AppColors.primaryBlue,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.darkNavy,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
    required String? Function(DateTime?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: AppColors.darkGray.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelText,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppColors.darkGray,
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
                              ? AppColors.darkNavy
                              : AppColors.darkGray.withOpacity(0.6),
                          fontWeight: selectedDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'PENDAFTARAN',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.paddingXL),
                  
                  // Register Form Card
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        Text(
                          'Data Pribadi',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingL),
                        
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
                                          color: AppColors.primaryBlue,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryBlue.withOpacity(0.2),
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
                                                color: AppColors.lightGray,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: AppColors.darkGray,
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
                                          color: AppColors.primaryBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: AppColors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingS),
                              Text(
                                'Foto Profil',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              Text(
                                'Tap untuk ${_selectedImage != null ? 'mengubah' : 'menambah'} foto',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSizes.paddingL),
                        
                        CustomTextField(
                          controller: _fullNameController,
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Nama tidak boleh kosong';
                            if (value!.length < 3) return 'Nama minimal 3 karakter';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        // Custom Date Picker for Date of Birth
                        _buildDatePicker(
                          labelText: 'Tanggal Lahir',
                          selectedDate: _dateOfBirth,
                          onTap: _selectDateOfBirth,
                          validator: (value) {
                            if (value == null) return 'Pilih tanggal lahir';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingL),
                        
                        // Military Information Section
                        Text(
                          'Data Militer',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        
                        CustomTextField(
                          controller: _nrpController,
                          labelText: 'NRP (Nomor Registrasi Pokok)',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'NRP tidak boleh kosong';
                            if (value!.length < 8) return 'NRP minimal 8 digit';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        CustomDropdown<String>(
                          value: _rankController.text.isEmpty ? null : _rankController.text,
                          labelText: 'Pangkat',
                          prefixIcon: Icons.military_tech_outlined,
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
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        CustomDropdown<UserRole>(
                          value: _selectedRole,
                          labelText: 'Satuan',
                          prefixIcon: Icons.group_outlined,
                          items: UserRole.values.map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.displayName),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedRole = value),
                          validator: (value) {
                            if (value == null) return 'Pilih satuan';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        // Custom Date Picker for Military Join Date
                        _buildDatePicker(
                          labelText: 'Tanggal Masuk Militer',
                          selectedDate: _militaryJoinDate,
                          onTap: _selectMilitaryJoinDate,
                          validator: (value) {
                            if (value == null) return 'Pilih tanggal masuk militer';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingL),
                        
                        // Security Section
                        Text(
                          'Keamanan Akun',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Password tidak boleh kosong';
                            if (value!.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Konfirmasi Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Konfirmasi password tidak boleh kosong';
                            if (value != _passwordController.text) return 'Password tidak sama';
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppSizes.paddingXL),
                        
                        // Register Button
                        CustomButton(
                          onPressed: _isLoading ? null : _register,
                          text: _isLoading ? 'Mendaftar...' : 'DAFTAR',
                          isLoading: _isLoading,
                        ),
                        
                        const SizedBox(height: AppSizes.paddingM),
                        
                        // Info Text
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: Text(
                                  'Akun Anda akan diverifikasi oleh admin terlebih dahulu sebelum dapat digunakan.',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}