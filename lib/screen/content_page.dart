import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../models/content_model.dart';
import '../services/firebase_service.dart';

class ContentPage extends StatefulWidget {
  final String category;

  const ContentPage({super.key, required this.category});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  ContentModel? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final content = await FirebaseService.getContentByCategory(widget.category);
      
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuTitle = _getMenuTitle(widget.category);
    final menuColor = _getMenuColor(widget.category);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: menuColor,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          menuTitle,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadContent,
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

    if (_error != null) {
      return _buildErrorState();
    }

    if (_content == null) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
    final menuColor = _getMenuColor(widget.category);
    final menuData = _getMenuData(widget.category);
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: menuColor,
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
            if (menuData['imageUrl'] != null)
              CachedNetworkImage(
                imageUrl: menuData['imageUrl'],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: menuColor),
                errorWidget: (context, url, error) => Container(color: menuColor),
              ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    menuColor.withOpacity(0.8),
                    menuColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Text(
                          _getMenuIcon(widget.category),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _content?.title ?? _getMenuTitle(widget.category),
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingXS),
                            Text(
                              menuData['description'] ?? 'Informasi ${_getMenuTitle(widget.category)}',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_content?.updatedAt != null) ...[
                    const SizedBox(height: AppSizes.paddingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Terakhir diupdate: ${_formatDate(_content!.updatedAt)}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_content!.images.isNotEmpty) ...[
            _buildImageGallery(),
            const SizedBox(height: AppSizes.paddingL),
          ],
          _buildTextContent(),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Galeri',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _content!.images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _content!.images.length - 1 ? AppSizes.paddingM : 0,
                ),
                child: _buildImageCard(_content!.images[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return GestureDetector(
      onTap: () => _showImageDialog(imageUrl),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.lightGray,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.lightGray,
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            if (_content!.content.isNotEmpty)
              Html(
                data: _content!.content,
                style: {
                  "body": Style(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontSize: FontSize(16),
                    lineHeight: const LineHeight(1.6),
                    color: AppColors.darkNavy,
                  ),
                  "h1, h2, h3": Style(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.bold,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                },
              )
            else
              Text(
                'Informasi untuk ${_getMenuTitle(widget.category)} akan segera tersedia.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: AppColors.darkGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.red,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Terjadi Kesalahan',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            ElevatedButton(
              onPressed: _loadContent,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
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
              Icons.info_outline,
              size: 64,
              color: AppColors.darkGray,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              'Konten Belum Tersedia',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Informasi untuk ${_getMenuTitle(widget.category)} sedang dalam proses pengembangan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  String _getMenuTitle(String category) {
    final menu = MenuData.mainMenus.firstWhere(
      (menu) => menu['id'] == category,
      orElse: () => {'title': category.toUpperCase()},
    );
    return menu['title'];
  }

  Map<String, dynamic> _getMenuData(String category) {
    return MenuData.mainMenus.firstWhere(
      (menu) => menu['id'] == category,
      orElse: () => {
        'title': category.toUpperCase(),
        'color': AppColors.primaryBlue,
        'icon': '📋',
        'imageUrl': null,
        'description': null,
      },
    );
  }

  Color _getMenuColor(String category) {
    final menu = MenuData.mainMenus.firstWhere(
      (menu) => menu['id'] == category,
      orElse: () => {'color': AppColors.primaryBlue},
    );
    return menu['color'];
  }

  String _getMenuIcon(String category) {
    final menu = MenuData.mainMenus.firstWhere(
      (menu) => menu['id'] == category,
      orElse: () => {'icon': '📋'},
    );
    return menu['icon'];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}