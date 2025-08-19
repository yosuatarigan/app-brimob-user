import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/models/admin_model.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/admin_firebase_service.dart';

class GalleryManagementPage extends StatefulWidget {
  const GalleryManagementPage({super.key});

  @override
  State<GalleryManagementPage> createState() => _GalleryManagementPageState();
}

class _GalleryManagementPageState extends State<GalleryManagementPage> {
  List<GalleryItem> _galleryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final items = await AdminFirebaseService.getAllGallery();
      
      setState(() {
        _galleryItems = items;
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
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: AdminFloatingActionButton(
        icon: Icons.add,
        label: 'Tambah Galeri',
        onPressed: _showCreateGalleryDialog,
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
            imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=300&fit=crop',
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
                        'Gallery Management',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadGallery,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Kelola galeri satuan dan dokumentasi',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AdminSizes.paddingS),
                Row(
                  children: [
                    _buildQuickStat('Total Galeri', '${_galleryItems.length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Active', '${_galleryItems.where((g) => g.isActive).length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Images', '${_galleryItems.fold<int>(0, (sum, g) => sum + g.images.length)}'),
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

  Widget _buildLoadingState() {
    return const AdminLoadingWidget(message: 'Memuat galeri...');
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Gallery',
        message: _error!,
        onRetry: _loadGallery,
      );
    }

    if (_galleryItems.isEmpty) {
      return AdminEmptyState(
        icon: Icons.collections_outlined,
        title: 'Belum Ada Galeri',
        message: 'Tambah galeri pertama untuk satuan',
        actionText: 'Tambah Galeri',
        onAction: _showCreateGalleryDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGallery,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        itemCount: _galleryItems.length,
        onReorder: _reorderItems,
        itemBuilder: (context, index) {
          final item = _galleryItems[index];
          return _buildGalleryCard(item, index);
        },
      ),
    );
  }

  Widget _buildGalleryCard(GalleryItem item, int index) {
    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: AdminSizes.paddingM),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Order number
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      '${item.order}',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: AdminSizes.paddingM),
                
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.adminDark,
                              ),
                            ),
                          ),
                          AdminStatusChip(
                            text: item.isActive ? 'Active' : 'Inactive',
                            color: item.isActive ? AdminColors.success : AdminColors.error,
                            icon: item.isActive ? Icons.visibility : Icons.visibility_off,
                          ),
                        ],
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),
                      Text(
                        item.description,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AdminColors.darkGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleGalleryAction(value, item),
                  itemBuilder: (context) => [
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
                      value: 'manage_images',
                      child: Row(
                        children: [
                          Icon(Icons.photo_library, size: 18),
                          SizedBox(width: 8),
                          Text('Manage Images'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: item.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            item.isActive ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(item.isActive ? 'Deactivate' : 'Activate'),
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
              ],
            ),
            
            const SizedBox(height: AdminSizes.paddingM),
            
            // Images preview
            if (item.images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.images.length > 5 ? 5 : item.images.length,
                  itemBuilder: (context, imgIndex) {
                    if (imgIndex == 4 && item.images.length > 5) {
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: AdminSizes.paddingS),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                        ),
                        child: Center(
                          child: Text(
                            '+${item.images.length - 4}',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: AdminSizes.paddingS),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                        border: Border.all(color: AdminColors.borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                        child: CachedNetworkImage(
                          imageUrl: item.images[imgIndex],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AdminColors.background,
                            child: const Icon(Icons.image),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AdminColors.background,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                  border: Border.all(
                    color: AdminColors.borderColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        color: AdminColors.lightGray,
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),
                      Text(
                        'No images',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AdminColors.lightGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: AdminSizes.paddingM),
            
            // Footer info
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AdminColors.lightGray,
                ),
                const SizedBox(width: AdminSizes.paddingXS),
                Text(
                  'Updated ${_formatDate(item.updatedAt)}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AdminColors.lightGray,
                  ),
                ),
                const Spacer(),
                Text(
                  '${item.images.length} images',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AdminColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Icon(
                  Icons.drag_handle,
                  color: AdminColors.lightGray,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _galleryItems.removeAt(oldIndex);
      _galleryItems.insert(newIndex, item);
      
      // Update order numbers
      for (int i = 0; i < _galleryItems.length; i++) {
        _galleryItems[i] = GalleryItem(
          id: _galleryItems[i].id,
          name: _galleryItems[i].name,
          description: _galleryItems[i].description,
          images: _galleryItems[i].images,
          logoUrl: _galleryItems[i].logoUrl,
          order: i + 1,
          createdAt: _galleryItems[i].createdAt,
          updatedAt: DateTime.now(),
          createdBy: _galleryItems[i].createdBy,
          isActive: _galleryItems[i].isActive,
        );
      }
    });
    
    // Save the new order to Firebase
    _saveGalleryOrder();
  }

  void _saveGalleryOrder() async {
    try {
      for (final item in _galleryItems) {
        await AdminFirebaseService.updateGalleryItem(item.id, item);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallery order updated successfully'),
          backgroundColor: AdminColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: ${e.toString()}'),
          backgroundColor: AdminColors.error,
        ),
      );
    }
  }

  void _showCreateGalleryDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGalleryDialog(
        onGalleryCreated: _loadGallery,
      ),
    );
  }

  void _handleGalleryAction(String action, GalleryItem item) {
    switch (action) {
      case 'edit':
        _showEditGalleryDialog(item);
        break;
      case 'manage_images':
        _showManageImagesDialog(item);
        break;
      case 'activate':
      case 'deactivate':
        _toggleGalleryStatus(item);
        break;
      case 'delete':
        _showDeleteConfirmation(item);
        break;
    }
  }

  void _showEditGalleryDialog(GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) => EditGalleryDialog(
        item: item,
        onGalleryUpdated: _loadGallery,
      ),
    );
  }

  void _showManageImagesDialog(GalleryItem item) {
    showDialog(
      context: context,
      // isScrollControlled: true,
      builder: (context) => ManageImagesDialog(
        item: item,
        onImagesUpdated: _loadGallery,
      ),
    );
  }

  void _toggleGalleryStatus(GalleryItem item) async {
    try {
      final updatedItem = GalleryItem(
        id: item.id,
        name: item.name,
        description: item.description,
        images: item.images,
        logoUrl: item.logoUrl,
        order: item.order,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
        createdBy: item.createdBy,
        isActive: !item.isActive,
      );

      await AdminFirebaseService.updateGalleryItem(item.id, updatedItem);
      _loadGallery();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gallery ${updatedItem.isActive ? "activated" : "deactivated"} successfully',
          ),
          backgroundColor: AdminColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AdminColors.error,
        ),
      );
    }
  }

  void _showDeleteConfirmation(GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Gallery',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
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
              // TODO: Implement gallery deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gallery deletion feature coming soon'),
                  backgroundColor: AdminColors.warning,
                ),
              );
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

