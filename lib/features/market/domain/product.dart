class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.condition,
    required this.imageUrl,
    required this.brand,
    required this.size,
    this.description = '상태, 실루엣, 착용성을 기준으로 선별한 빈티지 아이템입니다.',
    this.isLiked = false,
  });

  final int id;
  final String name;
  final int price;
  final String category;
  final String condition;
  final String imageUrl;
  final String brand;
  final String size;
  final String description;
  final bool isLiked;

  Product copyWith({bool? isLiked}) {
    return Product(
      id: id,
      name: name,
      price: price,
      category: category,
      condition: condition,
      imageUrl: imageUrl,
      brand: brand,
      size: size,
      description: description,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Product copyWithDetails({
    String? name,
    int? price,
    String? category,
    String? condition,
    String? imageUrl,
    String? brand,
    String? size,
    String? description,
    bool? isLiked,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      description: description ?? this.description,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
