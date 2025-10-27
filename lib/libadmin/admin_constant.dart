import 'package:flutter/material.dart';

class AdminColors {
  // Primary admin colors - darker, more professional
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color adminDark = Color(0xFF0F172A);
  static const Color adminGold = Color(0xFFD97706);
  static const Color adminGreen = Color(0xFF059669);
  static const Color adminRed = Color(0xFFDC2626);
  static const Color adminPurple = Color(0xFF7C3AED);

  // UI Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF374151);
  static const Color lightGray = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);

  // Gradient colors
  static const List<Color> adminGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF3B82F6),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF0F172A),
    Color(0xFF1F2937),
  ];
}

class AdminSizes {
  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Icons
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Card heights
  static const double cardHeight = 120.0;
  static const double statsCardHeight = 140.0;
  static const double headerHeight = 200.0;
}

class AdminMenus {
  static const List<Map<String, dynamic>> dashboardStats = [
    {
      'id': 'total_content',
      'title': 'Total Konten',
      'icon': Icons.article,
      'color': AdminColors.adminGreen,
      'imageUrl':
          'https://images.unsplash.com/photo-1432888622747-4eb9a8efeb07?w=400&h=200&fit=crop',
    },
    {
      'id': 'total_users',
      'title': 'Total Users',
      'icon': Icons.people,
      'color': AdminColors.adminGreen,
      'imageUrl':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&h=200&fit=crop',
    },
    {
      'id': 'total_media',
      'title': 'Media Files',
      'icon': Icons.perm_media,
      'color': AdminColors.adminPurple,
      'imageUrl':
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=200&fit=crop',
    },
    {
      'id': 'storage_used',
      'title': 'Storage',
      'icon': Icons.storage,
      'color': AdminColors.adminGold,
      'imageUrl':
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400&h=200&fit=crop',
    },
  ];

  static List<Map<String, dynamic>> adminMenus = [
    {
      'id': 'content_management',
      'title': 'MENU UTAMA',
      'subtitle': 'Kelola konten aplikasi',
      'icon': Icons.edit_note,
      'color': AdminColors.primaryBlue,
      'imageUrl':
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&h=200&fit=crop',
      'route': '/content-management',
    },
    {
      'id': 'user_management',
      'title': 'ADMIN SDM',
      'subtitle': 'Kelola akun pengguna',
      'icon': Icons.manage_accounts,
      'color': AdminColors.adminGreen,
      'imageUrl':
          'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=200&fit=crop',
      'route': '/user-management',
    },
    {
      'id': 'send_notification',
      'title': 'ALARM PLB',
      'subtitle': 'Kirim notifikasi ke satuan',
      'icon': Icons.send,
      'color': AdminColors.adminRed,
      'imageUrl':
          'https://images.unsplash.com/photo-1553484771-371a605b060b?w=400&h=200&fit=crop',
      'route': '/send-notification',
    },
    {
      'id': 'notification_history',
      'title': 'ALARM PLB HISTORY',
      'subtitle': 'Lihat riwayat notifikasi',
      'icon': Icons.history,
      'color': AdminColors.adminRed,
      'imageUrl':
          'https://images.unsplash.com/photo-1553484771-371a605b060b?w=400&h=200&fit=crop',
      'route': '/notification-history',
    },
    {
      'id': 'gallery_management',
      'title': 'ADMIN HUMAS',
      'subtitle': 'Kelola galeri satuan',
      'icon': Icons.collections,
      'color': AdminColors.adminGold,
      'imageUrl':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=200&fit=crop',
      'route': '/gallery-management',
    },
    {
      'id': 'slideshow_management',
      'title': 'ADMIN SLIDESHOW',
      'subtitle': 'Kelola slideshow dashboard',
      'icon': Icons.slideshow,
      'color': AdminColors.adminPurple,
      'imageUrl': AdminImages.slideshowManagement,
    },
    {
      'id': 'alarm_naik_pangkat',
      'title': 'Alarm Naik Pangkat',
      'subtitle': 'Notifikasi Naik Pangkat',
      'icon': Icons.send,
      'color': AdminColors.adminPurple,
      'imageUrl': AdminImages.slideshowManagement,
    },
  ];

  static const List<Map<String, dynamic>> contentCategories = [
    {
      'id': 'korbrimob',
      'title': 'KORBRIMOB',
      'color': AdminColors.adminRed,
      'isPublic': true,
    },
    {
      'id': 'binkar',
      'title': 'BINKAR',
      'color': AdminColors.adminPurple,
      'isPublic': false,
    },
    {
      'id': 'dalpers',
      'title': 'DALPERS',
      'color': AdminColors.adminRed,
      'isPublic': true,
    },
    {
      'id': 'watpers',
      'title': 'WATPERS',
      'color': AdminColors.adminGreen,
      'isPublic': true,
    },
    {
      'id': 'psikologi',
      'title': 'PSIKOLOGI',
      'color': AdminColors.info,
      'isPublic': true,
    },
    {
      'id': 'perdankor',
      'title': 'PERDANKOR',
      'color': AdminColors.adminRed,
      'isPublic': true,
    },
    {
      'id': 'perkap',
      'title': 'PERKAP',
      'color': AdminColors.adminGreen,
      'isPublic': true,
    },
    {
      'id': 'other',
      'title': 'OTHER',
      'color': AdminColors.info,
      'isPublic': true,
    },
  ];
}

class AdminImages {
  // Admin specific images
  static const String adminDashboard =
      'https://images.unsplash.com/photo-1551434678-e076c223a692?w=800&h=400&fit=crop';
  static const String adminProfile =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop';
  static const String contentManagement =
      'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=800&h=400&fit=crop';
  static const String userManagement =
      'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop';
  static const String mediaLibrary =
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=400&fit=crop';
  static const String sendNotification =
      'https://images.unsplash.com/photo-1553484771-371a605b060b?w=800&h=400&fit=crop';
  static const String slideshowManagement =
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop';
  static const String analytics =
      'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=400&fit=crop';

  // Polri Logo
  static const String polriLogo =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Emblem_of_the_Indonesian_National_Police.svg/200px-Emblem_of_the_Indonesian_National_Police.svg.png';
}

class AdminTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AdminColors.adminDark,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AdminColors.adminDark,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AdminColors.adminDark,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AdminColors.darkGray,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AdminColors.darkGray,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AdminColors.lightGray,
  );
}
