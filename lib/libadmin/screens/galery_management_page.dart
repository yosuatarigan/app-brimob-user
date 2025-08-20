import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryManagementPage extends StatefulWidget {
  @override
  _GalleryManagementPageState createState() => _GalleryManagementPageState();
}

class _GalleryManagementPageState extends State<GalleryManagementPage> {
  final List<Map<String, dynamic>> categories = [
    {
      'id': 'mako_kor',
      'name': 'MAKO KOR',
      'color': const Color(0xFF1565C0),
      'logo': 'assets/brimob.png',
    },
    {
      'id': 'pas_pelopor',
      'name': 'PAS PELOPOR',
      'color': const Color(0xFFD32F2F),
      'logo': 'assets/paspelopor.jpg',
    },
    {
      'id': 'pas_gegana',
      'name': 'PAS GEGANA',
      'color': const Color(0xFF388E3C),
      'logo': 'assets/gegana.jpg',
    },
    {
      'id': 'pasbrimob_i',
      'name': 'PASBRIMOB I',
      'color': const Color(0xFFF57C00),
      'logo': 'assets/brimob.png',
    },
    {
      'id': 'pasbrimob_ii',
      'name': 'PASBRIMOB II',
      'color': const Color(0xFF7B1FA2),
      'logo': 'assets/brimob.png',
    },
    {
      'id': 'pasbrimob_iii',
      'name': 'PASBRIMOB III',
      'color': const Color(0xFF00796B),
      'logo': 'assets/brimob.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Gallery Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Galeri Satuan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola gambar untuk setiap satuan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(categories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  category['logo'],
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                category['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: category['color'],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kelola Gambar',
                  style: TextStyle(
                    fontSize: 12,
                    color: category['color'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<String> imageUrls = [];
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => isLoading = true);
    
    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('gallery/${widget.category['id']}')
          .listAll();
      
      List<String> urls = [];
      for (var ref in result.items) {
        final url = await ref.getDownloadURL();
        urls.add(url);
      }
      
      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() => isLoading = true);

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref('gallery/${widget.category['id']}/$fileName');
      
      await ref.putFile(File(image.path));
      final String downloadUrl = await ref.getDownloadURL();
      
      setState(() {
        imageUrls.add(downloadUrl);
        isLoading = false;
      });
      
      _showSnackBar('Gambar berhasil ditambahkan', Colors.green);
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Gagal menambahkan gambar', Colors.red);
    }
  }

  Future<void> _deleteImage(String imageUrl, int index) async {
    final bool? confirmed = await _showDeleteDialog();
    if (confirmed != true) return;

    try {
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      
      setState(() {
        imageUrls.removeAt(index);
      });
      
      _showSnackBar('Gambar berhasil dihapus', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal menghapus gambar', Colors.red);
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Gambar'),
        content: const Text('Apakah Anda yakin ingin menghapus gambar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.category['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.category['color'],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildImageGrid()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        backgroundColor: widget.category['color'],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.category['color'],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              widget.category['logo'],
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${imageUrls.length} Gambar',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (imageUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada gambar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan gambar pertama',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return _buildImageCard(index);
        },
      ),
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _deleteImage(imageUrls[index], index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}