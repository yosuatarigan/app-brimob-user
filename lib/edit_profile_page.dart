import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel currentUser;
  
  const EditProfilePage({
    super.key,
    required this.currentUser,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _rankController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _sukuController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  // Data variables
  UserRole? _selectedRole;
  String? _selectedAgama;
  String? _selectedBloodType;
  String? _selectedMaritalStatus;
  String? _selectedStatusPersonel;
  DateTime? _dateOfBirth;
  DateTime? _militaryJoinDate;
  DateTime? _jabatanTmt;
  File? _selectedImage;
  String? _currentPhotoUrl;
  
  // Complex data arrays
  List<PendidikanKepolisian> _pendidikanKepolisian = [];
  List<PendidikanUmum> _pendidikanUmum = [];
  List<RiwayatPangkat> _riwayatPangkat = [];
  List<RiwayatJabatan> _riwayatJabatan = [];
  List<PendidikanPelatihan> _pendidikanPelatihan = [];
  List<TandaKehormatan> _tandaKehormatan = [];
  List<KemampuanBahasa> _kemampuanBahasa = [];
  List<PenugasanLuarStruktur> _penugasanLuarStruktur = [];
  
  bool _isLoading = false;
  bool _hasChanges = false;
  int _currentStep = 0;
  final int _totalSteps = 8;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final user = widget.currentUser;
    
    // Initialize basic fields
    _fullNameController.text = user.fullName;
    _nrpController.text = user.nrp;
    _rankController.text = user.rank;
    _jabatanController.text = user.jabatan;
    _tempatLahirController.text = user.tempatLahir ?? '';
    _sukuController.text = user.suku ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _emergencyContactController.text = user.emergencyContact ?? '';
    
    _selectedRole = user.role;
    _selectedAgama = user.agama;
    _selectedBloodType = user.bloodType;
    _selectedMaritalStatus = user.maritalStatus;
    _selectedStatusPersonel = user.statusPersonel;
    _dateOfBirth = user.dateOfBirth;
    _militaryJoinDate = user.militaryJoinDate;
    _jabatanTmt = user.jabatanTmt;
    _currentPhotoUrl = user.photoUrl;
    
    // Initialize complex arrays with proper null checks
    _pendidikanKepolisian = List.from(user.pendidikanKepolisian ?? []);
    _pendidikanUmum = List.from(user.pendidikanUmum ?? []);
    _riwayatPangkat = List.from(user.riwayatPangkat ?? []);
    _riwayatJabatan = List.from(user.riwayatJabatan ?? []);
    _pendidikanPelatihan = List.from(user.pendidikanPelatihan ?? []);
    _tandaKehormatan = List.from(user.tandaKehormatan ?? []);
    _kemampuanBahasa = List.from(user.kemampuanBahasa ?? []);
    _penugasanLuarStruktur = List.from(user.penugasanLuarStruktur ?? []);
    
    _addChangeListeners();
  }

  void _addChangeListeners() {
    _fullNameController.addListener(() => _setHasChanges(true));
    _nrpController.addListener(() => _setHasChanges(true));
    _rankController.addListener(() => _setHasChanges(true));
    _jabatanController.addListener(() => _setHasChanges(true));
    _tempatLahirController.addListener(() => _setHasChanges(true));
    _sukuController.addListener(() => _setHasChanges(true));
    _phoneController.addListener(() => _setHasChanges(true));
    _addressController.addListener(() => _setHasChanges(true));
    _emergencyContactController.addListener(() => _setHasChanges(true));
  }

  void _setHasChanges(bool value) {
    if (_hasChanges != value) {
      setState(() => _hasChanges = value);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nrpController.dispose();
    _rankController.dispose();
    _jabatanController.dispose();
    _tempatLahirController.dispose();
    _sukuController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedImage != null) {
        final result = await _authService.updateProfilePhoto(
          userId: widget.currentUser.id,
          imageFile: _selectedImage!,
        );
        
        if (result['success']) {
          _currentPhotoUrl = result['photoUrl'];
        } else {
          throw Exception(result['message']);
        }
      }

      final updatedUser = widget.currentUser.copyWith(
        fullName: _fullNameController.text.trim(),
        nrp: _nrpController.text.trim(),
        rank: _rankController.text.trim(),
        jabatan: _jabatanController.text.trim(),
        role: _selectedRole,
        tempatLahir: _tempatLahirController.text.trim().isEmpty ? null : _tempatLahirController.text.trim(),
        suku: _sukuController.text.trim().isEmpty ? null : _sukuController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
        agama: _selectedAgama,
        bloodType: _selectedBloodType,
        maritalStatus: _selectedMaritalStatus,
        statusPersonel: _selectedStatusPersonel,
        dateOfBirth: _dateOfBirth,
        militaryJoinDate: _militaryJoinDate,
        jabatanTmt: _jabatanTmt,
        photoUrl: _currentPhotoUrl,
        pendidikanKepolisian: _pendidikanKepolisian,
        pendidikanUmum: _pendidikanUmum,
        riwayatPangkat: _riwayatPangkat,
        riwayatJabatan: _riwayatJabatan,
        pendidikanPelatihan: _pendidikanPelatihan,
        tandaKehormatan: _tandaKehormatan,
        kemampuanBahasa: _kemampuanBahasa,
        penugasanLuarStruktur: _penugasanLuarStruktur,
        updatedAt: DateTime.now(),
      );

      final result = await _authService.updateUserProfile(
        userId: widget.currentUser.id,
        updatedUser: updatedUser,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        _showSnackBar(
          result['success'] ? 'Profil berhasil diperbarui' : result['message'],
          result['success'],
        );

        if (result['success']) {
          setState(() => _hasChanges = false);
          Navigator.pop(context, updatedUser);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', false);
      }
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Photo selection methods
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
            Icon(icon, size: 32, color: AppColors.primaryBlue),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkNavy,
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
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memilih foto: ${e.toString()}', false);
      }
    }
  }

  // Date picker methods
  Future<void> _selectDate({required String type}) async {
    final DateTime firstDate = DateTime(1960);
    final DateTime lastDate = DateTime.now();
    DateTime initialDate;
    
    switch(type) {
      case 'dateOfBirth':
        initialDate = _dateOfBirth ?? DateTime(1990, 1, 1);
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
        _hasChanges = true;
      });
    }
  }

  String _getDatePickerTitle(String type) {
    switch(type) {
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
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildDatePicker({
    required String labelText,
    required DateTime? selectedDate,
    required String type,
    bool isRequired = false,
  }) {
    return InkWell(
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
            Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
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
                    selectedDate != null ? _formatDate(selectedDate) : 'Pilih tanggal',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: selectedDate != null ? AppColors.darkNavy : AppColors.darkGray.withOpacity(0.6),
                      fontWeight: selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  // Build all 8 steps
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
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : _currentPhotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: _currentPhotoUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.lightGray,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColors.lightGray,
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
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
        
        // Email info
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.lightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(
                  'Email tidak dapat diubah. Hubungi admin jika perlu mengubah email.',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSizes.paddingM),
        
        CustomTextField(
          controller: TextEditingController(text: widget.currentUser.email),
          labelText: 'Email',
          prefixIcon: Icons.email_outlined,
          enabled: false,
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
          items: MilitaryRank.ranks.map((rank) => DropdownMenuItem(
            value: rank,
            child: Text(rank),
          )).toList(),
          onChanged: (value) => setState(() {
            _rankController.text = value ?? '';
            _hasChanges = true;
          }),
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
          items: UserRole.values.where((role) => role != UserRole.admin).map((role) => DropdownMenuItem(
            value: role,
            child: Text(role.displayName),
          )).toList(),
          onChanged: (value) => setState(() {
            _selectedRole = value;
            _hasChanges = true;
          }),
          validator: (value) {
            if (value == null) return 'Pilih satuan';
            return null;
          },
        ),
        
        const SizedBox(height: AppSizes.paddingM),
        
        // Status personel (read-only for user)
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.darkGray.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.person_pin_outlined, color: AppColors.darkGray),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Personel',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedStatusPersonel ?? 'Belum ditentukan',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: AppColors.darkNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.lock_outline, color: AppColors.darkGray, size: 16),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          'Status personel hanya dapat diubah oleh admin',
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: AppColors.darkGray,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: AppSizes.paddingM),
        
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
          items: MilitaryRank.religions.map((religion) => DropdownMenuItem(
            value: religion,
            child: Text(religion),
          )).toList(),
          onChanged: (value) => setState(() {
            _selectedAgama = value;
            _hasChanges = true;
          }),
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
          items: MilitaryRank.bloodTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: (value) => setState(() {
            _selectedBloodType = value;
            _hasChanges = true;
          }),
        ),
        
        const SizedBox(height: AppSizes.paddingM),
        
        CustomDropdown<String>(
          value: _selectedMaritalStatus,
          labelText: 'Status Pernikahan',
          prefixIcon: Icons.family_restroom_outlined,
          items: MilitaryRank.maritalStatuses.map((status) => DropdownMenuItem(
            value: status,
            child: Text(status),
          )).toList(),
          onChanged: (value) => setState(() {
            _selectedMaritalStatus = value;
            _hasChanges = true;
          }),
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
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
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
                      icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
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
              'Tambah Pendidikan Pertama Kepolisian',
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
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
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
                      icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
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
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
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
                      icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 18),
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
            style: GoogleFonts.roboto(fontSize: 12, color: AppColors.primaryBlue),
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
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
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
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == 'AKTIF' ? Colors.green : Colors.grey,
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
                  'Perubahan profil akan disimpan dan dapat dilihat oleh admin.',
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

  // Modal methods for all complex arrays
  void _addPendidikanKepolisian() => _showPendidikanKepolisianModal();
  void _editPendidikanKepolisian(int index) => _showPendidikanKepolisianModal(index: index);
  void _deletePendidikanKepolisian(int index) {
    setState(() {
      _pendidikanKepolisian.removeAt(index);
      _hasChanges = true;
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
      builder: (context) => AlertDialog(
        title: Text(
          index == null ? 'Tambah Pendidikan Pertama Kepolisian' : 'Edit Pendidikan Pertama Kepolisian',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown<String>(
              value: tingkatController.text.isEmpty ? null : tingkatController.text,
              labelText: 'Tingkat Pendidikan',
              prefixIcon: Icons.school_outlined,
              items: MilitaryRank.pendidikanKepolisian.map((tingkat) => DropdownMenuItem(
                value: tingkat,
                child: Text(tingkat),
              )).toList(),
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
              if (tingkatController.text.isNotEmpty && tahunController.text.isNotEmpty) {
                final item = PendidikanKepolisian(
                  tingkat: tingkatController.text,
                  tahun: int.tryParse(tahunController.text) ?? DateTime.now().year,
                );
                
                setState(() {
                  if (index == null) {
                    _pendidikanKepolisian.add(item);
                  } else {
                    _pendidikanKepolisian[index] = item;
                  }
                  _hasChanges = true;
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

  void _addPendidikanUmum() => _showPendidikanUmumModal();
  void _editPendidikanUmum(int index) => _showPendidikanUmumModal(index: index);
  void _deletePendidikanUmum(int index) {
    setState(() {
      _pendidikanUmum.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => AlertDialog(
        title: Text(
          index == null ? 'Tambah Pendidikan Umum' : 'Edit Pendidikan Umum',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown<String>(
              value: tingkatController.text.isEmpty ? null : tingkatController.text,
              labelText: 'Tingkat Pendidikan',
              prefixIcon: Icons.school_outlined,
              items: MilitaryRank.educationLevels.map((tingkat) => DropdownMenuItem(
                value: tingkat,
                child: Text(tingkat),
              )).toList(),
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
                  tahun: int.tryParse(tahunController.text) ?? DateTime.now().year,
                );
                
                setState(() {
                  if (index == null) {
                    _pendidikanUmum.add(item);
                  } else {
                    _pendidikanUmum[index] = item;
                  }
                  _hasChanges = true;
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

  void _addRiwayatPangkat() => _showRiwayatPangkatModal();
  void _editRiwayatPangkat(int index) => _showRiwayatPangkatModal(index: index);
  void _deleteRiwayatPangkat(int index) {
    setState(() {
      _riwayatPangkat.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            index == null ? 'Tambah Riwayat Pangkat' : 'Edit Riwayat Pangkat',
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDropdown<String>(
                value: pangkatController.text.isEmpty ? null : pangkatController.text,
                labelText: 'Pangkat',
                prefixIcon: Icons.military_tech_outlined,
                items: MilitaryRank.ranks.map((pangkat) => DropdownMenuItem(
                  value: pangkat,
                  child: Text(pangkat),
                )).toList(),
                onChanged: (value) => pangkatController.text = value ?? '',
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
                      Text(selectedTmt != null ? _formatDate(selectedTmt!) : 'Pilih TMT'),
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
                if (pangkatController.text.isNotEmpty && selectedTmt != null) {
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
                    _hasChanges = true;
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

  void _addRiwayatJabatan() => _showRiwayatJabatanModal();
  void _editRiwayatJabatan(int index) => _showRiwayatJabatanModal(index: index);
  void _deleteRiwayatJabatan(int index) {
    setState(() {
      _riwayatJabatan.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            index == null ? 'Tambah Riwayat Jabatan' : 'Edit Riwayat Jabatan',
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
                      Text(selectedTmt != null ? _formatDate(selectedTmt!) : 'Pilih TMT'),
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
                if (jabatanController.text.isNotEmpty && selectedTmt != null) {
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
                    _hasChanges = true;
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

  void _addPendidikanPelatihan() => _showPendidikanPelatihanModal();
  void _editPendidikanPelatihan(int index) => _showPendidikanPelatihanModal(index: index);
  void _deletePendidikanPelatihan(int index) {
    setState(() {
      _pendidikanPelatihan.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            index == null ? 'Tambah Pendidikan Pelatihan' : 'Edit Pendidikan Pelatihan',
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
                      Text(selectedTmt != null ? _formatDate(selectedTmt!) : 'Pilih TMT'),
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
                if (dikbangController.text.isNotEmpty && selectedTmt != null) {
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
                    _hasChanges = true;
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

  void _addTandaKehormatan() => _showTandaKehormatanModal();
  void _editTandaKehormatan(int index) => _showTandaKehormatanModal(index: index);
  void _deleteTandaKehormatan(int index) {
    setState(() {
      _tandaKehormatan.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            index == null ? 'Tambah Tanda Kehormatan' : 'Edit Tanda Kehormatan',
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
                      Text(selectedTmt != null ? _formatDate(selectedTmt!) : 'Pilih TMT'),
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
                if (tandaController.text.isNotEmpty && selectedTmt != null) {
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
                    _hasChanges = true;
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

  void _addKemampuanBahasa() => _showKemampuanBahasaModal();
  void _editKemampuanBahasa(int index) => _showKemampuanBahasaModal(index: index);
  void _deleteKemampuanBahasa(int index) {
    setState(() {
      _kemampuanBahasa.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => AlertDialog(
        title: Text(
          index == null ? 'Tambah Kemampuan Bahasa' : 'Edit Kemampuan Bahasa',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown<String>(
              value: bahasaController.text.isEmpty ? null : bahasaController.text,
              labelText: 'Bahasa',
              prefixIcon: Icons.language_outlined,
              items: MilitaryRank.bahasaList.map((bahasa) => DropdownMenuItem(
                value: bahasa,
                child: Text(bahasa),
              )).toList(),
              onChanged: (value) => bahasaController.text = value ?? '',
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomDropdown<String>(
              value: statusController.text.isEmpty ? null : statusController.text,
              labelText: 'Status Kemampuan',
              prefixIcon: Icons.check_circle_outline,
              items: MilitaryRank.statusBahasa.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              )).toList(),
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
              if (bahasaController.text.isNotEmpty && statusController.text.isNotEmpty) {
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
                  _hasChanges = true;
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

  void _addPenugasanLuarStruktur() => _showPenugasanLuarStrukturModal();
  void _editPenugasanLuarStruktur(int index) => _showPenugasanLuarStrukturModal(index: index);
  void _deletePenugasanLuarStruktur(int index) {
    setState(() {
      _penugasanLuarStruktur.removeAt(index);
      _hasChanges = true;
    });
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
      builder: (context) => AlertDialog(
        title: Text(
          index == null ? 'Tambah Penugasan Luar Struktur' : 'Edit Penugasan Luar Struktur',
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
              if (penugasanController.text.isNotEmpty && lokasiController.text.isNotEmpty) {
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
                  _hasChanges = true;
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
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'EDIT DATA DIRI PERSONEL',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      child: _hasChanges
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),

              // Step indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                          right: index < _totalSteps - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
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
                                  onPressed: () => setState(() => _currentStep--),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primaryBlue),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
                            
                            if (_currentStep > 0) const SizedBox(width: AppSizes.paddingM),
                            
                            Expanded(
                              child: _currentStep < _totalSteps - 1
                                  ? ElevatedButton(
                                      onPressed: () => setState(() => _currentStep++),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
                                  : ElevatedButton(
                                      onPressed: _isLoading || !_hasChanges ? null : _saveChanges,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _hasChanges ? AppColors.primaryBlue : AppColors.darkGray,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                              ),
                                            )
                                          : Text(
                                              'SIMPAN PERUBAHAN',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.white,
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
      ),
    );
  }
}