import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_image.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _sleeveLengthController = TextEditingController();
  final _lengthController = TextEditingController();
  final _neckController = TextEditingController();
  final _armLengthController = TextEditingController();
  final _inseamController = TextEditingController();
  final _thighController = TextEditingController();

  @override
  void dispose() {
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    _sleeveLengthController.dispose();
    _lengthController.dispose();
    _neckController.dispose();
    _armLengthController.dispose();
    _inseamController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              width: double.infinity,
              height: 300,
              child: AppImage(
                source: widget.product.imageUrl,
                fit: BoxFit.cover,
                iconSize: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.rating.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.product.stock} in stock)',
                        style: TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                    ),
                    child: Text(
                      widget.product.category,
                      style: const TextStyle(fontSize: 14, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Custom Measurements Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.mediumBlack,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.straighten, color: AppColors.gold),
                            const SizedBox(width: 8),
                            const Text(
                              'Your Measurements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We customize and stitch according to your measurements',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMeasurementField('Chest', _chestController),
                        _buildMeasurementField('Waist', _waistController),
                        _buildMeasurementField('Hips', _hipsController),
                        _buildMeasurementField('Shoulder', _shoulderController),
                        _buildMeasurementField('Sleeve Length', _sleeveLengthController),
                        _buildMeasurementField('Length', _lengthController),
                        _buildMeasurementField('Neck', _neckController),
                        _buildMeasurementField('Arm Length', _armLengthController),
                        _buildMeasurementField('Inseam', _inseamController),
                        _buildMeasurementField('Thigh', _thighController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Add to Cart Button
                  Consumer2<CartProvider, AuthProvider>(
                    builder: (context, cartProvider, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.product.stock > 0
                              ? () {
                                  // Check if user is logged in
                                  if (!authProvider.isAuthenticated) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LoginScreen(),
                                      ),
                                    );
                                    return;
                                  }

                                  // Add to cart
                                  cartProvider.addItem(widget.product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${widget.product.name} added to cart'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.mediumBlack,
                                    ),
                                  );
                                }
                              : null,
                          child: Text(
                            widget.product.stock > 0
                                ? 'Add to Cart - \$${widget.product.price.toStringAsFixed(2)}'
                                : 'Out of Stock',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.white70),
          suffixText: 'inches',
          suffixStyle: const TextStyle(color: AppColors.white70),
          filled: true,
          fillColor: AppColors.darkBlack,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBlack),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBlack),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
        ),
        style: const TextStyle(color: AppColors.white),
      ),
    );
  }
}
