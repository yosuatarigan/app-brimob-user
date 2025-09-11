import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_date_picker.dart';

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
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  UserRole? _selectedRole;
  DateTime? _dateOfBirth;
  DateTime? _militaryJoinDate;

  final List<String> _ranks = [
    'AIPDA', 'AIPTU', 'IPDA', 'IPTU', 'AKP', 'KOMPOL', 
    'AKBP', 'KOMBES', 'BRIGJEN', 'IRJEN', 'KOMJEN'
  ];

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

    final result = await _authService.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      nrp: _nrpController.text.trim(),
      rank: _rankController.text.trim(),
      role: _selectedRole!,
      dateOfBirth: _dateOfBirth!,
      militaryJoinDate: _militaryJoinDate!,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.darkNavy,
            ],
          ),
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
                        const SizedBox(height: AppSizes.paddingM),
                        
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
                        
                        CustomDatePicker(
                          labelText: 'Tanggal Lahir',
                          selectedDate: _dateOfBirth,
                          onDateSelected: (date) => setState(() => _dateOfBirth = date),
                          firstDate: DateTime(1960),
                          lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
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
                          items: _ranks.map((rank) => DropdownMenuItem(
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
                        
                        CustomDatePicker(
                          labelText: 'Tanggal Masuk Militer',
                          selectedDate: _militaryJoinDate,
                          onDateSelected: (date) => setState(() => _militaryJoinDate = date),
                          firstDate: DateTime(1980),
                          lastDate: DateTime.now(),
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
                            color: Colors.lightBlue.withOpacity(0.1),
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