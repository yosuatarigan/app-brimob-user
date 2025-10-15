import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Updated sesuai dengan yang ada
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color policeBlue = Color(0xFF0F172A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightBlue = Color(0xFF3E7BC7);

  // Secondary Colors
  static const Color goldYellow = Color(0xFFFCD34D);
  static const Color lightGold = Color(0xFFFEF3C7);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Color(0xFF000000);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color darkGray = Color(0xFF64748B);
  static const Color mediumGray = Color(0xFF9E9E9E);

  // Status Colors
  static const Color red = Color(0xFFDC2626);
  static const Color green = Color(0xFF059669);
  static const Color orange = Color(0xFFEA580C);
  static const Color purple = Color(0xFF7C3AED);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color teal = Color(0xFF0D9488);
  static const Color info = Color(0xFF0EA5E9);

  // Status Aliases
  static const Color success = green;
  static const Color warning = orange;
  static const Color error = red;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, darkNavy],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldYellow, lightGold],
  );
}

class AppSizes {
  // Padding - Extended
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 40.0;

  // Margin
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 24.0;
  static const double marginXL = 32.0;
  static const double marginXXL = 40.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Icon Sizes
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Font Sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontTitle = 24.0;
  static const double fontHeading = 28.0;
  static const double fontDisplay = 32.0;

  // Button Heights
  static const double buttonS = 36.0;
  static const double buttonM = 44.0;
  static const double buttonL = 52.0;

  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
}

class AppStrings {
  // App Info
  static const String appName = 'SDM KORBRIMOB';
  static const String appSubtitle = 'RORENMINOPS POLRI';
  static const String appAddress =
      'Jalan M. Yasin, Kel. Pasir Gn. Sel., Kec. Cimanggis\nKota Depok, Jawa Barat 16451';

  // Auth
  static const String login = 'MASUK';
  static const String register = 'DAFTAR';
  static const String logout = 'KELUAR';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String forgotPassword = 'Lupa Password?';

  // User Data
  static const String fullName = 'Nama Lengkap';
  static const String nrp = 'NRP (Nomor Registrasi Pokok)';
  static const String rank = 'Pangkat';
  static const String unit = 'Satuan';
  static const String dateOfBirth = 'Tanggal Lahir';
  static const String militaryJoinDate = 'TMT Masuk Polri ';

  // Status
  static const String pending = 'Menunggu Persetujuan';
  static const String approved = 'Disetujui';
  static const String rejected = 'Ditolak';

  // Messages
  static const String loadingApp = 'Memuat Aplikasi...';
  static const String waitingApproval = 'MENUNGGU PERSETUJUAN';
  static const String accountBeingVerified =
      'Akun Anda sedang diverifikasi oleh admin';

  // Validation Messages
  static const String fieldRequired = 'Field ini tidak boleh kosong';
  static const String invalidEmail = 'Format email tidak valid';
  static const String passwordTooShort = 'Password minimal 6 karakter';
  static const String passwordNotMatch = 'Password tidak sama';
  static const String nameTooShort = 'Nama minimal 3 karakter';
  static const String nrpTooShort = 'NRP minimal 8 digit';
}

class AppDurations {
  static const Duration splashDuration = Duration(seconds: 4);
  static const Duration animationShort = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 500);
  static const Duration animationLong = Duration(milliseconds: 800);
  static const Duration animationSlow = Duration(milliseconds: 1200);
}

class MenuData {
  static const List<Map<String, dynamic>> mainMenus = [
    {
      'id': 'korbrimob',
      'title': 'KORBRIMOB',
      'icon': '🛡️',
      'imageUrl':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=300&h=200&fit=crop',
      'color': AppColors.red,
      'isProtected': false,
      'description': 'Korps Brigade Mobil',
    },
    {
      'id': 'binkar',
      'title': 'BINKAR',
      'icon': '👨‍💼',
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=200&fit=crop',
      'color': AppColors.purple,
      'isProtected': true,
      'description': 'Pembinaan Karir',
    },
    {
      'id': 'dalpers',
      'title': 'DALPERS',
      'icon': '🔍',
      'imageUrl':
          'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=300&h=200&fit=crop',
      'color': AppColors.red,
      'isProtected': false,
      'description': 'Dalam Personel',
    },
    {
      'id': 'watpers',
      'title': 'WATPERS',
      'icon': '👥',
      'imageUrl':
          'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=300&h=200&fit=crop',
      'color': AppColors.green,
      'isProtected': false,
      'description': 'Pengawasan Personel',
    },
    {
      'id': 'psikologi',
      'title': 'PSIKOLOGI',
      'icon': '🧠',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=200&fit=crop',
      'color': AppColors.info,
      'isProtected': false,
      'description': 'Layanan Psikologi',
    },
    {
      'id': 'perdankor',
      'title': 'PERDANKOR',
      'icon': '⚖️',
      'imageUrl':
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=300&h=200&fit=crop',
      'color': AppColors.red,
      'isProtected': false,
      'description': 'Perdampingan Korps',
    },
    {
      'id': 'perkap',
      'title': 'PERKAP',
      'icon': '📋',
      'imageUrl':
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=300&h=200&fit=crop',
      'color': AppColors.green,
      'isProtected': false,
      'description': 'Peraturan Kapolri',
    },
    {
      'id': 'other',
      'title': 'OTHER',
      'icon': '📂',
      'imageUrl':
          'https://images.unsplash.com/photo-1553484771-cc0d9b8c2b33?w=300&h=200&fit=crop',
      'color': AppColors.info,
      'isProtected': false,
      'description': 'Informasi Lainnya',
    },
  ];

