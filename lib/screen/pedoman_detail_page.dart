import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';

class PedomanDetailPage extends StatelessWidget {
  final String title;
  final String content; // Sekarang ini akan berisi path ke gambar
  final IconData icon;
  final String assetPath;
  final bool isImageContent; // Flag untuk indicate content adalah gambar

  const PedomanDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.assetPath,
    this.isImageContent = true, // Default true untuk gambar
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // foregroundColor: AppColors.white,
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
            // _buildHeader(),
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
          placeholderBuilder: (context) =>
              Icon(fallbackIcon, size: width * 0.7, color: AppColors.white),
        );
      } else {
        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
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
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [color, color.withOpacity(0.8)],
        // ),
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
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Korbrimob Polri',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
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
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildImageContent(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (!isImageContent) {
      // Fallback untuk text content jika diperlukan
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: AppColors.darkNavy,
            height: 1.6,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      child: Image.asset(
        content,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 400,
            width: double.infinity,
            // color: color.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 64,
                  // color: color.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gambar tidak dapat dimuat',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    // color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
    );
  }
}