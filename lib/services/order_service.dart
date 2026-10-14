import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class OrderService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Order>> fetchOrders() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((row) => Order.fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<Order?> createOrder(Order order) async {
    try {
      final response = await _client
          .from('orders')
          .insert(order.toMap())
          .select()
          .single();

      // Calculate estimated delivery (5-7 business days)
      final estimatedDelivery = DateTime.now().add(const Duration(days: 7));
      await _client
          .from('orders')
          .update({'estimated_delivery': estimatedDelivery.toIso8601String()})
          .eq('id', response['id']);

      return Order.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _client
          .from('orders')
          .update({'order_status': status})
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}
