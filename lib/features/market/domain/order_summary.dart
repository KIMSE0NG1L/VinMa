class OrderProductSummary {
  const OrderProductSummary({
    required this.id,
    required this.name,
    required this.brand,
    required this.size,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String brand;
  final String size;
  final String imageUrl;

  factory OrderProductSummary.fromJson(Map<String, dynamic> json) {
    return OrderProductSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      size: json['size'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class OrderLineItemSummary {
  const OrderLineItemSummary({
    required this.id,
    required this.price,
    required this.product,
  });

  final String id;
  final int price;
  final OrderProductSummary product;

  factory OrderLineItemSummary.fromJson(Map<String, dynamic> json) {
    return OrderLineItemSummary(
      id: json['id'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      product: OrderProductSummary.fromJson(
        (json['product'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.receiverName,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String status;
  final int totalPrice;
  final String receiverName;
  final DateTime? createdAt;
  final List<OrderLineItemSummary> items;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      receiverName: json['receiverName'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      items: ((json['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(OrderLineItemSummary.fromJson)
          .toList(),
    );
  }
}

class OrderTrackingStep {
  const OrderTrackingStep({
    required this.title,
    required this.completed,
  });

  final String title;
  final bool completed;

  factory OrderTrackingStep.fromJson(Map<String, dynamic> json) {
    return OrderTrackingStep(
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class OrderTrackingData {
  const OrderTrackingData({
    required this.orderId,
    required this.carrier,
    required this.trackingNumber,
    required this.steps,
  });

  final String orderId;
  final String carrier;
  final String trackingNumber;
  final List<OrderTrackingStep> steps;

  factory OrderTrackingData.fromJson(Map<String, dynamic> json) {
    return OrderTrackingData(
      orderId: json['orderId'] as String? ?? '',
      carrier: json['carrier'] as String? ?? '',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      steps: ((json['steps'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(OrderTrackingStep.fromJson)
          .toList(),
    );
  }
}
