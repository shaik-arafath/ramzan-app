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
      await _supabase.from('orders').update({'order_status': newStatus}).eq('id', orderId);
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

  Future<void> _confirmPayment(String orderId) async {
    try {
      await _supabase.from('orders').update({'payment_status': 'Confirmed'}).eq('id', orderId);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment confirmed'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming payment: $e')),
        );
      }
    }
  }

  Future<void> _rejectPayment(String orderId) async {
    try {
      await _supabase.from('orders').update({'payment_status': 'Rejected'}).eq('id', orderId);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment rejected'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting payment: $e')),
        );
      }
    }
  }

  Future<void> _updateTracking(String orderId, String trackingStatus, String? location, DateTime? deliveryDate) async {
    try {
      await _supabase.from('orders').update({
        'tracking_status': trackingStatus,
        'current_location': location,
        'estimated_delivery_date': deliveryDate?.toIso8601String(),
      }).eq('id', orderId);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking updated'), backgroundColor: Color(0xFFE8B931)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating tracking: $e')),
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
                            color: _getStatusColor(order['order_status'] ?? 'pending'),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order['order_status']?.toUpperCase() ?? 'PENDING',
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      'Payment Status: ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      order['payment_status']?.toUpperCase() ?? 'PENDING',
                                      style: TextStyle(
                                        color: order['payment_status'] == 'Confirmed'
                                            ? Colors.green
                                            : order['payment_status'] == 'Rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Payment confirmation section
                                if (order['payment_status'] == 'Pending') ...[
                                  const Text(
                                    'Confirm Payment:',
                                    style: TextStyle(color: Color(0xFFE8B931), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _confirmPayment(order['id']),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Confirm'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _rejectPayment(order['id']),
                                        icon: const Icon(Icons.close, size: 16),
                                        label: const Text('Reject'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                
                                // Order status section
                                const Text(
                                  'Order Status:',
                                  style: TextStyle(color: Color(0xFFE8B931), fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildStatusButton(order['id'], 'Pending', order['order_status']),
                                    _buildStatusButton(order['id'], 'Processing', order['order_status']),
                                    _buildStatusButton(order['id'], 'Shipped', order['order_status']),
                                    _buildStatusButton(order['id'], 'Delivered', order['order_status']),
                                    _buildStatusButton(order['id'], 'Cancelled', order['order_status']),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Tracking section
                                if (order['order_status'] == 'Processing' || order['order_status'] == 'Shipped') ...[
                                  const Text(
                                    'Tracking Info:',
                                    style: TextStyle(color: Color(0xFFE8B931), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _buildTrackingButton(order['id'], 'Packed', order['tracking_status']),
                                      _buildTrackingButton(order['id'], 'Out for Delivery', order['tracking_status']),
                                      _buildTrackingButton(order['id'], 'Delivered', order['tracking_status']),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Current Location',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onSubmitted: (value) {
                                      _updateTracking(order['id'], order['tracking_status'] ?? 'pending', value, null);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 30)),
                                      );
                                      if (date != null) {
                                        _updateTracking(order['id'], order['tracking_status'] ?? 'pending', order['current_location'], date);
                                      }
                                    },
                                    child: const Text('Set Delivery Date'),
                                  ),
                                ],
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

  Widget _buildTrackingButton(String orderId, String status, String? currentStatus) {
    final isSelected = currentStatus?.toLowerCase() == status.toLowerCase();
    return ElevatedButton(
      onPressed: isSelected ? null : () => _updateTracking(orderId, status.toLowerCase(), null, null),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : const Color(0xFF0A1628),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE8B931)),
        minimumSize: const Size(80, 32),
      ),
      child: Text(status),
    );
  }
}
