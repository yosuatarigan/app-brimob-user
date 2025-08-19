import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/models/admin_model.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/admin_firebase_service.dart';

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<MediaFile> _allMedia = [];
  List<MediaFile> _filteredMedia = [];
  bool _isLoading = true;
  String? _error;
  String _selectedType = 'all';
  String _searchQuery = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final media = await AdminFirebaseService.getAllMedia();
      
      setState(() {
        _allMedia = media;
        _filteredMedia = media;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMedia() {
    setState(() {
      _filteredMedia = _allMedia.where((media) {
        final matchesType = _selectedType == 'all' || media.fileType == _selectedType;
        final matchesSearch = media.fileName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             (media.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        return matchesType && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterSection(),
            _buildTabBar(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "upload",
            onPressed: _showUploadOptions,
            backgroundColor: AdminColors.primaryBlue,
            child: _isUploading 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.cloud_upload, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: "camera",
            onPressed: () => _pickMedia(ImageSource.camera),
            backgroundColor: AdminColors.adminGreen,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AdminColors.adminGradient,
        ),
      ),
      child: Stack(
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl: AdminImages.mediaLibrary,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AdminColors.adminGradient,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AdminColors.adminGradient,
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
                  AdminColors.primaryBlue.withOpacity(0.8),
                  AdminColors.adminDark.withOpacity(0.9),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AdminSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AdminSizes.paddingS),
                    Expanded(
                      child: Text(
                        'Media Library',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadMedia,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Kelola file dan media aplikasi',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AdminSizes.paddingS),
                Row(
                  children: [
                    _buildQuickStat('Total', '${_allMedia.length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Images', '${_allMedia.where((m) => m.fileType == 'image').length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Storage', _formatStorageSize()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminGold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AdminSizes.paddingM),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              _searchQuery = value;
              _filterMedia();
            },
            decoration: InputDecoration(
              hintText: 'Cari file...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                borderSide: BorderSide(color: AdminColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                borderSide: BorderSide(color: AdminColors.borderColor),
              ),
              filled: true,
              fillColor: AdminColors.background,
            ),
          ),
          
          const SizedBox(height: AdminSizes.paddingM),
          
          // File type filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeChip('all', 'Semua', Icons.folder),
                _buildTypeChip('image', 'Gambar', Icons.image),
                _buildTypeChip('video', 'Video', Icons.video_library),
                _buildTypeChip('pdf', 'PDF', Icons.picture_as_pdf),
                _buildTypeChip('document', 'Dokumen', Icons.description),
                _buildTypeChip('file', 'File', Icons.insert_drive_file),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String typeId, String title, IconData icon) {
    final isSelected = _selectedType == typeId;
    return Padding(
      padding: const EdgeInsets.only(right: AdminSizes.paddingS),
      child: FilterChip(
        avatar: Icon(icon, size: 16),
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = typeId;
          });
          _filterMedia();
        },
        backgroundColor: Colors.white,
        selectedColor: AdminColors.primaryBlue.withOpacity(0.1),
        checkmarkColor: AdminColors.primaryBlue,
        labelStyle: GoogleFonts.roboto(
          color: isSelected ? AdminColors.primaryBlue : AdminColors.darkGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AdminColors.primaryBlue : AdminColors.borderColor,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AdminColors.primaryBlue,
        unselectedLabelColor: AdminColors.darkGray,
        indicatorColor: AdminColors.primaryBlue,
        isScrollable: true,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'All Media'),
          Tab(text: 'Images'),
          Tab(text: 'Videos'),
          Tab(text: 'Documents'),
          Tab(text: 'Recent'),
        ],
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _filteredMedia = _allMedia;
                break;
              case 1:
                _filteredMedia = _allMedia.where((m) => m.fileType == 'image').toList();
                break;
              case 2:
                _filteredMedia = _allMedia.where((m) => m.fileType == 'video').toList();
                break;
              case 3:
                _filteredMedia = _allMedia.where((m) => m.fileType == 'pdf' || m.fileType == 'document').toList();
                break;
              case 4:
                _filteredMedia = _allMedia..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
                break;
            }
          });
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const AdminLoadingWidget(message: 'Memuat media...');
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Media',
        message: _error!,
        onRetry: _loadMedia,
      );
    }

    if (_filteredMedia.isEmpty) {
      return AdminEmptyState(
        icon: Icons.perm_media_outlined,
        title: 'Belum Ada Media',
        message: 'Upload file pertama untuk media library',
        actionText: 'Upload File',
        onAction: _showUploadOptions,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildMediaGrid(_filteredMedia),
        _buildMediaGrid(_allMedia.where((m) => m.fileType == 'image').toList()),
        _buildMediaGrid(_allMedia.where((m) => m.fileType == 'video').toList()),
        _buildMediaGrid(_allMedia.where((m) => m.fileType == 'pdf' || m.fileType == 'document').toList()),
        _buildMediaGrid(_allMedia..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt))),
      ],
    );
  }

  Widget _buildMediaGrid(List<MediaFile> media) {
    return RefreshIndicator(
      onRefresh: _loadMedia,
      child: GridView.builder(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: AdminSizes.paddingM,
          mainAxisSpacing: AdminSizes.paddingM,
        ),
        itemCount: media.length,
        itemBuilder: (context, index) {
          final mediaFile = media[index];
          return _buildMediaCard(mediaFile);
        },
      ),
    );
  }

  Widget _buildMediaCard(MediaFile media) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: InkWell(
        onTap: () => _showMediaDetail(media),
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getFileTypeColor(media.fileType).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AdminSizes.radiusM),
                    topRight: Radius.circular(AdminSizes.radiusM),
                  ),
                ),
                child: Stack(
                  children: [
                    // Preview content
                    if (media.fileType == 'image')
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AdminSizes.radiusM),
                          topRight: Radius.circular(AdminSizes.radiusM),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: media.fileUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildFilePlaceholder(media.fileType),
                          errorWidget: (context, url, error) => _buildFilePlaceholder(media.fileType),
                        ),
                      )
                    else
                      _buildFilePlaceholder(media.fileType),
                    
                    // File type badge
                    Positioned(
                      top: AdminSizes.paddingS,
                      left: AdminSizes.paddingS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AdminSizes.paddingS,
                          vertical: AdminSizes.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getFileTypeColor(media.fileType),
                          borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                        ),
                        child: Text(
                          media.fileType.toUpperCase(),
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Actions menu
                    Positioned(
                      top: AdminSizes.paddingS,
                      right: AdminSizes.paddingS,
                      child: PopupMenuButton<String>(
                        onSelected: (value) => _handleMediaAction(value, media),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('View'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(Icons.download, size: 18),
                                SizedBox(width: 8),
                                Text('Download'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // File info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AdminSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.fileName,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.adminDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AdminSizes.paddingXS),
                    Text(
                      _formatFileSize(media.fileSize),
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AdminColors.darkGray,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: AdminColors.lightGray,
                        ),
                        const SizedBox(width: AdminSizes.paddingXS),
                        Expanded(
                          child: Text(
                            _formatDate(media.uploadedAt),
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: AdminColors.lightGray,
                            ),
                          ),
                        ),
                        AdminStatusChip(
                          text: media.isUsed ? 'Used' : 'Unused',
                          color: media.isUsed ? AdminColors.success : AdminColors.warning,
                          isActive: media.isUsed,
                        ),
                      ],
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

  Widget _buildFilePlaceholder(String fileType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileTypeIcon(fileType),
            size: 40,
            color: _getFileTypeColor(fileType),
          ),
          const SizedBox(height: AdminSizes.paddingS),
          Text(
            fileType.toUpperCase(),
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getFileTypeColor(fileType),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AdminSizes.radiusL),
          topRight: Radius.circular(AdminSizes.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Media',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingL),
            Row(
              children: [
                Expanded(
                  child: _buildUploadOption(
                    'Camera',
                    Icons.camera_alt,
                    AdminColors.adminGreen,
                    () => _pickMedia(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: _buildUploadOption(
                    'Gallery',
                    Icons.photo_library,
                    AdminColors.primaryBlue,
                    () => _pickMedia(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminSizes.paddingM),
            SizedBox(
              width: double.infinity,
              child: _buildUploadOption(
                'Multiple Files',
                Icons.file_upload,
                AdminColors.adminPurple,
                _pickMultipleFiles,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AdminSizes.paddingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: AdminSizes.paddingS),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: AdminColors.adminDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      await _uploadFile(File(pickedFile.path));
    }
  }

  Future<void> _pickMultipleFiles() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() => _isUploading = true);
      
      for (final pickedFile in pickedFiles) {
        await _uploadFile(File(pickedFile.path));
      }
      
      setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadFile(File file) async {
    setState(() => _isUploading = true);

    try {
      final fileName = file.path.split('/').last;
      await AdminFirebaseService.uploadMedia(file, fileName, null);
      
      await _loadMedia();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File "$fileName" uploaded successfully!'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: ${e.toString()}'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showMediaDetail(MediaFile media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminSizes.radiusL),
        ),
        child: Container(
          padding: const EdgeInsets.all(AdminSizes.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Media Details',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.adminDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: AdminSizes.paddingM),
              
              // Preview
              if (media.fileType == 'image')
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                    border: Border.all(color: AdminColors.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                    child: CachedNetworkImage(
                      imageUrl: media.fileUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildFilePlaceholder(media.fileType),
                      errorWidget: (context, url, error) => _buildFilePlaceholder(media.fileType),
                    ),
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getFileTypeColor(media.fileType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                    border: Border.all(color: AdminColors.borderColor),
                  ),
                  child: _buildFilePlaceholder(media.fileType),
                ),
              
              const SizedBox(height: AdminSizes.paddingL),
              
              // Details
              _buildDetailRow('File Name', media.fileName),
              _buildDetailRow('File Type', media.fileType.toUpperCase()),
              _buildDetailRow('File Size', _formatFileSize(media.fileSize)),
              _buildDetailRow('Uploaded', _formatDate(media.uploadedAt)),
              _buildDetailRow('Status', media.isUsed ? 'Used' : 'Unused'),
              if (media.description?.isNotEmpty == true)
                _buildDetailRow('Description', media.description!),
              
              const SizedBox(height: AdminSizes.paddingL),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement download
                      },
                      child: const Text('Download'),
                    ),
                  ),
                  const SizedBox(width: AdminSizes.paddingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleMediaAction('delete', media);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.darkGray,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AdminColors.adminDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMediaAction(String action, MediaFile media) {
    switch (action) {
      case 'view':
        _showMediaDetail(media);
        break;
      case 'download':
        // TODO: Implement download
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download feature coming soon'),
            backgroundColor: AdminColors.info,
          ),
        );
        break;
      case 'edit':
        // TODO: Implement edit
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit feature coming soon'),
            backgroundColor: AdminColors.info,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(media);
        break;
    }
  }

  void _showDeleteConfirmation(MediaFile media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Media',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${media.fileName}"? This action cannot be undone.',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: AdminColors.darkGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMedia(media);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMedia(MediaFile media) async {
    try {
      await AdminFirebaseService.deleteMedia(media.id, media.fileUrl);
      await _loadMedia();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Media "${media.fileName}" deleted successfully'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting media: ${e.toString()}'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType) {
      case 'image':
        return AdminColors.adminGreen;
      case 'video':
        return AdminColors.adminPurple;
      case 'pdf':
        return AdminColors.error;
      case 'document':
        return AdminColors.primaryBlue;
      default:
        return AdminColors.darkGray;
    }
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatStorageSize() {
    final totalSize = _allMedia.fold<int>(0, (sum, media) => sum + media.fileSize);
    return _formatFileSize(totalSize);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}