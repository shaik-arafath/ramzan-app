import 'product.dart';
import 'sunnah_product.dart';

class CartItem {
  final dynamic product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice {
    if (product is SunnahProduct) {
      return (product as SunnahProduct).price * quantity;
    }
    return (product as Product).price * quantity;
  }

  String get productName {
    if (product is SunnahProduct) {
      return (product as SunnahProduct).name;
    }
    return (product as Product).name;
  }

  String get productImageUrl {
    if (product is SunnahProduct) {
      return (product as SunnahProduct).imageUrl;
    }
    return (product as Product).imageUrl;
  }

  double get productPrice {
    if (product is SunnahProduct) {
      return (product as SunnahProduct).price;
    }
    return (product as Product).price;
  }

  CartItem copyWith({
    dynamic product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
