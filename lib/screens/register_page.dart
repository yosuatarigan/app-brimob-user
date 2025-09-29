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
  final PageController _pageController = PageController();

  // Basic controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _rankController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _sukuController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Dropdowns
  UserRole? _selectedRole;
  String? _selectedAgama;
  String? _selectedBloodType;
  String? _selectedMaritalStatus;
  final String _selectedStatusPersonel = 'NON-AKTIF';

  // Dates
  DateTime? _dateOfBirth;
  DateTime? _militaryJoinDate;
  DateTime? _jabatanTmt;

  File? _selectedImage;
  int _currentStep = 0;
  final int _totalSteps = 8;

  // Complex data lists
  List<PendidikanKepolisian> _pendidikanKepolisian = [];
  List<PendidikanUmum> _pendidikanUmum = [];
  List<RiwayatPangkat> _riwayatPangkat = [];
  List<RiwayatJabatan> _riwayatJabatan = [];
  List<PendidikanPelatihan> _pendidikanPelatihan = [];
  List<TandaKehormatan> _tandaKehormatan = [];
  List<KemampuanBahasa> _kemampuanBahasa = [];
  List<PenugasanLuarStruktur> _penugasanLuarStruktur = [];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
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

  Future<void> _register() async {
    setState(() => _isLoading = true);

    String? photoUrl;

    try {
      if (_selectedImage != null) {
        photoUrl = await _uploadProfilePhoto(_selectedImage!);
      }

      final result = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        nrp: _nrpController.text.trim(),
        rank: _rankController.text.trim(),
        jabatan: _jabatanController.text.trim(),
        jabatanTmt: _jabatanTmt,
        role: _selectedRole ?? UserRole.other,
        photoUrl: photoUrl,
        tempatLahir:
            _tempatLahirController.text.trim().isEmpty
                ? null
                : _tempatLahirController.text.trim(),
        dateOfBirth: _dateOfBirth,
        agama: _selectedAgama,
        suku:
            _sukuController.text.trim().isEmpty
                ? null
                : _sukuController.text.trim(),
        statusPersonel: _selectedStatusPersonel,
        militaryJoinDate: _militaryJoinDate,
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        emergencyContact:
            _emergencyContactController.text.trim().isEmpty
                ? null
                : _emergencyContactController.text.trim(),
        bloodType: _selectedBloodType,
        maritalStatus: _selectedMaritalStatus,
        pendidikanKepolisian: _pendidikanKepolisian,
        pendidikanUmum: _pendidikanUmum,
        riwayatPangkat: _riwayatPangkat,
        riwayatJabatan: _riwayatJabatan,
        pendidikanPelatihan: _pendidikanPelatihan,
        tandaKehormatan: _tandaKehormatan,
        kemampuanBahasa: _kemampuanBahasa,
        penugasanLuarStruktur: _penugasanLuarStruktur,
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
      final photoUrl = await _authService.uploadProfilePhoto(
        imageFile,
        'temp_${DateTime.now().millisecondsSinceEpoch}',
      );
      return photoUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      throw Exception('Gagal mengupload foto profil');
    }
  }

  // Photo selection methods
  Future<void> _selectProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
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
            Icon(icon, size: 32, color: color ?? AppColors.primaryBlue),
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

  // Date picker methods
  Future<void> _selectDate({required String type}) async {
    final DateTime firstDate = DateTime(1960);
    final DateTime lastDate = DateTime.now();
    DateTime initialDate;

    switch (type) {
      case 'dateOfBirth':
        initialDate = _dateOfBirth ?? DateTime(1990, 1, 1);
        break;
      case 'militaryJoinDate':
        initialDate =
            _militaryJoinDate ??
            DateTime.now().subtract(const Duration(days: 365 * 5));
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
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        switch (type) {
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
    switch (type) {
      case 'dateOfBirth':
        return 'Pilih Tanggal Lahir';
      case 'militaryJoinDate':
        return 'Pilih TMT Masuk Polri ';
      case 'jabatanTmt':
        return 'Pilih TMT Jabatan';
      default:
        return 'Pilih Tanggal';
    }
  }

  String _formatDate(DateTime date) {
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

  Widget _buildDatePicker({
    required String labelText,
    required DateTime? selectedDate,
    required String type,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _selectDate(type: type),
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
                        labelText + (isRequired ? ' *' : ''),
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
                          color:
                              selectedDate != null
                                  ? AppColors.darkNavy
                                  : AppColors.darkGray.withOpacity(0.6),
                          fontWeight:
                              selectedDate != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build step methods
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akun & Data Dasar',
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
                      width: 100,
                      height: 100,
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
                        child:
                            _selectedImage != null
                                ? Image.file(
                                  _selectedImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.lightGray,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.darkGray,
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
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                'Foto Profil (Opsional)',
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
          controller: _emailController,
          labelText: 'Email *',
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

        CustomTextField(
          controller: _passwordController,
          labelText: 'Password *',
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
          labelText: 'Konfirmasi Password *',
          prefixIcon: Icons.lock_outline,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              );
            },
          ),
          validator: (value) {
            if (value?.isEmpty ?? true)
              return 'Konfirmasi password tidak boleh kosong';
            if (value != _passwordController.text) return 'Password tidak sama';
            return null;
          },
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _fullNameController,
          labelText: 'Nama Lengkap *',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Nama tidak boleh kosong';
            if (value!.length < 3) return 'Nama minimal 3 karakter';
            return null;
          },
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _nrpController,
          labelText: 'NRP (Nomor Registrasi Pokok) *',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'NRP tidak boleh kosong';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Kepangkatan & Jabatan',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),

        CustomDropdown<String>(
          value: _rankController.text.isEmpty ? null : _rankController.text,
          labelText: 'Pangkat *',
          prefixIcon: Icons.military_tech_outlined,
          items:
              MilitaryRank.ranks
                  .map(
                    (rank) => DropdownMenuItem(value: rank, child: Text(rank)),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() => _rankController.text = value ?? ''),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Pilih pangkat';
            return null;
          },
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _jabatanController,
          labelText: 'Jabatan *',
          prefixIcon: Icons.work_outline,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Jabatan tidak boleh kosong';
            return null;
          },
        ),

        const SizedBox(height: AppSizes.paddingM),

        _buildDatePicker(
          labelText: 'TMT Jabatan',
          selectedDate: _jabatanTmt,
          type: 'jabatanTmt',
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomDropdown<UserRole>(
          value: _selectedRole,
          labelText: 'Satuan *',
          prefixIcon: Icons.group_outlined,
          items:
              UserRole.values
                  .where((e) => e != UserRole.admin)
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedRole = value),
          validator: (value) {
            if (value == null) return 'Pilih satuan';
            return null;
          },
        ),

        const SizedBox(height: AppSizes.paddingM),

        // CustomDropdown<String>(
        //   value: _selectedStatusPersonel,
        //   labelText: 'Status Personel',
        //   prefixIcon: Icons.person_pin_outlined,
        //   items: MilitaryRank.statusPersonel.map((status) => DropdownMenuItem(
        //     value: status,
        //     child: Text(status),
        //   )).toList(),
        //   onChanged: (value) => setState(() => _selectedStatusPersonel = value),
        // ),

        // const SizedBox(height: AppSizes.paddingM),
        _buildDatePicker(
          labelText: 'TMT Masuk Polri ',
          selectedDate: _militaryJoinDate,
          type: 'militaryJoinDate',
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Personal',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),

        CustomTextField(
          controller: _tempatLahirController,
          labelText: 'Tempat Lahir',
          prefixIcon: Icons.location_on_outlined,
        ),

        const SizedBox(height: AppSizes.paddingM),

        _buildDatePicker(
          labelText: 'Tanggal Lahir',
          selectedDate: _dateOfBirth,
          type: 'dateOfBirth',
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomDropdown<String>(
          value: _selectedAgama,
          labelText: 'Agama',
          prefixIcon: Icons.mosque_outlined,
          items:
              MilitaryRank.religions
                  .map(
                    (religion) => DropdownMenuItem(
                      value: religion,
                      child: Text(religion),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedAgama = value),
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _sukuController,
          labelText: 'Suku',
          prefixIcon: Icons.people_outline,
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomDropdown<String>(
          value: _selectedBloodType,
          labelText: 'Golongan Darah',
          prefixIcon: Icons.bloodtype_outlined,
          items:
              MilitaryRank.bloodTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedBloodType = value),
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomDropdown<String>(
          value: _selectedMaritalStatus,
          labelText: 'Status Pernikahan',
          prefixIcon: Icons.family_restroom_outlined,
          items:
              MilitaryRank.maritalStatuses
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedMaritalStatus = value),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendidikan Kepolisian',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          'Data pendidikan kepolisian yang pernah diikuti (opsional)',
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.darkGray),
        ),
        const SizedBox(height: AppSizes.paddingL),

        // List of Pendidikan Kepolisian
        ..._pendidikanKepolisian.asMap().entries.map((entry) {
          int index = entry.key;
          PendidikanKepolisian item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tingkat,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'Tahun: ${item.tahun}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () => _editPendidikanKepolisian(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deletePendidikanKepolisian(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        // Add button
        const SizedBox(height: AppSizes.paddingM),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addPendidikanKepolisian,
            icon: Icon(Icons.add, color: AppColors.primaryBlue),
            label: Text(
              'Tambah Pendidikan Kepolisian',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendidikan Umum',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          'Riwayat pendidikan umum dari SD hingga perguruan tinggi (opsional)',
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.darkGray),
        ),
        const SizedBox(height: AppSizes.paddingL),

        // List of Pendidikan Umum
        ..._pendidikanUmum.asMap().entries.map((entry) {
          int index = entry.key;
          PendidikanUmum item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tingkat,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        item.namaInstitusi,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        'Tahun: ${item.tahun}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () => _editPendidikanUmum(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deletePendidikanUmum(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        // Add button
        const SizedBox(height: AppSizes.paddingM),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addPendidikanUmum,
            icon: Icon(Icons.add, color: AppColors.primaryBlue),
            label: Text(
              'Tambah Pendidikan Umum',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Pangkat & Jabatan',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          'Riwayat perjalanan karier pangkat dan jabatan (opsional)',
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.darkGray),
        ),
        const SizedBox(height: AppSizes.paddingL),

        // Riwayat Pangkat Section
        Text(
          'Riwayat Pangkat',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        ..._riwayatPangkat.asMap().entries.map((entry) {
          int index = entry.key;
          RiwayatPangkat item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.pangkat,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'TMT: ${_formatDate(item.tmt)}',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      onPressed: () => _editRiwayatPangkat(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deleteRiwayatPangkat(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        OutlinedButton.icon(
          onPressed: _addRiwayatPangkat,
          icon: Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
          label: Text(
            'Tambah Riwayat Pangkat',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: AppColors.primaryBlue,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primaryBlue, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),

        const SizedBox(height: AppSizes.paddingL),

        // Riwayat Jabatan Section
        Text(
          'Riwayat Jabatan',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        ..._riwayatJabatan.asMap().entries.map((entry) {
          int index = entry.key;
          RiwayatJabatan item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.jabatan,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'TMT: ${_formatDate(item.tmt)}',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green, size: 18),
                      onPressed: () => _editRiwayatJabatan(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deleteRiwayatJabatan(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        OutlinedButton.icon(
          onPressed: _addRiwayatJabatan,
          icon: Icon(Icons.add, size: 16, color: Colors.green),
          label: Text(
            'Tambah Riwayat Jabatan',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.green),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.green, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStep7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pelatihan & Penghargaan',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          'Pendidikan pengembangan, pelatihan, dan tanda kehormatan (opsional)',
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.darkGray),
        ),
        const SizedBox(height: AppSizes.paddingL),

        // Pendidikan Pelatihan Section
        Text(
          'Pendidikan Pengembangan & Pelatihan',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        ..._pendidikanPelatihan.asMap().entries.map((entry) {
          int index = entry.key;
          PendidikanPelatihan item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.dikbang,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'TMT: ${_formatDate(item.tmt)}',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange, size: 18),
                      onPressed: () => _editPendidikanPelatihan(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deletePendidikanPelatihan(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        OutlinedButton.icon(
          onPressed: _addPendidikanPelatihan,
          icon: Icon(Icons.add, size: 16, color: Colors.orange),
          label: Text(
            'Tambah Pelatihan',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.orange),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.orange, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),

        const SizedBox(height: AppSizes.paddingL),

        // Tanda Kehormatan Section
        Text(
          'Tanda Kehormatan',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        ..._tandaKehormatan.asMap().entries.map((entry) {
          int index = entry.key;
          TandaKehormatan item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tandaKehormatan,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'TMT: ${_formatDate(item.tmt)}',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.purple, size: 18),
                      onPressed: () => _editTandaKehormatan(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deleteTandaKehormatan(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        OutlinedButton.icon(
          onPressed: _addTandaKehormatan,
          icon: Icon(Icons.add, size: 16, color: Colors.purple),
          label: Text(
            'Tambah Tanda Kehormatan',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.purple),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.purple, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStep8() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Tambahan & Kontak',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          'Kemampuan bahasa, penugasan khusus, dan informasi kontak (opsional)',
          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.darkGray),
        ),
        const SizedBox(height: AppSizes.paddingL),

        // Kemampuan Bahasa Section
        Text(
          'Kemampuan Bahasa',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        ..._kemampuanBahasa.asMap().entries.map((entry) {
          int index = entry.key;
          KemampuanBahasa item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.bahasa,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              item.status == 'AKTIF'
                                  ? Colors.green
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.teal, size: 18),
                      onPressed: () => _editKemampuanBahasa(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deleteKemampuanBahasa(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        OutlinedButton.icon(
          onPressed: _addKemampuanBahasa,
          icon: Icon(Icons.add, size: 16, color: Colors.teal),
          label: Text(
            'Tambah Kemampuan Bahasa',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.teal),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.teal, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),

        const SizedBox(height: AppSizes.paddingL),

        // Penugasan Luar Struktur Section
        Text(
          'Penugasan Luar Struktur',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        ..._penugasanLuarStruktur.asMap().entries.map((entry) {
          int index = entry.key;
          PenugasanLuarStruktur item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(color: Colors.indigo.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.penugasan,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Text(
                        'Lokasi: ${item.lokasi}',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.indigo, size: 18),
                      onPressed: () => _editPenugasanLuarStruktur(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => _deletePenugasanLuarStruktur(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        OutlinedButton.icon(
          onPressed: _addPenugasanLuarStruktur,
          icon: Icon(Icons.add, size: 16, color: Colors.indigo),
          label: Text(
            'Tambah Penugasan',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.indigo),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.indigo, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),

        const SizedBox(height: AppSizes.paddingL),

        // Contact Information
        Text(
          'Informasi Kontak',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _phoneController,
          labelText: 'Nomor Telepon',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _addressController,
          labelText: 'Alamat Lengkap',
          prefixIcon: Icons.home_outlined,
          maxLines: 3,
        ),

        const SizedBox(height: AppSizes.paddingM),

        CustomTextField(
          controller: _emergencyContactController,
          labelText: 'Kontak Darurat',
          prefixIcon: Icons.contact_emergency_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: AppSizes.paddingL),

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
                  'Pendaftaran hampir selesai! Data yang kosong dapat dilengkapi kemudian melalui menu profil. Akun akan diverifikasi admin sebelum diaktifkan.',
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
    );
  }

  // Modal methods for dynamic data management
  void _addPendidikanKepolisian() {
    _showPendidikanKepolisianModal();
  }

  void _editPendidikanKepolisian(int index) {
    _showPendidikanKepolisianModal(index: index);
  }

  void _deletePendidikanKepolisian(int index) {
    setState(() {
      _pendidikanKepolisian.removeAt(index);
    });
  }

  void _showPendidikanKepolisianModal({int? index}) {
    final TextEditingController tingkatController = TextEditingController();
    final TextEditingController tahunController = TextEditingController();

    if (index != null) {
      final item = _pendidikanKepolisian[index];
      tingkatController.text = item.tingkat;
      tahunController.text = item.tahun.toString();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              index == null
                  ? 'Tambah Pendidikan Kepolisian'
                  : 'Edit Pendidikan Kepolisian',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDropdown<String>(
                  value:
                      tingkatController.text.isEmpty
                          ? null
                          : tingkatController.text,
                  labelText: 'Tingkat Pendidikan',
                  prefixIcon: Icons.school_outlined,
                  items:
                      MilitaryRank.pendidikanKepolisian
                          .map(
                            (tingkat) => DropdownMenuItem(
                              value: tingkat,
                              child: Text(tingkat),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => tingkatController.text = value ?? '',
                ),
                const SizedBox(height: AppSizes.paddingM),
                CustomTextField(
                  controller: tahunController,
                  labelText: 'Tahun Lulus',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tingkatController.text.isNotEmpty &&
                      tahunController.text.isNotEmpty) {
                    final item = PendidikanKepolisian(
                      tingkat: tingkatController.text,
                      tahun:
                          int.tryParse(tahunController.text) ??
                          DateTime.now().year,
                    );

                    setState(() {
                      if (index == null) {
                        _pendidikanKepolisian.add(item);
                      } else {
                        _pendidikanKepolisian[index] = item;
                      }
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  // Similar modal methods for other dynamic data types...
  void _addPendidikanUmum() => _showPendidikanUmumModal();
  void _editPendidikanUmum(int index) => _showPendidikanUmumModal(index: index);
  void _deletePendidikanUmum(int index) {
    setState(() => _pendidikanUmum.removeAt(index));
  }

  void _showPendidikanUmumModal({int? index}) {
    final TextEditingController tingkatController = TextEditingController();
    final TextEditingController institusiController = TextEditingController();
    final TextEditingController tahunController = TextEditingController();

    if (index != null) {
      final item = _pendidikanUmum[index];
      tingkatController.text = item.tingkat;
      institusiController.text = item.namaInstitusi;
      tahunController.text = item.tahun.toString();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              index == null ? 'Tambah Pendidikan Umum' : 'Edit Pendidikan Umum',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDropdown<String>(
                  value:
                      tingkatController.text.isEmpty
                          ? null
                          : tingkatController.text,
                  labelText: 'Tingkat Pendidikan',
                  prefixIcon: Icons.school_outlined,
                  items:
                      MilitaryRank.educationLevels
                          .map(
                            (tingkat) => DropdownMenuItem(
                              value: tingkat,
                              child: Text(tingkat),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => tingkatController.text = value ?? '',
                ),
                const SizedBox(height: AppSizes.paddingM),
                CustomTextField(
                  controller: institusiController,
                  labelText: 'Nama Institusi',
                  prefixIcon: Icons.business_outlined,
                ),
                const SizedBox(height: AppSizes.paddingM),
                CustomTextField(
                  controller: tahunController,
                  labelText: 'Tahun Lulus',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tingkatController.text.isNotEmpty &&
                      institusiController.text.isNotEmpty &&
                      tahunController.text.isNotEmpty) {
                    final item = PendidikanUmum(
                      tingkat: tingkatController.text,
                      namaInstitusi: institusiController.text,
                      tahun:
                          int.tryParse(tahunController.text) ??
                          DateTime.now().year,
                    );

                    setState(() {
                      if (index == null) {
                        _pendidikanUmum.add(item);
                      } else {
                        _pendidikanUmum[index] = item;
                      }
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  // Riwayat Pangkat methods
  void _addRiwayatPangkat() => _showRiwayatPangkatModal();
  void _editRiwayatPangkat(int index) => _showRiwayatPangkatModal(index: index);
  void _deleteRiwayatPangkat(int index) {
    setState(() => _riwayatPangkat.removeAt(index));
  }

  void _showRiwayatPangkatModal({int? index}) {
    final TextEditingController pangkatController = TextEditingController();
    DateTime? selectedTmt;

    if (index != null) {
      final item = _riwayatPangkat[index];
      pangkatController.text = item.pangkat;
      selectedTmt = item.tmt;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    index == null
                        ? 'Tambah Riwayat Pangkat'
                        : 'Edit Riwayat Pangkat',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomDropdown<String>(
                        value:
                            pangkatController.text.isEmpty
                                ? null
                                : pangkatController.text,
                        labelText: 'Pangkat',
                        prefixIcon: Icons.military_tech_outlined,
                        items:
                            MilitaryRank.ranks
                                .map(
                                  (pangkat) => DropdownMenuItem(
                                    value: pangkat,
                                    child: Text(pangkat),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => pangkatController.text = value ?? '',
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedTmt ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedTmt = picked);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 12),
                              Text(
                                selectedTmt != null
                                    ? _formatDate(selectedTmt!)
                                    : 'Tahun',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (pangkatController.text.isNotEmpty &&
                            selectedTmt != null) {
                          final item = RiwayatPangkat(
                            pangkat: pangkatController.text,
                            tmt: selectedTmt!,
                          );

                          this.setState(() {
                            if (index == null) {
                              _riwayatPangkat.add(item);
                            } else {
                              _riwayatPangkat[index] = item;
                            }
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: Text(index == null ? 'Tambah' : 'Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Riwayat Jabatan methods
  void _addRiwayatJabatan() => _showRiwayatJabatanModal();
  void _editRiwayatJabatan(int index) => _showRiwayatJabatanModal(index: index);
  void _deleteRiwayatJabatan(int index) {
    setState(() => _riwayatJabatan.removeAt(index));
  }

  void _showRiwayatJabatanModal({int? index}) {
    final TextEditingController jabatanController = TextEditingController();
    DateTime? selectedTmt;

    if (index != null) {
      final item = _riwayatJabatan[index];
      jabatanController.text = item.jabatan;
      selectedTmt = item.tmt;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    index == null
                        ? 'Tambah Riwayat Jabatan'
                        : 'Edit Riwayat Jabatan',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: jabatanController,
                        labelText: 'Jabatan',
                        prefixIcon: Icons.work_outline,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedTmt ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedTmt = picked);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 12),
                              Text(
                                selectedTmt != null
                                    ? _formatDate(selectedTmt!)
                                    : 'Tahun',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (jabatanController.text.isNotEmpty &&
                            selectedTmt != null) {
                          final item = RiwayatJabatan(
                            jabatan: jabatanController.text,
                            tmt: selectedTmt!,
                          );

                          this.setState(() {
                            if (index == null) {
                              _riwayatJabatan.add(item);
                            } else {
                              _riwayatJabatan[index] = item;
                            }
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: Text(index == null ? 'Tambah' : 'Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Pendidikan Pelatihan methods
  void _addPendidikanPelatihan() => _showPendidikanPelatihanModal();
  void _editPendidikanPelatihan(int index) =>
      _showPendidikanPelatihanModal(index: index);
  void _deletePendidikanPelatihan(int index) {
    setState(() => _pendidikanPelatihan.removeAt(index));
  }

  void _showPendidikanPelatihanModal({int? index}) {
    final TextEditingController dikbangController = TextEditingController();
    DateTime? selectedTmt;

    if (index != null) {
      final item = _pendidikanPelatihan[index];
      dikbangController.text = item.dikbang;
      selectedTmt = item.tmt;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    index == null
                        ? 'Tambah Pendidikan Pelatihan'
                        : 'Edit Pendidikan Pelatihan',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: dikbangController,
                        labelText: 'Nama Pelatihan/Dikbang',
                        prefixIcon: Icons.school_outlined,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedTmt ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedTmt = picked);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 12),
                              Text(
                                selectedTmt != null
                                    ? _formatDate(selectedTmt!)
                                    : 'Tahun',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (dikbangController.text.isNotEmpty &&
                            selectedTmt != null) {
                          final item = PendidikanPelatihan(
                            dikbang: dikbangController.text,
                            tmt: selectedTmt!,
                          );

                          this.setState(() {
                            if (index == null) {
                              _pendidikanPelatihan.add(item);
                            } else {
                              _pendidikanPelatihan[index] = item;
                            }
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: Text(index == null ? 'Tambah' : 'Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Tanda Kehormatan methods
  void _addTandaKehormatan() => _showTandaKehormatanModal();
  void _editTandaKehormatan(int index) =>
      _showTandaKehormatanModal(index: index);
  void _deleteTandaKehormatan(int index) {
    setState(() => _tandaKehormatan.removeAt(index));
  }

  void _showTandaKehormatanModal({int? index}) {
    final TextEditingController tandaController = TextEditingController();
    DateTime? selectedTmt;

    if (index != null) {
      final item = _tandaKehormatan[index];
      tandaController.text = item.tandaKehormatan;
      selectedTmt = item.tmt;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    index == null
                        ? 'Tambah Tanda Kehormatan'
                        : 'Edit Tanda Kehormatan',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: tandaController,
                        labelText: 'Tanda Kehormatan',
                        prefixIcon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedTmt ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedTmt = picked);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 12),
                              Text(
                                selectedTmt != null
                                    ? _formatDate(selectedTmt!)
                                    : 'Tahun',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (tandaController.text.isNotEmpty &&
                            selectedTmt != null) {
                          final item = TandaKehormatan(
                            tandaKehormatan: tandaController.text,
                            tmt: selectedTmt!,
                          );

                          this.setState(() {
                            if (index == null) {
                              _tandaKehormatan.add(item);
                            } else {
                              _tandaKehormatan[index] = item;
                            }
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: Text(index == null ? 'Tambah' : 'Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Kemampuan Bahasa methods
  void _addKemampuanBahasa() => _showKemampuanBahasaModal();
  void _editKemampuanBahasa(int index) =>
      _showKemampuanBahasaModal(index: index);
  void _deleteKemampuanBahasa(int index) {
    setState(() => _kemampuanBahasa.removeAt(index));
  }

  void _showKemampuanBahasaModal({int? index}) {
    final TextEditingController bahasaController = TextEditingController();
    final TextEditingController statusController = TextEditingController();

    if (index != null) {
      final item = _kemampuanBahasa[index];
      bahasaController.text = item.bahasa;
      statusController.text = item.status;
    } else {
      statusController.text = 'TIDAK AKTIF'; // default value
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              index == null
                  ? 'Tambah Kemampuan Bahasa'
                  : 'Edit Kemampuan Bahasa',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDropdown<String>(
                  value:
                      bahasaController.text.isEmpty
                          ? null
                          : bahasaController.text,
                  labelText: 'Bahasa',
                  prefixIcon: Icons.language_outlined,
                  items:
                      MilitaryRank.bahasaList
                          .map(
                            (bahasa) => DropdownMenuItem(
                              value: bahasa,
                              child: Text(bahasa),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => bahasaController.text = value ?? '',
                ),
                const SizedBox(height: AppSizes.paddingM),
                CustomDropdown<String>(
                  value:
                      statusController.text.isEmpty
                          ? null
                          : statusController.text,
                  labelText: 'Status Kemampuan',
                  prefixIcon: Icons.check_circle_outline,
                  items:
                      MilitaryRank.statusBahasa
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => statusController.text = value ?? '',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (bahasaController.text.isNotEmpty &&
                      statusController.text.isNotEmpty) {
                    final item = KemampuanBahasa(
                      bahasa: bahasaController.text,
                      status: statusController.text,
                    );

                    setState(() {
                      if (index == null) {
                        _kemampuanBahasa.add(item);
                      } else {
                        _kemampuanBahasa[index] = item;
                      }
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  // Penugasan Luar Struktur methods
  void _addPenugasanLuarStruktur() => _showPenugasanLuarStrukturModal();
  void _editPenugasanLuarStruktur(int index) =>
      _showPenugasanLuarStrukturModal(index: index);
  void _deletePenugasanLuarStruktur(int index) {
    setState(() => _penugasanLuarStruktur.removeAt(index));
  }

  void _showPenugasanLuarStrukturModal({int? index}) {
    final TextEditingController penugasanController = TextEditingController();
    final TextEditingController lokasiController = TextEditingController();

    if (index != null) {
      final item = _penugasanLuarStruktur[index];
      penugasanController.text = item.penugasan;
      lokasiController.text = item.lokasi;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              index == null
                  ? 'Tambah Penugasan Luar Struktur'
                  : 'Edit Penugasan Luar Struktur',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: penugasanController,
                  labelText: 'Jenis Penugasan',
                  prefixIcon: Icons.assignment_outlined,
                ),
                const SizedBox(height: AppSizes.paddingM),
                CustomTextField(
                  controller: lokasiController,
                  labelText: 'Lokasi Penugasan',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (penugasanController.text.isNotEmpty &&
                      lokasiController.text.isNotEmpty) {
                    final item = PenugasanLuarStruktur(
                      penugasan: penugasanController.text,
                      lokasi: lokasiController.text,
                    );

                    setState(() {
                      if (index == null) {
                        _penugasanLuarStruktur.add(item);
                      } else {
                        _penugasanLuarStruktur[index] = item;
                      }
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'PENDAFTARAN PERSONEL BRIMOB',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Step indicator
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                ),
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                          right: index < _totalSteps - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              index <= _currentStep
                                  ? AppColors.white
                                  : AppColors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: AppSizes.paddingS),

              // Step title
              Text(
                'Langkah ${_currentStep + 1} dari $_totalSteps',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Form content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(AppSizes.paddingL),
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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Step content
                          if (_currentStep == 0) _buildStep1(),
                          if (_currentStep == 1) _buildStep2(),
                          if (_currentStep == 2) _buildStep3(),
                          if (_currentStep == 3) _buildStep4(),
                          if (_currentStep == 4) _buildStep5(),
                          if (_currentStep == 5) _buildStep6(),
                          if (_currentStep == 6) _buildStep7(),
                          if (_currentStep == 7) _buildStep8(),

                          const SizedBox(height: AppSizes.paddingXL),

                          // Navigation buttons
                          Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        () => setState(() => _currentStep--),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primaryBlue,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusM,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'SEBELUMNYA',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),

                              if (_currentStep > 0)
                                const SizedBox(width: AppSizes.paddingM),

                              Expanded(
                                child:
                                    _currentStep < _totalSteps - 1
                                        ? ElevatedButton(
                                          onPressed: () {
                                            if (_currentStep == 0) {
                                              if (_emailController
                                                      .text
                                                      .isEmpty ||
                                                  _passwordController
                                                      .text
                                                      .isEmpty ||
                                                  _fullNameController
                                                      .text
                                                      .isEmpty ||
                                                  _nrpController.text.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Mohon lengkapi field yang wajib diisi',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                            }
                                            if (_currentStep == 1) {
                                              if (_rankController
                                                      .text
                                                      .isEmpty ||
                                                  _jabatanController
                                                      .text
                                                      .isEmpty ||
                                                  _selectedRole == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Mohon lengkapi field yang wajib diisi',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                            }
                                            setState(() => _currentStep++);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppSizes.radiusM,
                                                  ),
                                            ),
                                          ),
                                          child: Text(
                                            'SELANJUTNYA',
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        )
                                        : CustomButton(
                                          onPressed:
                                              _isLoading ? null : _register,
                                          text:
                                              _isLoading
                                                  ? 'Mendaftar...'
                                                  : 'DAFTAR',
                                          isLoading: _isLoading,
                                        ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
