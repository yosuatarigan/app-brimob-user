import 'dart:io';
import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:app_brimob_user/slide_show_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import '../services/admin_firebase_service.dart';

class SlideshowManagementPage extends StatefulWidget {
  const SlideshowManagementPage({super.key});

  @override
  State<SlideshowManagementPage> createState() =>
      _SlideshowManagementPageState();
}

class _SlideshowManagementPageState extends State<SlideshowManagementPage> {
  List<SlideshowItem> _slideshowItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSlideshowItems();
  }

  Future<void> _loadSlideshowItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final items = await AdminFirebaseService.getSlideshowItems();
      setState(() {
        _slideshowItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addSlideshowItem() async {
    final result = await showDialog<SlideshowItem>(
      context: context,
      builder: (context) => const SlideshowItemDialog(),
    );

    if (result != null) {
      try {
        await AdminFirebaseService.addSlideshowItem(result);
        await _loadSlideshowItems();
        _showSnackBar('Slideshow item berhasil ditambahkan', Colors.green);
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _editSlideshowItem(SlideshowItem item) async {
    final result = await showDialog<SlideshowItem>(
      context: context,
      builder: (context) => SlideshowItemDialog(item: item),
    );

    if (result != null) {
      try {
        await AdminFirebaseService.updateSlideshowItem(result);
        await _loadSlideshowItems();
        _showSnackBar('Slideshow item berhasil diupdate', Colors.green);
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _deleteSlideshowItem(SlideshowItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Hapus Slideshow Item',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus slideshow image ini?',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.roboto(color: AdminColors.darkGray),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Hapus',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await AdminFirebaseService.deleteSlideshowItem(item.id);
        await _loadSlideshowItems();
        _showSnackBar('Slideshow item berhasil dihapus', Colors.green);
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _toggleItemStatus(SlideshowItem item) async {
    try {
      final updatedItem = item.copyWith(
        isActive: !item.isActive,
        updatedAt: DateTime.now(),
      );
      await AdminFirebaseService.updateSlideshowItem(updatedItem);
      await _loadSlideshowItems();
      _showSnackBar(
        'Status slideshow berhasil ${updatedItem.isActive ? "diaktifkan" : "dinonaktifkan"}',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _reorderItems(List<SlideshowItem> newOrder) async {
    try {
      // Update order for all items
      final updatedItems = <SlideshowItem>[];
      for (int i = 0; i < newOrder.length; i++) {
        updatedItems.add(
          newOrder[i].copyWith(order: i, updatedAt: DateTime.now()),
        );
      }

      await AdminFirebaseService.updateSlideshowOrder(updatedItems);
      setState(() {
        _slideshowItems = updatedItems;
      });
      _showSnackBar('Urutan slideshow berhasil diupdate', Colors.green);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: Text(
          'Kelola Slideshow',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AdminColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _addSlideshowItem,
            icon: const Icon(Icons.add_circle),
            tooltip: 'Tambah Slideshow Item',
          ),
          IconButton(
            onPressed: _loadSlideshowItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlideshowItem,
        backgroundColor: AdminColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Slideshow Item',
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: AdminLoadingWidget(message: 'Memuat slideshow items...'),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Slideshow',
        message: _error!,
        onRetry: _loadSlideshowItems,
      );
    }

    if (_slideshowItems.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSlideshowItems,
      child: Column(
        children: [_buildStatsCard(), Expanded(child: _buildSlideshowList())],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.slideshow, size: 80, color: AdminColors.lightGray),
          const SizedBox(height: 16),
          Text(
            'Belum ada slideshow item',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AdminColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan slideshow item untuk dashboard',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AdminColors.lightGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addSlideshowItem,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Slideshow Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final activeCount = _slideshowItems.where((item) => item.isActive).length;
    final inactiveCount = _slideshowItems.length - activeCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Items',
              '${_slideshowItems.length}',
              Icons.slideshow,
              AdminColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Aktif',
              '$activeCount',
              Icons.visibility,
              AdminColors.adminGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Nonaktif',
              '$inactiveCount',
              Icons.visibility_off,
              AdminColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AdminColors.adminDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 12, color: AdminColors.darkGray),
        ),
      ],
    );
  }

  Widget _buildSlideshowList() {
    return ReorderableColumn(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onReorder: (oldIndex, newIndex) {
        final List<SlideshowItem> reorderedItems = List.from(_slideshowItems);
        final item = reorderedItems.removeAt(oldIndex);
        reorderedItems.insert(newIndex, item);
        _reorderItems(reorderedItems);
      },
      children:
          _slideshowItems.map((item) => _buildSlideshowCard(item)).toList(),
    );
  }

  Widget _buildSlideshowCard(SlideshowItem item) {
    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            Icon(Icons.drag_handle, color: AdminColors.lightGray, size: 20),
            const SizedBox(width: 12),

            // Image preview
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.lightGray),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: AdminColors.lightGray.withOpacity(0.3),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: AdminColors.lightGray.withOpacity(0.3),
                                child: const Icon(Icons.error, size: 20),
                              ),
                        )
                        : Container(
                          color: AdminColors.lightGray.withOpacity(0.3),
                          child: const Icon(Icons.image, size: 30),
                        ),
              ),
            ),

            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Slideshow Image ${item.order + 1}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.adminDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              item.isActive
                                  ? AdminColors.adminGreen.withOpacity(0.1)
                                  : AdminColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.isActive ? 'Aktif' : 'Nonaktif',
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color:
                                item.isActive
                                    ? AdminColors.adminGreen
                                    : AdminColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Order: ${item.order}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AdminColors.darkGray,
                    ),
                  ),

                  if (item.imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_done,
                            size: 12,
                            color: AdminColors.adminGreen,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Firebase Storage',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                color: AdminColors.adminGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  onPressed: () => _toggleItemStatus(item),
                  icon: Icon(
                    item.isActive ? Icons.visibility : Icons.visibility_off,
                    color:
                        item.isActive
                            ? AdminColors.adminGreen
                            : AdminColors.error,
                    size: 20,
                  ),
                  tooltip: item.isActive ? 'Nonaktifkan' : 'Aktifkan',
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editSlideshowItem(item);
                        break;
                      case 'delete':
                        _deleteSlideshowItem(item);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 16),
                              const SizedBox(width: 8),
                              Text('Edit', style: GoogleFonts.roboto()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: GoogleFonts.roboto(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                  child: const Icon(
                    Icons.more_vert,
                    color: AdminColors.lightGray,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SlideshowItemDialog extends StatefulWidget {
  final SlideshowItem? item;

  const SlideshowItemDialog({super.key, this.item});

  @override
  State<SlideshowItemDialog> createState() => _SlideshowItemDialogState();
}

class _SlideshowItemDialogState extends State<SlideshowItemDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isActive = true;
  bool _isUploading = false;
  File? _selectedImage;
  String _uploadedImageUrl = '';

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _isActive = widget.item!.isActive;
      _uploadedImageUrl = widget.item!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final imageUrl = await AdminFirebaseService.uploadSlideshowImage(
        _selectedImage!,
      );
      setState(() {
        _uploadedImageUrl = imageUrl;
        _selectedImage = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar berhasil diupload'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error upload gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    // If editing existing item and no new image selected, use existing image
    if (widget.item != null &&
        _selectedImage == null &&
        _uploadedImageUrl.isNotEmpty) {
      final now = DateTime.now();
      final slideshowItem = widget.item!.copyWith(
        isActive: _isActive,
        updatedAt: now,
      );
      Navigator.pop(context, slideshowItem);
      return;
    }

    // If new item or new image selected, upload first
    if (_selectedImage != null) {
      setState(() => _isUploading = true);
      try {
        final imageUrl = await AdminFirebaseService.uploadSlideshowImage(
          _selectedImage!,
        );
        setState(() {
          _uploadedImageUrl = imageUrl;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_uploadedImageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih dan upload gambar terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final slideshowItem =
        widget.item?.copyWith(
          imageUrl: _uploadedImageUrl,
          isActive: _isActive,
          updatedAt: now,
        ) ??
        SlideshowItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: _uploadedImageUrl,
          isActive: _isActive,
          order: 0,
          createdAt: now,
          updatedAt: now,
        );

    Navigator.pop(context, slideshowItem);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.slideshow, color: AdminColors.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item == null
                        ? 'Tambah Slideshow Item'
                        : 'Edit Slideshow Item',
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
            const SizedBox(height: 20),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Image selection
                    _buildImageSection(),
                    const SizedBox(height: 16),


                    // Status toggle
                    SwitchListTile(
                      title: Text(
                        'Status Aktif',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _isActive
                            ? 'Item akan ditampilkan di slideshow'
                            : 'Item tidak akan ditampilkan',
                        style: GoogleFonts.roboto(fontSize: 12),
                      ),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeColor: AdminColors.adminGreen,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Batal', style: GoogleFonts.roboto()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isUploading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Simpan',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar Slideshow',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AdminColors.adminDark,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Upload gambar berkualitas tinggi dengan rasio landscape (16:9 direkomendasikan)',
          style: GoogleFonts.roboto(fontSize: 12, color: AdminColors.darkGray),
        ),

        const SizedBox(height: 12),

        // Image preview
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AdminColors.lightGray),
            borderRadius: BorderRadius.circular(12),
            color: AdminColors.lightGray.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImagePreview(),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons
        if (_selectedImage != null) ...[
          // Upload button when image is selected
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadImage,
              icon:
                  _isUploading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.cloud_upload),
              label: Text(
                _isUploading ? 'Mengupload...' : 'Upload Gambar ke Firebase',
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.adminGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Change image button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: Text('Pilih Gambar Lain', style: GoogleFonts.roboto()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else if (_uploadedImageUrl.isNotEmpty) ...[
          // Change uploaded image
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: Text('Ganti Gambar', style: GoogleFonts.roboto()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _uploadedImageUrl = ''),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: Text(
                    'Hapus',
                    style: GoogleFonts.roboto(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Initial select image button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                'Pilih Gambar dari Galeri',
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    // Show selected local image (not yet uploaded)
    if (_selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_selectedImage!, fit: BoxFit.cover),
          // Overlay to indicate not uploaded yet
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AdminColors.warning.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Klik "Upload Gambar" untuk menyimpan',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show uploaded image from Firebase
    if (_uploadedImageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _uploadedImageUrl,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: AdminColors.lightGray.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: AdminColors.lightGray.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 40, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading image',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
          // Success indicator overlay
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AdminColors.adminGreen.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Tersimpan',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Empty state - no image selected or uploaded
    return Container(
      color: AdminColors.lightGray.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: AdminColors.lightGray,
          ),
          const SizedBox(height: 12),
          Text(
            'Pilih Gambar Slideshow',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AdminColors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gambar akan diupload ke Firebase Storage',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: AdminColors.lightGray,
            ),
          ),
        ],
      ),
    );
  }
}
