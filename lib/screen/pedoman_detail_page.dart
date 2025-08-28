import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';

class PedomanDetailPage extends StatelessWidget {
  final String title;
  final String content; // Sekarang ini akan berisi path ke gambar
  final Color color;
  final IconData icon;
  final String assetPath;
  final bool isImageContent; // Flag untuk indicate content adalah gambar

  const PedomanDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
    required this.assetPath,
    this.isImageContent = true, // Default true untuk gambar
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailAssetImage(
    String assetPath, {
    required double width,
    required double height,
    required IconData fallbackIcon,
  }) {
    try {
      if (assetPath.endsWith('.svg')) {
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          placeholderBuilder: (context) =>
              Icon(fallbackIcon, size: width * 0.7, color: AppColors.white),
        );
      } else {
        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          color: AppColors.white,
          errorBuilder: (context, error, stackTrace) =>
              Icon(fallbackIcon, size: width * 0.7, color: AppColors.white),
        );
      }
    } catch (e) {
      return Icon(fallbackIcon, size: width * 0.7, color: AppColors.white);
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _buildDetailAssetImage(
                assetPath,
                width: 36,
                height: 36,
                fallbackIcon: icon,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Korbrimob Polri',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
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

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pedoman dan Doktrin',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content area
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildImageContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (!isImageContent) {
      // Fallback untuk text content jika diperlukan
      return Text(
        content,
        style: GoogleFonts.roboto(
          fontSize: 15,
          color: AppColors.darkNavy,
          height: 1.6,
        ),
      );
    }

    return Column(
      children: [
        // Image container with better styling
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              content,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: color.withOpacity(0.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Gambar tidak dapat dimuat',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mohon periksa file gambar',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Info footer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ketuk gambar untuk memperbesar tampilan',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.darkGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}