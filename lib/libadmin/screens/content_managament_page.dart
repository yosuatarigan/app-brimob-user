import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:app_brimob_user/libadmin/models/admin_model.dart';
import 'package:app_brimob_user/libadmin/widget/admin_witget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/admin_firebase_service.dart';
import 'content_editor_page.dart';

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<ContentItem> _allContent = [];
  List<ContentItem> _filteredContent = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final content = await AdminFirebaseService.getAllContent();
      
      setState(() {
        _allContent = content;
        _filteredContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterContent() {
    setState(() {
      _filteredContent = _allContent.where((content) {
        final matchesCategory = _selectedCategory == 'all' || 
                               content.category == _selectedCategory;
        final matchesSearch = content.title.toLowerCase()
                               .contains(_searchQuery.toLowerCase()) ||
                             content.content.toLowerCase()
                               .contains(_searchQuery.toLowerCase());
        
        return matchesCategory && matchesSearch;
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
      floatingActionButton: AdminFloatingActionButton(
        icon: Icons.add,
        label: 'Tambah Konten',
        onPressed: _navigateToEditor,
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
            imageUrl: AdminImages.contentManagement,
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
                        'Content Management',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadContent,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Kelola semua konten aplikasi',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AdminSizes.paddingS),
                Row(
                  children: [
                    _buildQuickStat('Total', '${_allContent.length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Published', '${_allContent.where((c) => c.isPublished).length}'),
                    const SizedBox(width: AdminSizes.paddingL),
                    _buildQuickStat('Drafts', '${_allContent.where((c) => !c.isPublished).length}'),
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
              _filterContent();
            },
            decoration: InputDecoration(
              hintText: 'Cari konten...',
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
          
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('all', 'Semua'),
                ...AdminMenus.contentCategories.map((category) => 
                  _buildCategoryChip(category['id'], category['title'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryId, String title) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: AdminSizes.paddingS),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = categoryId;
          });
          _filterContent();
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
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'All Content'),
          Tab(text: 'Published'),
          Tab(text: 'Drafts'),
        ],
        onTap: (index) {
          // Filter based on tab
          setState(() {
            switch (index) {
              case 0:
                _filteredContent = _allContent;
                break;
              case 1:
                _filteredContent = _allContent.where((c) => c.isPublished).toList();
                break;
              case 2:
                _filteredContent = _allContent.where((c) => !c.isPublished).toList();
                break;
            }
          });
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const AdminLoadingWidget(message: 'Memuat konten...');
  }

  Widget _buildContent() {
    if (_error != null) {
      return AdminErrorWidget(
        title: 'Error Loading Content',
        message: _error!,
        onRetry: _loadContent,
      );
    }

    if (_filteredContent.isEmpty) {
      return AdminEmptyState(
        icon: Icons.article_outlined,
        title: 'Belum Ada Konten',
        message: 'Mulai buat konten pertama untuk aplikasi',
        actionText: 'Tambah Konten',
        onAction: _navigateToEditor,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildContentList(_filteredContent),
        _buildContentList(_allContent.where((c) => c.isPublished).toList()),
        _buildContentList(_allContent.where((c) => !c.isPublished).toList()),
      ],
    );
  }

  Widget _buildContentList(List<ContentItem> content) {
    return RefreshIndicator(
      onRefresh: _loadContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(AdminSizes.paddingM),
        itemCount: content.length,
        itemBuilder: (context, index) {
          final item = content[index];
          return _buildContentCard(item);
        },
      ),
    );
  }

  Widget _buildContentCard(ContentItem content) {
    final categoryData = AdminMenus.contentCategories.firstWhere(
      (cat) => cat['id'] == content.category,
      orElse: () => {'title': content.category.toUpperCase(), 'color': AdminColors.lightGray},
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AdminSizes.paddingM),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: InkWell(
        onTap: () => _navigateToEditor(content: content),
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.adminDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AdminSizes.paddingXS),
                        Text(
                          content.content.length > 100 
                              ? '${content.content.substring(0, 100)}...'
                              : content.content,
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
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, content),
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
                      PopupMenuItem(
                        value: content.isPublished ? 'unpublish' : 'publish',
                        child: Row(
                          children: [
                            Icon(
                              content.isPublished ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(content.isPublished ? 'Unpublish' : 'Publish'),
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
              
              // Status and meta info
              Row(
                children: [
                  AdminStatusChip(
                    text: categoryData['title'],
                    color: categoryData['color'],
                  ),
                  const SizedBox(width: AdminSizes.paddingS),
                  AdminStatusChip(
                    text: content.isPublished ? 'Published' : 'Draft',
                    color: content.isPublished ? AdminColors.success : AdminColors.warning,
                    icon: content.isPublished ? Icons.visibility : Icons.edit,
                  ),
                  const Spacer(),
                  Text(
                    '${content.viewCount} views',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AdminColors.lightGray,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AdminSizes.paddingS),
              
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AdminColors.lightGray,
                  ),
                  const SizedBox(width: AdminSizes.paddingXS),
                  Text(
                    'Updated ${_formatDate(content.updatedAt)}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AdminColors.lightGray,
                    ),
                  ),
                  const Spacer(),
                  if (content.images.isNotEmpty) ...[
                    Icon(
                      Icons.image,
                      size: 16,
                      color: AdminColors.lightGray,
                    ),
                    const SizedBox(width: AdminSizes.paddingXS),
                    Text(
                      '${content.images.length} images',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AdminColors.lightGray,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditor({ContentItem? content}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentEditorPage(content: content),
      ),
    ).then((result) {
      if (result == true) {
        _loadContent();
      }
    });
  }

  void _handleMenuAction(String action, ContentItem content) {
    switch (action) {
      case 'edit':
        _navigateToEditor(content: content);
        break;
      case 'publish':
      case 'unpublish':
        _togglePublishStatus(content);
        break;
      case 'delete':
        _showDeleteConfirmation(content);
        break;
    }
  }

  void _togglePublishStatus(ContentItem content) async {
    try {
      final updatedContent = ContentItem(
        id: content.id,
        title: content.title,
        content: content.content,
        category: content.category,
        images: content.images,
        isPublic: content.isPublic,
        createdAt: content.createdAt,
        updatedAt: DateTime.now(),
        createdBy: content.createdBy,
        updatedBy: AdminFirebaseService.currentUser!.uid,
        isPublished: !content.isPublished,
        viewCount: content.viewCount,
      );

      await AdminFirebaseService.updateContent(content.id, updatedContent);
      _loadContent();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Content ${updatedContent.isPublished ? "published" : "unpublished"} successfully',
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

  void _showDeleteConfirmation(ContentItem content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Content',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${content.title}"? This action cannot be undone.',
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
              _deleteContent(content);
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

  void _deleteContent(ContentItem content) async {
    try {
      await AdminFirebaseService.deleteContent(content.id);
      _loadContent();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Content "${content.title}" deleted successfully'),
          backgroundColor: AdminColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting content: ${e.toString()}'),
          backgroundColor: AdminColors.error,
        ),
      );
    }
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