// Create Gallery Dialog
class CreateGalleryDialog extends StatefulWidget {
  final VoidCallback onGalleryCreated;

  const CreateGalleryDialog({super.key, required this.onGalleryCreated});

  @override
  State<CreateGalleryDialog> createState() => _CreateGalleryDialogState();
}

class _CreateGalleryDialogState extends State<CreateGalleryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Create New Gallery',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Gallery Name',
                prefixIcon: Icon(Icons.collections),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.roboto(color: AdminColors.darkGray),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createGallery,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryBlue,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Create',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
        ),
      ],
    );
  }

  void _createGallery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newItem = GalleryItem(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        images: [],
        logoUrl: '',
        order: 999, // Will be updated based on existing items
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: AdminFirebaseService.currentUser!.uid,
        isActive: true,
      );

      await AdminFirebaseService.createGalleryItem(newItem);

      if (mounted) {
        Navigator.pop(context);
        widget.onGalleryCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gallery created successfully!'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Edit Gallery Dialog
class EditGalleryDialog extends StatefulWidget {
  final GalleryItem item;
  final VoidCallback onGalleryUpdated;

  const EditGalleryDialog({
    super.key,
    required this.item,
    required this.onGalleryUpdated,
  });

  @override
  State<EditGalleryDialog> createState() => _EditGalleryDialogState();
}

class _EditGalleryDialogState extends State<EditGalleryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _descriptionController.text = widget.item.description;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Gallery',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Gallery Name',
                prefixIcon: Icon(Icons.collections),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AdminSizes.paddingM),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.roboto(color: AdminColors.darkGray),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateGallery,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryBlue,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Update',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
        ),
      ],
    );
  }

  void _updateGallery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedItem = GalleryItem(
        id: widget.item.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        images: widget.item.images,
        logoUrl: widget.item.logoUrl,
        order: widget.item.order,
        createdAt: widget.item.createdAt,
        updatedAt: DateTime.now(),
        createdBy: widget.item.createdBy,
        isActive: widget.item.isActive,
      );

      await AdminFirebaseService.updateGalleryItem(widget.item.id, updatedItem);

      if (mounted) {
        Navigator.pop(context);
        widget.onGalleryUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gallery updated successfully!'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Manage Images Dialog
class ManageImagesDialog extends StatefulWidget {
  final GalleryItem item;
  final VoidCallback onImagesUpdated;

  const ManageImagesDialog({
    super.key,
    required this.item,
    required this.onImagesUpdated,
  });

  @override
  State<ManageImagesDialog> createState() => _ManageImagesDialogState();
}

class _ManageImagesDialogState extends State<ManageImagesDialog> {
  List<String> _images = [];
  List<File> _newImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.item.images);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage Images - ${widget.item.name}',
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
            
            // Add images button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImages,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(_isUploading ? 'Uploading...' : 'Add Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: AdminSizes.paddingM),
            
            // Images grid
            Expanded(
              child: _buildImagesGrid(),
            ),
            
            const SizedBox(height: AdminSizes.paddingM),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _saveImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.success,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid() {
    final allImages = [
      ..._images.map((url) => {'type': 'url', 'data': url}),
      ..._newImages.map((file) => {'type': 'file', 'data': file}),
    ];

    if (allImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: AdminColors.lightGray,
            ),
            const SizedBox(height: AdminSizes.paddingM),
            Text(
              'No images yet',
              style: GoogleFonts.roboto(
                color: AdminColors.lightGray,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AdminSizes.paddingS,
        mainAxisSpacing: AdminSizes.paddingS,
        childAspectRatio: 1,
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        final image = allImages[index];
        return _buildImageItem(image, index);
      },
    );
  }

  Widget _buildImageItem(Map<String, dynamic> image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
            border: Border.all(color: AdminColors.borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
            child: image['type'] == 'url'
                ? CachedNetworkImage(
                    imageUrl: image['data'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    // errorBuilder: (context, error, stackTrace) => Container(
                    //   color: AdminColors.background,
                    //   child: const Icon(Icons.broken_image),
                    // ),
                  )
                : Image.file(
                    image['data'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _images.length) {
        _images.removeAt(index);
      } else {
        _newImages.removeAt(index - _images.length);
      }
    });
  }

  Future<void> _saveImages() async {
    setState(() => _isUploading = true);

    try {
      // Upload new images
      List<String> uploadedImageUrls = [];
      for (File image in _newImages) {
        final fileName = 'gallery_${widget.item.id}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final imageUrl = await AdminFirebaseService.uploadMedia(image, fileName, null);
        uploadedImageUrls.add(imageUrl);
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._images, ...uploadedImageUrls];

      // Update gallery item
      final updatedItem = GalleryItem(
        id: widget.item.id,
        name: widget.item.name,
        description: widget.item.description,
        images: allImageUrls,
        logoUrl: widget.item.logoUrl,
        order: widget.item.order,
        createdAt: widget.item.createdAt,
        updatedAt: DateTime.now(),
        createdBy: widget.item.createdBy,
        isActive: widget.item.isActive,
      );

      await AdminFirebaseService.updateGalleryItem(widget.item.id, updatedItem);

      if (mounted) {
        Navigator.pop(context);
        widget.onImagesUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images updated successfully!'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving images: ${e.toString()}'),
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
}