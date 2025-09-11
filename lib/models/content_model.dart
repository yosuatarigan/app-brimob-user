class ContentModel {
  final String id;
  final String title;
  final String content;
  final List<String> images;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String icon;

  ContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.icon,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map, String id) {
    return ContentModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isPublic: map['isPublic'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      category: map['category'] ?? '',
      icon: map['icon'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'images': images,
      'isPublic': isPublic,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'category': category,
      'icon': icon,
    };
  }
}

class GaleriModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int order;
  final String logoUrl;

  GaleriModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.order,
    required this.logoUrl,
  });

  factory GaleriModel.fromMap(Map<String, dynamic> map, String id) {
    return GaleriModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      order: map['order'] ?? 0,
      logoUrl: map['logoUrl'] ?? '',
    );
  }
}

