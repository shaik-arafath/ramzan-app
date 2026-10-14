import 'address.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final Address shippingAddress;
  final double totalAmount;
  final double shippingCost;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.totalAmount,
    required this.shippingCost,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    this.estimatedDelivery,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
        ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
        .toList() ?? [];

    return Order(
      id: map['id']?.toString() ?? '',
      userId: map['user_id'] as String? ?? '',
      items: itemsList,
      shippingAddress: Address.fromMap(map['shipping_address'] as Map<String, dynamic>),
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
      shippingCost: (map['shipping_cost'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'COD',
      paymentStatus: map['payment_status'] as String? ?? 'Pending',
      orderStatus: map['order_status'] as String? ?? 'Pending',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      estimatedDelivery: map['estimated_delivery'] != null
          ? DateTime.tryParse(map['estimated_delivery'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'shipping_address': shippingAddress.toMap(),
      'total_amount': totalAmount,
      'shipping_cost': shippingCost,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
    };
  }

  double get grandTotal => totalAmount + shippingCost;
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      productImageUrl: map['product_image_url'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  double get total => price * quantity;
}
