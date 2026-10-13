import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('orders')
          .select('*, user_profiles(full_name)')
          .order('created_at', ascending: false);
      setState(() => _orders = response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('orders').update({'status': newStatus}).eq('id', orderId);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated'), backgroundColor: Color(0xFFE8B931)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8B931)))
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final userName = order['user_profiles']?['full_name'] ?? 'Unknown';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: const Color(0xFF1E3A5F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE8B931), width: 0.5),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(order['status'] ?? 'pending'),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          'Order #${order['id'].toString().substring(0, 8)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '\$${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(color: Color(0xFFE8B931), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status'] ?? 'pending'),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order['status']?.toUpperCase() ?? 'PENDING',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        children: [
                          const Divider(color: Color(0xFFE8B931)),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Date: ${order['created_at']?.toString().split('T')[0] ?? ''}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                if (order['shipping_address'] != null)
                                  Text(
                                    'Shipping Address: ${order['shipping_address']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                const SizedBox(height: 8),
                                if (order['payment_method'] != null)
                                  Text(
                                    'Payment Method: ${order['payment_method']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Update Status:',
                                  style: TextStyle(color: Color(0xFFE8B931), fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildStatusButton(order['id'], 'Pending', order['status']),
                                    _buildStatusButton(order['id'], 'Processing', order['status']),
                                    _buildStatusButton(order['id'], 'Shipped', order['status']),
                                    _buildStatusButton(order['id'], 'Delivered', order['status']),
                                    _buildStatusButton(order['id'], 'Cancelled', order['status']),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusButton(String orderId, String status, String? currentStatus) {
    final isSelected = currentStatus?.toLowerCase() == status.toLowerCase();
    return ElevatedButton(
      onPressed: isSelected ? null : () => _updateOrderStatus(orderId, status.toLowerCase()),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? _getStatusColor(status) : const Color(0xFF0A1628),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE8B931)),
        minimumSize: const Size(80, 32),
      ),
      child: Text(status),
    );
  }
}
