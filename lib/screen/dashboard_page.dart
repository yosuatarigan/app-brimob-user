import 'package:app_brimob_user/slide_show_model.dart';
import 'package:app_brimob_user/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';
import 'login_page.dart';
import 'content_page.dart';
import 'galeri_page.dart';
import 'pedoman_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  
  // Slideshow variables
  final PageController _pageController = PageController();
  List<SlideshowItem> _slideshowImages = [];
  int _currentSlide = 0;
  bool _isLoadingSlideshow = true;

  @override
  void initState() {
    super.initState();
    _loadSlideshowImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSlideshowImages() async {
    try {
      setState(() => _isLoadingSlideshow = true);
      final images = await FirebaseService.getSlideshowImages();
      setState(() {
        _slideshowImages = images;
        _isLoadingSlideshow = false;
      });
      
      // Start auto-slide if images are available
      if (_slideshowImages.isNotEmpty) {
        _startAutoSlide();
      }
    } catch (e) {
      print('Error loading slideshow images: $e');
      setState(() => _isLoadingSlideshow = false);
      // Use default image if loading fails
      _slideshowImages = [
        SlideshowItem(
          id: 'default',
          imageUrl: 'assets/head.png',
          isActive: true,
          order: 0,
        ),
      ];
      _startAutoSlide(); // Start auto-slide even with default image
    }
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _slideshowImages.length > 1) {
        final nextSlide = (_currentSlide + 1) % _slideshowImages.length;
        _pageController.animateToPage(
          nextSlide,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSlide(); // Continue auto-slide
      } else if (mounted && _slideshowImages.length == 1) {
        // Even with single image, restart the timer for consistency
        _startAutoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSlideshowHeader(),
                _buildGaleriSatuan(),
                _buildMenuGrid(),
                const SizedBox(height: AppSizes.paddingXL),
                _buildPedomanSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlideshowHeader() {
    if (_isLoadingSlideshow) {
      return Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6D4C41),
              AppColors.primaryBlue,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Slideshow...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_slideshowImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        color: AppColors.primaryBlue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library,
                color: Colors.white.withOpacity(0.7),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No Slideshow Images Available',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Contact administrator to add slideshow images',
                style: GoogleFonts.roboto(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      child: Stack(
        children: [
          // PageView for slideshow
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: _slideshowImages.length,
            itemBuilder: (context, index) {
              final slide = _slideshowImages[index];
              return _buildSlideItem(slide);
            },
          ),
          
          // Dots indicator (only show if more than 1 image)
          if (_slideshowImages.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slideshowImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentSlide == index ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentSlide == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      boxShadow: _currentSlide == index
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          
          // Navigation arrows (only show if more than 1 image)
          if (_slideshowImages.length > 1) ...[
            // Previous button
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    final prevSlide = _currentSlide == 0 
                        ? _slideshowImages.length - 1 
                        : _currentSlide - 1;
                    _pageController.animateToPage(
                      prevSlide,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            
            // Next button
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    final nextSlide = (_currentSlide + 1) % _slideshowImages.length;
                    _pageController.animateToPage(
                      nextSlide,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Slide counter (top right)
          if (_slideshowImages.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentSlide + 1} / ${_slideshowImages.length}',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlideItem(SlideshowItem slide) {
    return Container(
      width: double.infinity,
      height: 250,
      child: slide.imageUrl.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: slide.imageUrl,
              fit: BoxFit.fill,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      const Color(0xFF6D4C41),
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Loading image...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.primaryBlue,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white.withOpacity(0.7),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load image',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Image.asset(
              slide.imageUrl,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryBlue,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.white.withOpacity(0.7),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SDM Korbrimob Polri',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sistem Data Manajemen',
                          style: GoogleFonts.roboto(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Keep all other existing methods unchanged
  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGaleriSatuan() {
    final List<Map<String, dynamic>> galeriItems = [
      {
        'id': 'mako_kor',
        'name': 'MAKO KOR',
        'color': const Color(0xFF1565C0),
        'logo': 'assets/brimob.png',
      },
      {
        'id': 'pas_pelopor',
        'name': 'PAS PELOPOR',
        'color': const Color(0xFFD32F2F),
        'logo': 'assets/paspelopor.jpg',
      },
      {
        'id': 'pas_gegana',
        'name': 'PAS GEGANA',
        'color': const Color(0xFF388E3C),
        'logo': 'assets/gegana.jpg',
      },
      {
        'id': 'pasbrimob_i',
        'name': 'PASBRIMOB I',
        'color': const Color(0xFFF57C00),
        'logo': 'assets/brimob.png',
      },
      {
        'id': 'pasbrimob_ii',
        'name': 'PASBRIMOB II',
        'color': const Color(0xFF7B1FA2),
        'logo': 'assets/brimob.png',
      },
      {
        'id': 'pasbrimob_iii',
        'name': 'PASBRIMOB III',
        'color': const Color(0xFF00796B),
        'logo': 'assets/brimob.png',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'GALERI SATUAN',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 30,
              mainAxisSpacing: 0,
            ),
            itemCount: galeriItems.length,
            itemBuilder: (context, index) {
              final item = galeriItems[index];
              return _buildGaleriItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGaleriItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _navigateToGalleryCategory(item),
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              child: Image.asset(
                item['logo'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['name'],
              style: GoogleFonts.roboto(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'KORBRIMOB',
        'asset': 'assets/korbrimob.png',
        'id': 'korbrimob',
        'isProtected': false,
      },
      {
        'title': 'BINKAR',
        'asset': 'assets/binkar.png',
        'id': 'binkar',
        'isProtected': true,
      },
      {
        'title': 'DALPERS',
        'asset': 'assets/dalpers.png',
        'id': 'dalpers',
        'isProtected': false,
      },
      {
        'title': 'WATPERS',
        'asset': 'assets/watpress.png',
        'id': 'watpers',
        'isProtected': false,
      },
      {
        'title': 'PSIKOLOGI',
        'asset': 'assets/psikologi.png',
        'id': 'psikologi',
        'isProtected': false,
      },
      {
        'title': 'PERDANKOR',
        'asset': 'assets/perdankor.png',
        'id': 'perdankor',
        'isProtected': false,
      },
      {
        'title': 'PERKAP',
        'asset': 'assets/perkap.png',
        'id': 'perkap',
        'isProtected': false,
      },
      {
        'title': 'OTHER',
        'asset': 'assets/other.png',
        'id': 'other',
        'isProtected': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final menu = menuItems[index];
          return _buildMenuItem(
            title: menu['title']!,
            assetPath: menu['asset']!,
            onTap: () => _handleMenuTap(menu),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        print('Item tapped: $title');
        onTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedomanSection() {
    final List<Map<String, String>> pedomanItems = [
      {
        'title': 'Tri Brata',
        'description':
            'Pedoman hidup bagi setiap anggota Polri yang terdiri dari tiga bagian utama.',
        'id': 'tri_brata',
        'assetPath': 'assets/tribrata.png',
      },
      {
        'title': 'Catur Prasetya',
        'description':
            'Empat janji kerja anggota Polri dalam melaksanakan tugas kepolisian.',
        'id': 'catur_prasetya',
        'assetPath': 'assets/tribrata.png',
      },
      {
        'title': 'Panca Prasetya',
        'description':
            'Lima prinsip khusus untuk anggota Korps Brimob Polri sebagai pasukan elite.',
        'id': 'panca_prasetya',
        'assetPath': 'assets/brimob.png',
      },
      {
        'title': 'Sapta Marga',
        'description':
            'Tujuh pedoman hidup prajurit yang diadopti dalam lingkungan Brimob.',
        'id': 'sapta_marga',
        'assetPath': 'assets/brimob.png',
      },
      {
        'title': 'Asta Gatra',
        'description':
            'Delapan unsur kekuatan nasional sebagai dasar ketahanan nasional Indonesia.',
        'id': 'asta_gatra',
        'assetPath': 'assets/brimob.png',
      },
      {
        'title': 'Pancasila Prasetya',
        'description':
            'Sumpah setia kepada dasar negara Pancasila sebagai panduan moral dan etika.',
        'id': 'pancasila_prasetya',
        'assetPath': 'assets/korpri.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pedoman, Falsafah & Doktrin Korbrimob Polri'),
        const SizedBox(height: AppSizes.paddingM),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 32,
              mainAxisSpacing: 0,
            ),
            itemCount: pedomanItems.length,
            itemBuilder: (context, index) {
              final item = pedomanItems[index];
              return _buildPedomanItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPedomanItem(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _navigateToPedomanDetail(item),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getPedomanColor(item['id']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Image.asset(
                    item['assetPath']!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                item['title']!,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGalleryCategory(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryGalleryPage(category: category),
      ),
    );
  }

  void _navigateToPedomanDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PedomanDetailPage(
          title: item['title']!,
          content: _getPedomanContent(item['id']!),
          color: _getPedomanColor(item['id']!),
          icon: _getPedomanIcon(item['id']!),
          assetPath: item['assetPath']!,
        ),
      ),
    );
  }

  Color _getPedomanColor(String id) {
    switch (id) {
      case 'tri_brata':
        return AppColors.primaryBlue;
      case 'catur_prasetya':
        return AppColors.red;
      case 'panca_prasetya':
        return AppColors.green;
      case 'sapta_marga':
        return AppColors.orange;
      case 'asta_gatra':
        return AppColors.purple;
      case 'pancasila_prasetya':
        return AppColors.indigo;
      default:
        return AppColors.darkGray;
    }
  }

  IconData _getPedomanIcon(String id) {
    switch (id) {
      case 'tri_brata':
        return Icons.star;
      case 'catur_prasetya':
        return Icons.favorite;
      case 'panca_prasetya':
        return Icons.security;
      case 'sapta_marga':
        return Icons.military_tech;
      case 'asta_gatra':
        return Icons.account_balance;
      case 'pancasila_prasetya':
        return Icons.flag;
      default:
        return Icons.book;
    }
  }

  String _getPedomanContent(String id) {
    switch (id) {
      case 'tri_brata':
        return '''TRI BRATA

Tri Brata adalah pedoman hidup bagi setiap anggota Polri yang terdiri dari tiga bagian:

KAMI POLISI INDONESIA:

1. BERBAKTI KEPADA NUSA DAN BANGSA
   "Berbakti kepada nusa dan bangsa dengan penuh ketakwaan terhadap Tuhan Yang Maha Esa."

2. MENJUNJUNG TINGGI KEBENARAN, KEADILAN, DAN KEMANUSIAAN  
   "Menjunjung tinggi kebenaran, keadilan, dan kemanusiaan dalam menegakkan hukum Negara Kesatuan Republik Indonesia yang berdasarkan Pancasila dan Undang-Undang Dasar 1945."

3. MELINDUNGI, MENGAYOMI, DAN MELAYANI MASYARAKAT
   "Senantiasa melindungi, mengayomi, dan melayani masyarakat dengan keikhlasan untuk mewujudkan keamanan dan ketertiban."

Tri Brata pertama kali diucapkan dalam prosesi wisuda keserjanaan PTIK angkatan II tanggal 3 Mei 1954, kemudian diresmikan sebagai pedoman hidup Polri pada tanggal 1 Juli 1955.''';

      case 'catur_prasetya':
        return '''CATUR PRASETYA

Catur Prasetya adalah empat janji kerja anggota Polri dalam melaksanakan tugas:

SEBAGAI INSAN BHAYANGKARA, KEHORMATAN SAYA ADALAH BERKORBAN DEMI MASYARAKAT, BANGSA DAN NEGARA UNTUK:

1. MENIADAKAN SEGALA BENTUK GANGGUAN KEAMANAN
2. MENJAGA KESELAMATAN JIWA RAGA, HARTA BENDA, DAN HAK ASASI MANUSIA
3. MENJAMIN KEPASTIAN BERDASARKAN HUKUM
4. MEMELIHARA PERASAAN TENTRAM DAN DAMAI''';

      case 'panca_prasetya':
        return '''PANCA PRASETYA KORBRIMOB

Lima prinsip khusus untuk anggota Korps Brimob Polri sebagai pasukan elite:

1. JIWA KORSA YANG TINGGI
2. DISIPLIN TINGGI  
3. PROFESIONALISME
4. LOYALITAS TOTAL
5. PENGABDIAN DHARMA KARTIKA''';

      case 'sapta_marga':
        return '''SAPTA MARGA

Tujuh pedoman hidup prajurit yang juga diadopsi dalam lingkungan Brimob:

1. KAMI WARGA NEGARA KESATUAN REPUBLIK INDONESIA YANG BERSENDIKAN PANCASILA
2. KAMI PATRIOT INDONESIA PENDUKUNG SERTA PEMBELA IDEOLOGI NEGARA
3. KAMI KESATRIA INDONESIA YANG BERTAQWA KEPADA TUHAN YANG MAHA ESA
4. KAMI PRAJURIT TENTARA NASIONAL INDONESIA ADALAH BHAYANGKARI NEGARA
5. KAMI PRAJURIT TENTARA NASIONAL INDONESIA MEMEGANG TEGUH DISIPLIN
6. KAMI PRAJURIT TENTARA NASIONAL INDONESIA MENGUTAMAKAN PERSATUAN
7. KAMI PRAJURIT TENTARA NASIONAL INDONESIA SADAR AKAN TANGGUNG JAWAB''';

      case 'asta_gatra':
        return '''ASTA GATRA

Delapan unsur kekuatan nasional yang menjadi dasar ketahanan nasional Indonesia:

TRI GATRA (ASPEK ALAMIAH):
1. GATRA GEOGRAFI
2. GATRA DEMOGRAFI  
3. GATRA SUMBER KEKAYAAN ALAM

PANCA GATRA (ASPEK SOSIAL):
4. GATRA IDEOLOGI
5. GATRA POLITIK
6. GATRA EKONOMI
7. GATRA SOSIAL BUDAYA
8. GATRA PERTAHANAN KEAMANAN (HANKAM)''';

      case 'pancasila_prasetya':
        return '''PANCASILA PRASETYA

Sumpah setia kepada dasar negara Pancasila sebagai panduan moral dan etika:

1. KETUHANAN YANG MAHA ESA
2. KEMANUSIAAN YANG ADIL DAN BERADAB
3. PERSATUAN INDONESIA
4. KERAKYATAN YANG DIPIMPIN OLEH HIKMAT KEBIJAKSANAAN
5. KEADILAN SOSIAL BAGI SELURUH RAKYAT INDONESIA''';

      default:
        return 'Konten sedang dalam pengembangan.';
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await _loadSlideshowImages(); // Refresh slideshow images
    setState(() => _isLoading = false);
  }

  Future<void> _handleMenuTap(Map<String, dynamic> menu) async {
    print('Menu tapped: ${menu['id']}');

    bool isProtected = menu['isProtected'] ?? false;

    if (isProtected) {
      if (FirebaseService.isLoggedIn) {
        final hasAccess = await FirebaseService.hasAccessToBinkar();
        if (hasAccess) {
          _navigateToContent(menu['id']);
        } else {
          _showAccessDeniedDialog();
        }
      } else {
        _navigateToLogin(menu['id']);
      }
    } else {
      _navigateToContent(menu['id']);
    }
  }

  void _navigateToLogin(String targetMenu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(targetMenu: targetMenu),
      ),
    );
  }

  void _navigateToContent(String menuId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContentPage(category: menuId)),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Akses Ditolak'),
        content: const Text(
          'Anda tidak memiliki akses ke menu BINKAR. Silakan hubungi administrator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}