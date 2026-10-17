import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentProcessingScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  String _status = 'Processing';
  String _message = 'Verifying your payment...';

  @override
  void initState() {
    super.initState();
    // Simulate payment verification
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _status = 'Pending Confirmation';
          _message = 'Payment received. Waiting for admin confirmation.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        title: const Text('Payment Status'),
        backgroundColor: AppColors.mediumBlack,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.mediumBlack,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
                child: Center(
                  child: _status == 'Processing'
                      ? const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                            strokeWidth: 4,
                          ),
                        )
                      : const Icon(
                          Icons.pending,
                          size: 60,
                          color: AppColors.gold,
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Status text
              Text(
                _status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                _message,
                style: const TextStyle(
                  color: AppColors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Order details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.mediumBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBlack),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Order ID', widget.orderId),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Amount',
                      '₹${(widget.totalAmount * 83).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.gold),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will receive a notification once your payment is confirmed by the admin.',
                        style: TextStyle(color: AppColors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // View orders button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/orders');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                  ),
                  child: const Text(
                    'View My Orders',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
