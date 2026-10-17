import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.mediumBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mediumBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.orderStatus),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.orderStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order Date: ${DateFormat('dd MMM yyyy').format(order.createdAt)}',
                    style: const TextStyle(color: AppColors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Status
            _buildSectionCard(
              'Payment Status',
              Row(
                children: [
                  Icon(
                    _getPaymentIcon(order.paymentStatus),
                    color: _getPaymentColor(order.paymentStatus),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    order.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: _getPaymentColor(order.paymentStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tracking Section
            if (order.trackingStatus != null) ...[
              _buildSectionCard(
                'Order Tracking',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrackingStep('Order Placed', true),
                    _buildTrackingStep('Payment Confirmed', order.paymentStatus == 'Confirmed'),
                    _buildTrackingStep('Packed', order.trackingStatus == 'packed'),
                    _buildTrackingStep('Out for Delivery', order.trackingStatus == 'out_for_delivery'),
                    _buildTrackingStep('Delivered', order.trackingStatus == 'delivered'),
                    const SizedBox(height: 16),
                    if (order.currentLocation != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'Current Location: ${order.currentLocation}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                    if (order.estimatedDeliveryDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Text(
                            'Estimated Delivery: ${DateFormat('dd MMM yyyy').format(order.estimatedDeliveryDate!)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Shipping Address
            _buildSectionCard(
              'Shipping Address',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.shippingAddress.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress.phone,
                    style: const TextStyle(color: AppColors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress.fullAddress,
                    style: const TextStyle(color: AppColors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Items
            _buildSectionCard(
              'Order Items',
              Column(
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: AppColors.mediumBlack,
                                child: const Icon(Icons.image, color: AppColors.white70),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity}',
                                style: const TextStyle(color: AppColors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${(item.price * 83).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Price Summary
            _buildSectionCard(
              'Price Summary',
              Column(
                children: [
                  _buildPriceRow('Subtotal', order.totalAmount * 83),
                  _buildPriceRow('Shipping', 99),
                  const Divider(color: AppColors.lightBlack),
                  _buildPriceRow(
                    'Total',
                    order.grandTotal * 83,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white70,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isBold ? AppColors.gold : Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String label, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.gold : AppColors.lightBlack,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isCompleted ? Colors.white : AppColors.white70,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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

  Color _getPaymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }
}
