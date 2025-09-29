import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class PendingApprovalPage extends StatelessWidget {
  final UserModel user;
  final AuthService _authService = AuthService();

  PendingApprovalPage({
    super.key,
    required this.user,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
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
            child: Column(
              children: [
                const SizedBox(height: AppSizes.paddingXL),
                
                // Logo and Status Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: user.photoUrl != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  placeholder: (context, url) => const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primaryBlue,
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Emblem_of_the_Indonesian_National_Police.svg/200px-Emblem_of_the_Indonesian_National_Police.svg.png',
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Icon(
                                  Icons.security,
                                  size: 80,
                                  color: AppColors.primaryBlue,
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.security,
                                  size: 80,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.goldYellow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: AppColors.darkNavy,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.paddingXL),
                
                // Status Title
                Text(
                  'MENUNGGU PERSETUJUAN',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                
                const SizedBox(height: AppSizes.paddingM),
                
                Text(
                  'Akun Anda sedang diverifikasi oleh admin',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.goldYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: AppSizes.paddingXL),
                
                // User Information Card
                Container(
                  width: double.infinity,
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
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: user.photoUrl != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: user.photoUrl!,
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                      placeholder: (context, url) => const Icon(
                                        Icons.person,
                                        color: AppColors.primaryBlue,
                                        size: 30,
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.person,
                                        color: AppColors.primaryBlue,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: AppColors.primaryBlue,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: AppSizes.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                                if (user.rank.isNotEmpty)
                                  Text(
                                    '${user.rank}${user.jabatan.isNotEmpty ? ' • ${user.jabatan}' : ''}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: AppColors.darkGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                Text(
                                  user.role.displayName,
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSizes.paddingL),
                      
                      // Basic Information Section
                      _buildSectionTitle('Data Dasar'),
                      const SizedBox(height: AppSizes.paddingM),
                      
                      _buildInfoRow('Email', user.email),
                      _buildInfoRow('NRP', user.nrp),
                      if (user.statusPersonel != null)
                        _buildInfoRow('Status Personel', user.statusPersonel!),
                      
                      // Personal Information Section
                      if (user.tempatLahir != null || user.dateOfBirth != null || user.agama != null)
                        ...[
                          const SizedBox(height: AppSizes.paddingL),
                          _buildSectionTitle('Data Personal'),
                          const SizedBox(height: AppSizes.paddingM),
                          
                          if (user.tempatTanggalLahir.isNotEmpty)
                            _buildInfoRow('Tempat, Tanggal Lahir', user.tempatTanggalLahir),
                          if (user.dateOfBirth != null)
                            _buildInfoRow('Umur', '${user.age} tahun'),
                          if (user.agama != null)
                            _buildInfoRow('Agama', user.agama!),
                          if (user.suku != null)
                            _buildInfoRow('Suku', user.suku!),
                          if (user.bloodType != null)
                            _buildInfoRow('Golongan Darah', user.bloodType!),
                          if (user.maritalStatus != null)
                            _buildInfoRow('Status Pernikahan', user.maritalStatus!),
                        ],
                      
                      // Military Service Information
                      if (user.militaryJoinDate != null)
                        ...[
                          const SizedBox(height: AppSizes.paddingL),
                          _buildSectionTitle('Data Dinas'),
                          const SizedBox(height: AppSizes.paddingM),
                          
                          _buildInfoRow('TMT Masuk Polri ', _formatDate(user.militaryJoinDate!)),
                          _buildInfoRow('Masa Dinas', '${user.yearsOfService} tahun'),
                          if (user.jabatanTmt != null)
                            _buildInfoRow('TMT Jabatan', user.formattedJabatanTmt),
                          if (user.jabatanTmt != null)
                            _buildInfoRow('Lama Jabatan', user.lamaJabatan),
                        ],
                      
                      // Contact Information
                      if (user.phoneNumber != null || user.address != null || user.emergencyContact != null)
                        ...[
                          const SizedBox(height: AppSizes.paddingL),
                          _buildSectionTitle('Informasi Kontak'),
                          const SizedBox(height: AppSizes.paddingM),
                          
                          if (user.phoneNumber != null)
                            _buildInfoRow('Telepon', user.phoneNumber!),
                          if (user.address != null)
                            _buildInfoRow('Alamat', user.address!),
                          if (user.emergencyContact != null)
                            _buildInfoRow('Kontak Darurat', user.emergencyContact!),
                        ],
                      
                      // System Information
                      const SizedBox(height: AppSizes.paddingL),
                      _buildSectionTitle('Status Pendaftaran'),
                      const SizedBox(height: AppSizes.paddingM),
                      
                      _buildInfoRow('Tanggal Daftar', _formatDate(user.createdAt)),
                      
                      const SizedBox(height: AppSizes.paddingL),
                      
                      // Status Badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingL,
                          vertical: AppSizes.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.goldYellow.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: AppColors.goldYellow.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Expanded(
                              child: Text(
                                'Status: ${user.status.displayName}',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Data Completeness Info
                      const SizedBox(height: AppSizes.paddingM),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryBlue,
                              size: 18,
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Expanded(
                              child: Text(
                                'Data yang kosong dapat dilengkapi setelah akun disetujui melalui menu profil.',
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
                
                const SizedBox(height: AppSizes.paddingXL),
                
                // Information Box
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.goldYellow,
                        size: 32,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'Informasi Penting',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        'Admin sedang memverifikasi data Anda. Proses ini biasanya memakan waktu 1-3 hari kerja. Anda akan menerima notifikasi melalui email setelah akun disetujui.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.paddingXL),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () => _authService.signOut(),
                        text: 'KELUAR',
                        backgroundColor: AppColors.white,
                        textColor: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          // Refresh the page or check status
                          Navigator.pushReplacementNamed(context, '/auth');
                        },
                        text: 'REFRESH',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppColors.darkNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}