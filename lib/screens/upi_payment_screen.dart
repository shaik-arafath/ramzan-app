import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';

class UpipaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;

  const UpipaymentScreen({
    super.key,
    required this.totalAmount,
    required this.orderId,
  });

  @override
  State<UpipaymentScreen> createState() => _UpipaymentScreenState();
}

class _UpipaymentScreenState extends State<UpipaymentScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _paymentScreenshot;
  bool _isUploading = false;

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentScreenshot = File(image.path);
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_paymentScreenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload payment screenshot')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // TODO: Upload screenshot to Supabase storage and update order
    // For now, just navigate to payment processing screen
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentProcessingScreen(
            orderId: widget.orderId,
            totalAmount: widget.totalAmount,
          ),
        ),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        title: const Text('UPI Payment'),
        backgroundColor: AppColors.mediumBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount to pay
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mediumBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount to Pay',
                    style: TextStyle(color: AppColors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${(widget.totalAmount * 83).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code / Scanner section
            const Text(
              'Scan QR Code to Pay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.mediumBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBlack),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/AccountQRCodeState Bank of India - 9292_DARK_THEME.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // UPI ID
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mediumBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UPI ID',
                    style: TextStyle(color: AppColors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'yourupi@paytm', // Replace with actual UPI ID
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.gold),
                        onPressed: () {
                          // Copy UPI ID
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload screenshot section
            const Text(
              'Upload Payment Screenshot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickScreenshot,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.mediumBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _paymentScreenshot != null
                        ? AppColors.gold
                        : AppColors.lightBlack,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _paymentScreenshot != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              _paymentScreenshot!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _paymentScreenshot = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 48, color: AppColors.gold),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload',
                              style: TextStyle(color: AppColors.white70),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Submit Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
