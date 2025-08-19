import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/models/admin_model.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/admin_firebase_service.dart';

class ContentEditorPage extends StatefulWidget {
  final ContentItem? content;

  const ContentEditorPage({super.key, this.content});

  @override
  State<ContentEditorPage> createState() => _ContentEditorPageState();
}

class _ContentEditorPageState extends State<ContentEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedCategory = 'korbrimob';
  bool _isPublic = true;
  bool _isPublished = false;
  List<String> _imageUrls = [];
  List<File> _newImages = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.content != null) {
      final content = widget.content!;
      _titleController.text = content.title;
      _contentController.text = content.content;
      _selectedCategory = content.category;
      _isPublic = content.isPublic;
      _isPublished = content.isPublished;
      _imageUrls = List.from(content.images);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          widget.content == null ? 'Tambah Konten' : 'Edit Konten',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _saveContent,
              child: Text(
                'SIMPAN',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildForm(),
    );
  }

  Widget _buildLoadingState() {
    return const AdminLoadingWidget(message: 'Memuat editor...');
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: AdminSizes.paddingL),
            _buildContentEditor(),
            const SizedBox(height: AdminSizes.paddingL),
            _buildImageSection(),
            const SizedBox(height: AdminSizes.paddingL),
            _buildSettings(),
            const SizedBox(height: AdminSizes.paddingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Dasar',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingL),
            
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Konten',
                hintText: 'Masukkan judul konten',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AdminSizes.paddingL),
            
            // Category selection
            Text(
              'Kategori',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingS),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: AdminMenus.contentCategories.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['id'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AdminSizes.paddingS),
                      Text(category['title']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentEditor() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Konten',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.adminDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showFormattingHelp,
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Bantuan Formatting',
                ),
              ],
            ),
            const SizedBox(height: AdminSizes.paddingL),
            
            // Content editor with toolbar
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AdminColors.borderColor),
                borderRadius: BorderRadius.circular(AdminSizes.radiusM),
              ),
              child: Column(
                children: [
                  // Formatting toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminSizes.paddingM,
                      vertical: AdminSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AdminSizes.radiusM),
                        topRight: Radius.circular(AdminSizes.radiusM),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildToolbarButton(Icons.format_bold, 'Bold', () => _insertText('**', '**')),
                        _buildToolbarButton(Icons.format_italic, 'Italic', () => _insertText('*', '*')),
                        _buildToolbarButton(Icons.format_list_bulleted, 'List', () => _insertText('\n• ', '')),
                        _buildToolbarButton(Icons.format_quote, 'Quote', () => _insertText('\n> ', '')),
                        _buildToolbarButton(Icons.link, 'Link', _insertLink),
                        const Spacer(),
                        Text(
                          '${_contentController.text.length} karakter',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AdminColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Text editor
                  TextFormField(
                    controller: _contentController,
                    maxLines: 15,
                    decoration: const InputDecoration(
                      hintText: 'Tulis konten di sini...\n\nGunakan markdown untuk formatting:\n**Bold** *Italic* \n• List item\n> Quote',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(AdminSizes.paddingM),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konten tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 40),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Gambar',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.adminDark,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: const Text('Tambah Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminSizes.paddingM),
            
            if (_imageUrls.isEmpty && _newImages.isEmpty)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(AdminSizes.radiusM),
                  border: Border.all(
                    color: AdminColors.borderColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: AdminColors.lightGray,
                    ),
                    const SizedBox(height: AdminSizes.paddingS),
                    Text(
                      'Belum ada gambar',
                      style: GoogleFonts.roboto(
                        color: AdminColors.lightGray,
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildImageGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final allImages = [
      ..._imageUrls.map((url) => {'type': 'url', 'data': url}),
      ..._newImages.map((file) => {'type': 'file', 'data': file}),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
                ? Image.network(
                    image['data'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AdminColors.background,
                      child: const Icon(Icons.broken_image),
                    ),
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

  Widget _buildSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingL),
            
            // Public/Private toggle
            Row(
              children: [
                Icon(
                  _isPublic ? Icons.public : Icons.lock,
                  color: _isPublic ? AdminColors.success : AdminColors.warning,
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPublic ? 'Konten Publik' : 'Konten Terbatas',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.adminDark,
                        ),
                      ),
                      Text(
                        _isPublic 
                            ? 'Dapat diakses oleh semua pengguna'
                            : 'Hanya untuk pengguna dengan akses khusus',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AdminColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  activeColor: AdminColors.success,
                ),
              ],
            ),
            
            const Divider(height: AdminSizes.paddingXL),
            
            // Published toggle
            Row(
              children: [
                Icon(
                  _isPublished ? Icons.visibility : Icons.visibility_off,
                  color: _isPublished ? AdminColors.success : AdminColors.lightGray,
                ),
                const SizedBox(width: AdminSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPublished ? 'Published' : 'Draft',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.adminDark,
                        ),
                      ),
                      Text(
                        _isPublished 
                            ? 'Konten sudah dipublikasikan dan dapat dilihat user'
                            : 'Konten masih dalam draft, belum dipublikasikan',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AdminColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isPublished,
                  onChanged: (value) {
                    setState(() {
                      _isPublished = value;
                    });
                  },
                  activeColor: AdminColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _insertText(String before, String after) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before${text.substring(selection.start, selection.end)}$after',
    );
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: selection.start + before.length + (selection.end - selection.start) + after.length,
    );
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (context) {
        final urlController = TextEditingController();
        final textController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Insert Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Link Text',
                  hintText: 'Enter link text',
                ),
              ),
              const SizedBox(height: AdminSizes.paddingM),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final linkText = textController.text.isNotEmpty 
                    ? textController.text 
                    : urlController.text;
                _insertText('[${linkText}](', '${urlController.text})');
                Navigator.pop(context);
              },
              child: const Text('Insert'),
            ),
          ],
        );
      },
    );
  }

  void _showFormattingHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Formatting Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('**Bold text**', 'Bold formatting'),
            _buildHelpItem('*Italic text*', 'Italic formatting'),
            _buildHelpItem('• List item', 'Bullet point'),
            _buildHelpItem('> Quote text', 'Quote block'),
            _buildHelpItem('[Link text](URL)', 'Hyperlink'),
          ],
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

  Widget _buildHelpItem(String syntax, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              syntax,
              style: GoogleFonts.roboto(
                // fontFamily: 'monospace',
                fontSize: 12,
                color: AdminColors.primaryBlue,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: GoogleFonts.roboto(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
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
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      } else {
        _newImages.removeAt(index - _imageUrls.length);
      }
    });
  }

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Upload new images
      List<String> uploadedImageUrls = [];
      for (File image in _newImages) {
        final fileName = 'content_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final imageUrl = await AdminFirebaseService.uploadMedia(image, fileName, null);
        uploadedImageUrls.add(imageUrl);
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._imageUrls, ...uploadedImageUrls];

      // Create content object
      final content = ContentItem(
        id: widget.content?.id ?? '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        images: allImageUrls,
        isPublic: _isPublic,
        createdAt: widget.content?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.content?.createdBy ?? AdminFirebaseService.currentUser!.uid,
        updatedBy: AdminFirebaseService.currentUser!.uid,
        isPublished: _isPublished,
        viewCount: widget.content?.viewCount ?? 0,
      );

      // Save to Firebase
      if (widget.content == null) {
        await AdminFirebaseService.createContent(content);
      } else {
        await AdminFirebaseService.updateContent(widget.content!.id, content);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.content == null 
                  ? 'Content created successfully!' 
                  : 'Content updated successfully!',
            ),
            backgroundColor: AdminColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving content: ${e.toString()}'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}