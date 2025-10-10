import 'package:app_brimob_user/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'edit_profile_page.dart';

class ProfileSectionWidget extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onLogout;

  const ProfileSectionWidget({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<ProfileSectionWidget> createState() => _ProfileSectionWidgetState();
}

class _ProfileSectionWidgetState extends State<ProfileSectionWidget> {
  late UserModel _currentUser;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.approved:
        return Colors.green;
      case UserStatus.pending:
        return Colors.orange;
      case UserStatus.rejected:
        return Colors.red;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.makoKor:
        return Colors.indigo;
      case UserRole.pasPelopor:
        return Colors.teal;
      case UserRole.pasGegana:
        return Colors.deepOrange;
      case UserRole.pasbrimobI:
        return Colors.blue;
      case UserRole.pasbrimobII:
        return Colors.green;
      case UserRole.pasbrimobIII:
        return Colors.amber;
      case UserRole.other:
        return Colors.grey;
    }
  }

  Map<String, int> _calculateRetirement() {
    final retirementAge = 58;
    final retirementDate = _currentUser.dateOfBirth?.add(
      Duration(days: retirementAge * 365),
    );

    if (retirementDate == null) {
      return {'years': 0, 'months': 0, 'days': 0};
    }

    final now = DateTime.now();
    if (now.isAfter(retirementDate)) {
      return {'years': 0, 'months': 0, 'days': 0};
    }

    int years = retirementDate.year - now.year;
    int months = retirementDate.month - now.month;
    int days = retirementDate.day - now.day;

    if (days < 0) {
      months--;
      days += DateTime(retirementDate.year, retirementDate.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentUser: _currentUser),
      ),
    );

    if (result != null) {
      setState(() {
        _currentUser = result;
      });
    }
  }

  void _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdfData = await PdfService.generateCvPdf(_currentUser);
      final fileName =
          'CV_${_currentUser.fullName.replaceAll(' ', '_')}_${_currentUser.nrp}.pdf';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'CV ${_currentUser.fullName} - ${_currentUser.nrp}',
        subject: 'Curriculum Vitae',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('CV siap dibagikan!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gagal membuat CV: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text('Konfirmasi Keluar'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retirement = _calculateRetirement();

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3440), Color(0xFF3B4252)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: Colors.white.withOpacity(0.9),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'PROFIL SAYA',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_currentUser.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentUser.status.displayName,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile Content
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar dan Info Utama
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child:
                          _currentUser.photoUrl != null
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _currentUser.photoUrl!,
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                  placeholder:
                                      (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.grey[400],
                                        child: Icon(
                                          Icons.person,
                                          size: 45,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 45,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                    ),

                    const SizedBox(width: 16),

                    // Info Utama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser.displayName,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Satuan Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(_currentUser.role),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _currentUser.role.displayName,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'NRP: ${_currentUser.nrp}',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (_currentUser.jabatan.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _currentUser.jabatan,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Usia',
                        '${_currentUser.age} tahun',
                        Icons.cake,
                        Colors.blue[400]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Masa Dinas',
                        '${_currentUser.yearsOfService} tahun',
                        Icons.military_tech,
                        Colors.green[400]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Lama Jabatan',
                        _currentUser.lamaJabatan.split(' ').take(2).join(' '),
                        Icons.work_history,
                        Colors.orange[400]!,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Masa Pensiun Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[400]!, Colors.red[600]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.event_available,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MASA PENSIUN',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${retirement['years']} TAHUN, ${retirement['months']} BULAN, ${retirement['days']} HARI',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Detail Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Email', _currentUser.email, Icons.email),
                      _buildDetailRow(
                        'Tempat, Tgl Lahir',
                        _currentUser.tempatTanggalLahir,
                        Icons.place,
                      ),
                      _buildDetailRow(
                        'Agama',
                        _currentUser.agama,
                        Icons.mosque,
                      ),
                      _buildDetailRow(
                        'Golongan Darah',
                        _currentUser.bloodType,
                        Icons.bloodtype,
                      ),
                      _buildDetailRow(
                        'Status Pernikahan',
                        _currentUser.maritalStatus,
                        Icons.family_restroom,
                      ),
                      _buildDetailRow(
                        'Telepon',
                        _currentUser.phoneNumber,
                        Icons.phone,
                      ),
                      _buildDetailRow(
                        'Alamat',
                        _currentUser.address,
                        Icons.home,
                      ),
                      _buildDetailRow(
                        'Kontak Darurat',
                        _currentUser.emergencyContact,
                        Icons.contact_emergency,
                      ),
                      if (_currentUser.militaryJoinDate != null)
                        _buildDetailRow(
                          'Bergabung',
                          _currentUser.formattedMilitaryJoinDate,
                          Icons.date_range,
                        ),
                      if (_currentUser.dateOfBirth != null)
                        _buildDetailRow(
                          'Masa Pensiun',
                          '${retirement['years']} Tahun, ${retirement['months']} Bulan, ${retirement['days']} Hari',
                          Icons.event_available,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Column(
                  children: [
                    // Export CV Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportToPdf,
                        icon:
                            _isExporting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.share, size: 20),
                        label: Text(
                          _isExporting ? 'Menyiapkan...' : 'CETAK DRH',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEditProfile,
                        icon: const Icon(Icons.edit, size: 20),
                        label: Text(
                          'Edit Data Diri',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutConfirmation,
                        icon: const Icon(Icons.logout, size: 20),
                        label: Text(
                          'Keluar dari Aplikasi',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[400],
                          side: BorderSide(color: Colors.red[400]!, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
