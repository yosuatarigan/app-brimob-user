import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';

class PedomanPage extends StatefulWidget {
  const PedomanPage({super.key});

  @override
  State<PedomanPage> createState() => _PedomanPageState();
}

class _PedomanPageState extends State<PedomanPage> {
  Map<String, String> _pedomanContent = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPedoman();
  }

  Future<void> _loadPedoman() async {
    setState(() => _isLoading = true);
    
    try {
      // Load from Firebase or use default content
      final triBrata = await FirebaseService.getSettings('tri_brata') ?? 
          {'content': _getDefaultTriBrata()};
      final falsafah = await FirebaseService.getSettings('falsafah') ?? 
          {'content': _getDefaultFalsafah()};
      final doktrin = await FirebaseService.getSettings('doktrin') ?? 
          {'content': _getDefaultDoktrin()};
      
      setState(() {
        _pedomanContent = {
          'tri_brata': triBrata['content'] ?? _getDefaultTriBrata(),
          'falsafah': falsafah['content'] ?? _getDefaultFalsafah(),
          'doktrin': doktrin['content'] ?? _getDefaultDoktrin(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _pedomanContent = {
          'tri_brata': _getDefaultTriBrata(),
          'falsafah': _getDefaultFalsafah(),
          'doktrin': _getDefaultDoktrin(),
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          'Pedoman, Falsafah & Doktrin',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadPedoman,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadPedoman,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingL),
            ...MenuData.pedomanItems.map((item) => 
              _buildPedomanCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Stack(
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&h=300&fit=crop',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.darkNavy],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.darkNavy],
                  ),
                ),
              ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.8),
                    AppColors.darkNavy.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pedoman, Falsafah dan Doktrin',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          'Landasan filosofis dan operasional Korbrimob Polri dalam menjalankan tugas dan tanggung jawab',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppColors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedomanCard(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: InkWell(
          onTap: () => _showPedomanDetail(item),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getPedomanColor(item['id']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: _getPedomanColor(item['id']!).withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    _getPedomanIcon(item['id']!),
                    color: _getPedomanColor(item['id']!),
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      Text(
                        item['description']!,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: AppColors.darkGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.darkGray.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPedomanDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PedomanDetailPage(
          title: item['title']!,
          content: _pedomanContent[item['id']!] ?? 'Konten sedang dalam pengembangan.',
          color: _getPedomanColor(item['id']!),
          icon: _getPedomanIcon(item['id']!),
        ),
      ),
    );
  }

  Color _getPedomanColor(String id) {
    switch (id) {
      case 'tri_brata':
        return AppColors.primaryBlue;
      case 'falsafah':
        return AppColors.red;
      case 'doktrin':
        return AppColors.green;
      default:
        return AppColors.darkGray;
    }
  }

  IconData _getPedomanIcon(String id) {
    switch (id) {
      case 'tri_brata':
        return Icons.star;
      case 'falsafah':
        return Icons.psychology;
      case 'doktrin':
        return Icons.library_books;
      default:
        return Icons.book;
    }
  }

  String _getDefaultTriBrata() {
    return '''
TRI BRATA

1. RASTRA SEWAKOTTAMA
   Kami Anggota Polri berjanji akan mengabdikan diri dalam perjuangan menyelenggarakan keamanan dalam negeri, memelihara ketertiban masyarakat, menegakkan hukum dan keadilan, melindungi, mengayomi dan melayani masyarakat serta berbakti kepada nusa dan bangsa.

2. ADHI UPAYA BRIKET DHARMA
   Kami Anggota Polri berjanji akan mengutamakan kepentingan masyarakat, bangsa dan negara, akan taat dan patuh pada atasan, akan menggunakan kekuatan kami secara bijaksana, berperikemanusiaan dan tidak mengguna-kan kekuatan kami demi kepentingan pribadi.

3. TRIBRATA EKA DHARMA
   Kami Anggota Polri berjanji akan berbakti dengan sepenuh jiwa raga, akan jujur dan dapat dipercaya, akan taat pada janji dan peraturan dinas, serta akan rela berkorban demi keselamatan nusa dan bangsa.
''';
  }

  String _getDefaultFalsafah() {
    return '''
FALSAFAH KORBRIMOB POLRI

Korbrimob Polri sebagai bagian integral dari Polri memiliki falsafah yang mengakar pada nilai-nilai Pancasila dan UUD 1945.

NILAI-NILAI DASAR:
• Ketuhanan Yang Maha Esa
• Kemanusiaan yang adil dan beradab
• Persatuan Indonesia
• Kerakyatan yang dipimpin oleh hikmat kebijaksanaan dalam permusyawaratan/perwakilan
• Keadilan sosial bagi seluruh rakyat Indonesia

PRINSIP OPERASIONAL:
• Melindungi, mengayomi, dan melayani masyarakat
• Menegakkan supremasi hukum
• Memelihara kamtibmas
• Profesional dan proporsional dalam setiap tindakan
''';
  }

  String _getDefaultDoktrin() {
    return '''
DOKTRIN KORBRIMOB POLRI

Doktrin Korbrimob Polri merupakan panduan fundamental dalam pelaksanaan tugas dan fungsi sebagai pasukan elite Polri.

TUGAS POKOK:
1. Pengendalian massa/kerusuhan
2. Pemberantasan terorisme
3. Pengamanan objek vital
4. Operasi khusus kepolisian
5. Bantuan SAR

PRINSIP OPERASI:
• Kesiapsiagaan tinggi
• Mobilitas cepat
• Fleksibilitas taktis
• Koordinasi terpadu
• Teknologi modern

MOTTO:
"JIWA DHARMA KARTIKA"
Jiwa pengabdian yang mengutamakan dharma dan kebenaran dalam setiap tindakan demi kepentingan bangsa dan negara.
''';
  }
}

class PedomanDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final IconData icon;

  const PedomanDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: color,
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXL),
          bottomRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXL),
          bottomRight: Radius.circular(AppSizes.radiusXL),
        ),
        child: Stack(
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&h=300&fit=crop',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: color),
              errorWidget: (context, url, error) => Container(color: color),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: AppColors.darkNavy,
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}