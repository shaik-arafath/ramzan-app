import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((row) => Product.fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      if (category == 'All') {
        return fetchProducts();
      }

      final response = await _client
          .from('products')
          .select('*')
          .eq('category', category)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((row) => Product.fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client
          .from('products')
          .select('category');

      final data = response as List<dynamic>;
      final categories = data.map((row) => row['category'] as String).toSet().toList();
      categories.sort();
      return ['All', ...categories];
    } catch (e) {
      print('Error fetching categories: $e');
      return ['All'];
    }
  }
}
