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
          .select('id, user_id, items, shipping_address, total_amount, shipping_cost, payment_method, payment_status, order_status, created_at, estimated_delivery, payment_screenshot, tracking_status, current_location, estimated_delivery_date')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      final orders = <Order>[];
      
      for (final row in data) {
        try {
          orders.add(Order.fromMap(row as Map<String, dynamic>));
        } catch (e) {
          print('Error parsing order: $e');
          print('Order data: $row');
        }
      }
      
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      print('Error type: ${e.runtimeType}');
      return [];
    }
  }

  Future<Order?> createOrder(Order order) async {
    try {
      print('Creating order with data: ${order.toMap(includeId: false)}');
      final response = await _client
          .from('orders')
          .insert(order.toMap(includeId: false))
          .select()
          .single();

      print('Order created successfully: $response');

      // Calculate estimated delivery (5-7 business days)
      final estimatedDelivery = DateTime.now().add(const Duration(days: 7));
      await _client
          .from('orders')
          .update({'estimated_delivery': estimatedDelivery.toIso8601String()})
          .eq('id', response['id']);

      return Order.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating order: $e');
      print('Error type: ${e.runtimeType}');
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
