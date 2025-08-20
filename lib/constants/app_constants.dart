import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color policeBlue = Color(0xFF0F172A);
  static const Color goldYellow = Color(0xFFFCD34D);
  static const Color lightGold = Color(0xFFFEF3C7);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color darkGray = Color(0xFF64748B);
  static const Color white = Colors.white;
  static const Color red = Color(0xFFDC2626);
  static const Color green = Color(0xFF059669);
  static const Color orange = Color(0xFFEA580C);
  static const Color purple = Color(0xFF7C3AED);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color teal = Color(0xFF0D9488);
}

class AppSizes {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
}

class MenuData {
  static const List<Map<String, dynamic>> mainMenus = [
    {
      'id': 'korbrimob',
      'title': 'KORBRIMOB',
      'icon': '🛡️',
      'imageUrl': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=300&h=200&fit=crop',
      'color': Color(0xFFDC2626),
      'isProtected': false,
      'description': 'Korps Brigade Mobil',
    },
    {
      'id': 'binkar',
      'title': 'BINKAR',
      'icon': '👨‍💼',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=200&fit=crop',
      'color': Color(0xFF7C3AED),
      'isProtected': true,
      'description': 'Pembinaan Karir',
    },
    {
      'id': 'dalpers',
      'title': 'DALPERS',
      'icon': '🔍',
      'imageUrl': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=300&h=200&fit=crop',
      'color': Color(0xFFDC2626),
      'isProtected': false,
      'description': 'Dalam Personel',
    },
    {
      'id': 'watpers',
      'title': 'WATPERS',
      'icon': '👥',
      'imageUrl': 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=300&h=200&fit=crop',
      'color': Color(0xFF059669),
      'isProtected': false,
      'description': 'Pengawasan Personel',
    },
    {
      'id': 'psikologi',
      'title': 'PSIKOLOGI',
      'icon': '🧠',
      'imageUrl': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=200&fit=crop',
      'color': Color(0xFF0EA5E9),
      'isProtected': false,
      'description': 'Layanan Psikologi',
    },
    {
      'id': 'perdankor',
      'title': 'PERDANKOR',
      'icon': '⚖️',
      'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=300&h=200&fit=crop',
      'color': Color(0xFFDC2626),
      'isProtected': false,
      'description': 'Perdampingan Korps',
    },
    {
      'id': 'perkap',
      'title': 'PERKAP',
      'icon': '📋',
      'imageUrl': 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=300&h=200&fit=crop',
      'color': Color(0xFF059669),
      'isProtected': false,
      'description': 'Peraturan Kapolri',
    },
    {
      'id': 'other',
      'title': 'OTHER',
      'icon': '📂',
      'imageUrl': 'https://images.unsplash.com/photo-1553484771-cc0d9b8c2b33?w=300&h=200&fit=crop',
      'color': Color(0xFF0EA5E9),
      'isProtected': false,
      'description': 'Informasi Lainnya',
    },
  ];

  static const List<Map<String, String>> galeriSatuan = [
    {
      'id': 'mako_kor',
      'title': 'MAKO KOR',
      'subtitle': 'Markas Komando',
      'imageUrl': 'https://images.unsplash.com/photo-1582719371699-d0d1b0c93e7a?w=400&h=300&fit=crop',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Emblem_of_the_Indonesian_National_Police.svg/200px-Emblem_of_the_Indonesian_National_Police.svg.png',
    },
    {
      'id': 'pas_pelopor',
      'title': 'PAS PELOPOR',
      'subtitle': 'Pelopor',
      'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      'logoUrl': 'https://images.unsplash.com/photo-1582719371699-d0d1b0c93e7a?w=100&h=100&fit=crop',
    },
    {
      'id': 'pas_gegana',
      'title': 'PAS GEGANA',
      'subtitle': 'Gegana',
      'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'logoUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop',
    },
    {
      'id': 'pasbrimob_1',
      'title': 'PASBRIMOB I',
      'subtitle': 'Pasbrimob I',
      'imageUrl': 'https://images.unsplash.com/photo-1586892479147-8d35e7edc3e8?w=400&h=300&fit=crop',
      'logoUrl': 'https://images.unsplash.com/photo-1586892479147-8d35e7edc3e8?w=100&h=100&fit=crop',
    },
    {
      'id': 'pasbrimob_2',
      'title': 'PASBRIMOB II',
      'subtitle': 'Pasbrimob II',
      'imageUrl': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop',
      'logoUrl': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=100&h=100&fit=crop',
    },
    {
      'id': 'pasbrimob_3',
      'title': 'PASBRIMOB III',
      'subtitle': 'Pasbrimob III',
      'imageUrl': 'https://images.unsplash.com/photo-1560472355-536de3962603?w=400&h=300&fit=crop',
      'logoUrl': 'https://images.unsplash.com/photo-1560472355-536de3962603?w=100&h=100&fit=crop',
    },
  ];

  // Updated with 6 items sesuai banner - using local assets
  static const List<Map<String, String>> pedomanItems = [
    {
      'id': 'tri_brata',
      'title': 'TRI BRATA',
      'description': 'Tiga bakti utama anggota Polri',
      'assetPath': 'assets/tribrata.png',
    },
    {
      'id': 'catur_prasetya',
      'title': 'CATUR PRASETYA',
      'description': 'Empat janji setia anggota Polri',
      'assetPath': 'assets/tribrata.png',
    },
    {
      'id': 'panca_prasetya',
      'title': 'PANCA PRASETYA BRIMOB',
      'description': 'Lima sumpah setia Brimob',
      'assetPath': 'assets/brimob.png',
    },
    {
      'id': 'sapta_marga',
      'title': 'SAPTA MARGA BRIMOB',
      'description': 'Tujuh janji prajurit Brimob',
      'assetPath': 'assets/brimob.png',
    },
    {
      'id': 'asta_gatra',
      'title': 'ASTA GATRA BRIMOB',
      'description': 'Delapan unsur kekuatan nasional',
      'assetPath': 'assets/brimob.png',
    },
    {
      'id': 'pancasila_prasetya',
      'title': 'PANCASILA PRASETYA',
      'description': 'Sumpah setia kepada Pancasila',
      'assetPath': 'assets/korpri.svg',
    },
  ];
}