  static const List<Map<String, String>> galeriSatuan = [
    {
      'id': 'mako_kor',
      'title': 'MAKO KOR',
      'subtitle': 'Markas Komando',
      'imageUrl':
          'https://images.unsplash.com/photo-1582719371699-d0d1b0c93e7a?w=400&h=300&fit=crop',
      'logoUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Emblem_of_the_Indonesian_National_Police.svg/200px-Emblem_of_the_Indonesian_National_Police.svg.png',
    },
    {
      'id': 'pas_pelopor',
      'title': 'PAS PELOPOR',
      'subtitle': 'Pelopor',
      'imageUrl':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      'logoUrl':
          'https://images.unsplash.com/photo-1582719371699-d0d1b0c93e7a?w=100&h=100&fit=crop',
    },
    {
      'id': 'pas_gegana',
      'title': 'PAS GEGANA',
      'subtitle': 'Gegana',
      'imageUrl':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'logoUrl':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop',
    },
    {
      'id': 'pasbrimob_1',
      'title': 'PASBRIMOB I',
      'subtitle': 'Pasbrimob I',
      'imageUrl':
          'https://images.unsplash.com/photo-1586892479147-8d35e7edc3e8?w=400&h=300&fit=crop',
      'logoUrl':
          'https://images.unsplash.com/photo-1586892479147-8d35e7edc3e8?w=100&h=100&fit=crop',
    },
    {
      'id': 'pasbrimob_2',
      'title': 'PASBRIMOB II',
      'subtitle': 'Pasbrimob II',
      'imageUrl':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
      'logoUrl':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=100&h=100&fit=crop',
    },
    {
      'id': 'pasbrimob_3',
      'title': 'PASBRIMOB III',
      'subtitle': 'Pasbrimob III',
      'imageUrl':
          'https://images.unsplash.com/photo-1560472355-536de3962603?w=400&h=300&fit=crop',
      'logoUrl':
          'https://images.unsplash.com/photo-1560472355-536de3962603?w=100&h=100&fit=crop',
    },
  ];

  // Pedoman items dengan asset paths - disesuaikan dengan yang ada
  static const List<Map<String, String>> pedomanItems = [
    {
      'id': 'tri_brata',
      'title': 'TRI BRATA',
      'description': 'Tiga bakti utama anggota Polri',
      'assetPath': 'assets/images/tribrata.png',
      'icon': '⚡',
    },
    {
      'id': 'catur_prasetya',
      'title': 'CATUR PRASETYA',
      'description': 'Empat janji setia anggota Polri',
      'assetPath': 'assets/images/tribrata.png',
      'icon': '🤝',
    },
    {
      'id': 'panca_prasetya',
      'title': 'PANCA PRASETYA BRIMOB',
      'description': 'Lima sumpah setia Brimob',
      'assetPath': 'assets/images/brimob.png',
      'icon': '🛡️',
    },
    {
      'id': 'sapta_marga',
      'title': 'SAPTA MARGA BRIMOB',
      'description': 'Tujuh janji prajurit Brimob',
      'assetPath': 'assets/images/brimob.png',
      'icon': '⚔️',
    },
    {
      'id': 'asta_gatra',
      'title': 'ASTA GATRA BRIMOB',
      'description': 'Delapan unsur kekuatan nasional',
      'assetPath': 'assets/images/brimob.png',
      'icon': '🏛️',
    },
    {
      'id': 'pancasila_prasetya',
      'title': 'PANCASILA PRASETYA',
      'description': 'Sumpah setia kepada Pancasila',
      'assetPath': 'assets/images/korpri.svg',
      'icon': '🇮🇩',
    },
  ];

  // Rank data for dropdowns
  static const List<String> militaryRanks = [
    'BHARADA',
    'BHARATU',
    'BHARAKA',
    'ABRIPDA',
    'ABRIPTU',
    'ABRIP',
    'BRIPDA',
    'BRIPTU',
    'BRIGADIR',
    'BRIPKA',
    'AIPDA',
    'AIPTU',
    'IPDA',
    'IPTU',
    'AKP',
    'KOMPOL',
    'AKBP',
    'KOMBES',
    'BRIGJEN',
    'IRJEN',
    'KOMJEN',
  ];

  static const List<String> dikbangKepolisianList = [
    'SESPIMTI/SEDERAJAT',
    'SESPIMMEN/SEDERAJAT',
    'STIK-PTIK/SEDERAJAT',
    'SESPIMMA',
    'SIP',
    'SBP',
  ];

  // Additional data for forms
  static const List<String> bloodTypes = ['A', 'B', 'AB', 'O'];

  static const List<String> religions = [
    'Islam',
    'Kristen Protestan',
    'Kristen Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  static const List<String> maritalStatuses = [
    'Belum Menikah',
    'Menikah',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  static const List<String> educationLevels = [
    'SD',
    'SMP',
    'SMA/SMK',
    'D3',
    'S1',
    'S2',
    'S3',
  ];
}

// Quick access aliases
class AppAssets {
  static const String logoPolri =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Emblem_of_the_Indonesian_National_Police.svg/200px-Emblem_of_the_Indonesian_National_Police.svg.png';

  // Local assets paths
  static const String tribrata = 'assets/images/tribrata.png';
  static const String brimob = 'assets/images/brimob.png';
  static const String korpri = 'assets/images/korpri.svg';
}

// Theme helpers
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.lightGray,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
      ),
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.darkNavy,
    );
  }
}
