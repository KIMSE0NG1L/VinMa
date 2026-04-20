class WardrobeProduct {
  const WardrobeProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.size,
    required this.imageUrl,
    required this.currentPrice,
    required this.status,
  });

  final String id;
  final String name;
  final String brand;
  final String size;
  final String imageUrl;
  final int currentPrice;
  final String status;

  factory WardrobeProduct.fromJson(Map<String, dynamic> json) {
    return WardrobeProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      size: json['size'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}

class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.status,
    required this.purchasePrice,
    required this.estimatedResalePrice,
    required this.liquidityScore,
    required this.createdAt,
    required this.product,
  });

  final String id;
  final String status;
  final int purchasePrice;
  final int? estimatedResalePrice;
  final int? liquidityScore;
  final DateTime? createdAt;
  final WardrobeProduct product;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      purchasePrice: (json['purchasePrice'] as num?)?.toInt() ?? 0,
      estimatedResalePrice: (json['estimatedResalePrice'] as num?)?.toInt(),
      liquidityScore: (json['liquidityScore'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      product: WardrobeProduct.fromJson(
        (json['product'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}
