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
  final String? paymentScreenshot;
  final String? trackingStatus; // packed, out_for_delivery, delivered
  final String? currentLocation;
  final DateTime? estimatedDeliveryDate;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.totalAmount,
    required this.shippingCost,
    this.paymentMethod = 'UPI',
    this.paymentStatus = 'Pending',
    this.orderStatus = 'Pending',
    required this.createdAt,
    this.estimatedDelivery,
    this.paymentScreenshot,
    this.trackingStatus,
    this.currentLocation,
    this.estimatedDeliveryDate,
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
      paymentMethod: map['payment_method'] as String? ?? 'UPI',
      paymentStatus: map['payment_status'] as String? ?? 'Pending',
      orderStatus: map['order_status'] as String? ?? 'Pending',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      estimatedDelivery: map['estimated_delivery'] != null
          ? DateTime.tryParse(map['estimated_delivery'] as String)
          : null,
      paymentScreenshot: map['payment_screenshot'] as String?,
      trackingStatus: map['tracking_status'] as String?,
      currentLocation: map['current_location'] as String?,
      estimatedDeliveryDate: map['estimated_delivery_date'] != null
          ? DateTime.tryParse(map['estimated_delivery_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'user_id': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'shipping_address': shippingAddress.toMap(),
      'total_amount': totalAmount,
      'shipping_cost': shippingCost,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'payment_screenshot': paymentScreenshot,
      'tracking_status': trackingStatus,
      'current_location': currentLocation,
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
    };

    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
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
