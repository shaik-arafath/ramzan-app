import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/sunnah_product.dart';

class WishlistProvider with ChangeNotifier {
  final List<dynamic> _wishlist = [];

  List<dynamic> get wishlist => List.unmodifiable(_wishlist);
  int get itemCount => _wishlist.length;
  
  bool isInWishlist(dynamic product) {
    final productId = product is SunnahProduct ? product.id : product.id;
    return _wishlist.any((item) {
      final itemId = item is SunnahProduct ? item.id : item.id;
      return itemId == productId;
    });
  }

  void addItem(dynamic product) {
    if (!isInWishlist(product)) {
      _wishlist.add(product);
      notifyListeners();
    }
  }

  void removeItem(dynamic product) {
    final productId = product is SunnahProduct ? product.id : product.id;
    _wishlist.removeWhere((item) {
      final itemId = item is SunnahProduct ? item.id : item.id;
      return itemId == productId;
    });
    notifyListeners();
  }

  void clear() {
    _wishlist.clear();
    notifyListeners();
  }

  void toggleItem(dynamic product) {
    if (isInWishlist(product)) {
      removeItem(product);
    } else {
      addItem(product);
    }
  }
}
