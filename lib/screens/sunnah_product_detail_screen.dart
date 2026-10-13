import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sunnah_product.dart';
import '../data/sunnah_products_data_sample.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_image.dart';
import 'login_screen.dart';

class SunnahProductDetailScreen extends StatelessWidget {
  final SunnahProduct product;

  const SunnahProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.darkBlack,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    source: product.imageUrl,
                    fit: BoxFit.cover,
                    iconSize: 80,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Wishlist Button
              IconButton(
                icon: Icon(
                  wishlistProvider.isInWishlist(product)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: wishlistProvider.isInWishlist(product)
                      ? Colors.red
                      : Colors.white,
                ),
                onPressed: () {
                  wishlistProvider.toggleItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wishlistProvider.isInWishlist(product)
                            ? '${product.name} added to wishlist'
                            : '${product.name} removed from wishlist',
                      ),
                      backgroundColor: AppColors.mediumBlack,
                    ),
                  );
                },
              ),
            ],
          ),
          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rating and Stock
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFE8B931), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.inventory_2_outlined,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
                        style: TextStyle(
                          color: product.stock > 0 ? Colors.white70 : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Islamic Evidence Section
                  _buildIslamicEvidenceCard(),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category Info
                  _buildCategoryInfo(),
                  const SizedBox(height: 32),
                  // Add to Cart Button
                  Consumer2<CartProvider, AuthProvider>(
                    builder: (context, cartProvider, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: product.stock > 0
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
                                  cartProvider.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to cart'),
                                      backgroundColor: AppColors.mediumBlack,
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: product.stock > 0
                                ? AppColors.gold
                                : Colors.grey,
                            foregroundColor: Colors.black,
                            elevation: 8,
                            shadowColor: AppColors.gold.withOpacity(0.5),
                          ),
                          child: Text(
                            product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Buy Now Button
                  Consumer2<CartProvider, AuthProvider>(
                    builder: (context, cartProvider, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: product.stock > 0
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

                                  // Add to cart and navigate
                                  cartProvider.addItem(product);
                                  Navigator.pushNamed(context, '/cart');
                                }
                              : null,
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicEvidenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mediumBlack,
            AppColors.darkBlack,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                color: AppColors.gold,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Islamic Evidence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Confidence Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(
                int.parse(product.confidenceColor.replaceAll('#', '0xFF')),
              ).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(
                  int.parse(product.confidenceColor.replaceAll('#', '0xFF')),
                ),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Color(
                    int.parse(product.confidenceColor.replaceAll('#', '0xFF')),
                  ),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  product.confidenceLevel,
                  style: TextStyle(
                    color: Color(
                      int.parse(product.confidenceColor.replaceAll('#', '0xFF')),
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Islamic Basis
          Text(
            'Source: ${product.islamicBasis}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Evidence Text
          Text(
            product.evidence,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: const Color(0xFFE8B931),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.subcategory,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
