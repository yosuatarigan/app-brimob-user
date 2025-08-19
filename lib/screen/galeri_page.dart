import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../models/content_model.dart';
import '../services/firebase_service.dart';

class GaleriPage extends StatefulWidget {
  const GaleriPage({super.key});

  @override
  State<GaleriPage> createState() => _GaleriPageState();
}

class _GaleriPageState extends State<GaleriPage> {
  List<GaleriModel> _galeriList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGaleri();
  }

  Future<void> _loadGaleri() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final galeriList = await FirebaseService.getGaleriSatuan();
      
      setState(() {
        _galeriList = galeriList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Use dummy data if Firebase fails
        _galeriList = _getDummyGaleri();
      });
    }
  }

  List<GaleriModel> _getDummyGaleri() {
    return MenuData.galeriSatuan.map((item) => 
      GaleriModel(
        id: item['id']!,
        name: item['title']!,
        description: item['subtitle']!,
        images: [item['imageUrl']!],
        order: MenuData.galeriSatuan.indexOf(item),
        logoUrl: item['logoUrl']!,
      )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          'Galeri Satuan',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadGaleri,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_galeriList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGaleri,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingL),
            _buildGaleriGrid(),
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
              imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=300&fit=crop',
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
                      Icons.photo_library,
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
                          'Galeri Satuan',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          'Dokumentasi kegiatan dan informasi berbagai satuan di lingkungan Korbrimob Polri',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
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

  Widget _buildGaleriGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
      ),
      itemCount: _galeriList.length,
      itemBuilder: (context, index) {
        final galeri = _galeriList[index];
        return _buildGaleriCard(galeri);
      },
    );
  }

  Widget _buildGaleriCard(GaleriModel galeri) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: () => _showGaleriDetail(galeri),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Logo area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getSatuanColor(galeri.id),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusM),
                    topRight: Radius.circular(AppSizes.radiusM),
                  ),
                ),
                child: galeri.logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.radiusM),
                          topRight: Radius.circular(AppSizes.radiusM),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: galeri.logoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildPlaceholder(galeri),
                          errorWidget: (context, url, error) => _buildPlaceholder(galeri),
                        ),
                      )
                    : _buildPlaceholder(galeri),
              ),
            ),
            
            // Content area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          galeri.name,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        Text(
                          galeri.description,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppColors.darkGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    // View button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Lihat Detail',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(GaleriModel galeri) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _getSatuanColor(galeri.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield,
            size: 40,
            color: AppColors.white.withOpacity(0.8),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            galeri.name,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.darkGray,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Galeri Kosong',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Belum ada galeri satuan yang tersedia',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            ElevatedButton(
              onPressed: _loadGaleri,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGaleriDetail(GaleriModel galeri) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXL),
              topRight: Radius.circular(AppSizes.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppSizes.paddingM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.paddingL),
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
                              color: _getSatuanColor(galeri.id),
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                            child: const Icon(
                              Icons.shield,
                              color: AppColors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  galeri.name,
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                                Text(
                                  galeri.description,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSizes.paddingXL),
                      
                      // Content placeholder
                      Text(
                        'Informasi Satuan',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'Informasi detail tentang ${galeri.name} akan segera tersedia. Silakan cek kembali nanti untuk update terbaru.',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.darkGray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSatuanColor(String id) {
    switch (id) {
      case 'mako_kor':
        return AppColors.primaryBlue;
      case 'pas_pelopor':
        return AppColors.red;
      case 'pas_gegana':
        return AppColors.green;
      case 'pasbrimob_1':
        return const Color(0xFF7C3AED);
      case 'pasbrimob_2':
        return const Color(0xFFEA580C);
      case 'pasbrimob_3':
        return const Color(0xFF0EA5E9);
      default:
        return AppColors.darkGray;
    }
  }
}