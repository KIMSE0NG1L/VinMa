class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.basePrice,
    required this.floorPrice,
    required this.category,
    required this.condition,
    required this.imageUrl,
    required this.brand,
    required this.size,
    required this.description,
    this.imageUrls = const [],
    this.ownerId,
    this.hashtags = const [],
    this.status = 'ACTIVE',
    this.isActive = true,
    this.viewCount = 0,
    this.passCount = 0,
    this.likeCount = 0,
    this.cartCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String name;
  final int price;
  final int basePrice;
  final int floorPrice;
  final String category;
  final String condition;
  final String imageUrl;
  final String brand;
  final String size;
  final String description;
  final List<String> imageUrls;
  final String? ownerId;
  final List<String> hashtags;
  final String status;
  final bool isActive;
  final int viewCount;
  final int passCount;
  final int likeCount;
  final int cartCount;
  final bool isLiked;

  int get priceDropAmount => basePrice > price ? basePrice - price : 0;
  bool get hasPriceDrop => priceDropAmount > 0;
  double get priceDropRate =>
      basePrice <= 0 || !hasPriceDrop ? 0 : priceDropAmount / basePrice;

  factory Product.fromJson(Map<String, dynamic> json) {
    final parsedImages = ((json['images'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((image) {
          final thumb = image['thumbUrl'] as String?;
          final large = image['largeUrl'] as String?;
          final original = image['originalUrl'] as String?;
          final source = image['imageUrl'] as String?;
          return thumb ?? large ?? original ?? source ?? '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
    final primaryImage = json['imageUrl'] as String? ?? '';
    final resolvedPrimaryImage = parsedImages.isNotEmpty
        ? parsedImages.first
        : primaryImage;

    return Product(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String?,
      name: json['name'] as String? ?? '',
      price: (json['currentPrice'] as num?)?.toInt() ?? 0,
      basePrice: (json['basePrice'] as num?)?.toInt() ?? 0,
      floorPrice: (json['floorPrice'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      imageUrl: resolvedPrimaryImage,
      brand: json['brand'] as String? ?? '',
      size: json['size'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrls: [
        if (resolvedPrimaryImage.isNotEmpty) resolvedPrimaryImage,
        ...parsedImages.where((url) => url != resolvedPrimaryImage),
      ],
      hashtags: ((json['hashtags'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      status: json['status'] as String? ?? 'ACTIVE',
      isActive: json['isActive'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      passCount: (json['passCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      cartCount: (json['cartCount'] as num?)?.toInt() ?? 0,
      isLiked:
          (json['likeCount'] as num?) != null &&
          ((json['likeCount'] as num).toInt() > 0),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    int? price,
    int? basePrice,
    int? floorPrice,
    String? category,
    String? condition,
    String? imageUrl,
    String? brand,
    String? size,
    String? description,
    List<String>? imageUrls,
    String? ownerId,
    List<String>? hashtags,
    String? status,
    bool? isActive,
    int? viewCount,
    int? passCount,
    int? likeCount,
    int? cartCount,
    bool? isLiked,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      basePrice: basePrice ?? this.basePrice,
      floorPrice: floorPrice ?? this.floorPrice,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId ?? this.ownerId,
      hashtags: hashtags ?? this.hashtags,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      passCount: passCount ?? this.passCount,
      likeCount: likeCount ?? this.likeCount,
      cartCount: cartCount ?? this.cartCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
