class SlideshowItem {
  final String id;
  final String imageUrl;
  final bool isActive;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SlideshowItem({
    required this.id,
    required this.imageUrl,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SlideshowItem.fromJson(Map<String, dynamic> json) {
    return SlideshowItem(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  SlideshowItem copyWith({
    String? id,
    String? imageUrl,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SlideshowItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideshowItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SlideshowItem{id: $id, isActive: $isActive, order: $order}';
  }
}