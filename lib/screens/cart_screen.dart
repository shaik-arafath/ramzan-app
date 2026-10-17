import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../widgets/app_image.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';
import '../theme/app_colors.dart';
import 'address_selection_screen.dart';
import 'upi_payment_screen.dart';
import 'orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();
  Address? _selectedAddress;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadAddress();
  }

  Future<void> _checkAuthAndLoadAddress() async {
    // Refresh session to ensure we have the latest auth state
    await Supabase.instance.client.auth.refreshSession();
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    print('Cart screen - Current user ID: $userId');
    print('Cart screen - Current user: ${Supabase.instance.client.auth.currentUser}');
    if (userId != null && userId.isNotEmpty) {
      await _loadDefaultAddress();
    }
  }

  Future<void> _loadDefaultAddress() async {
    final defaultAddress = await _addressService.getDefaultAddress();
    if (mounted) {
      setState(() {
        _selectedAddress = defaultAddress;
      });
    }
  }

  Future<void> _proceedToCheckout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Check if user has an address
    if (_selectedAddress == null) {
      // Navigate to address selection
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddressSelectionScreen(),
        ),
      );
      if (result != null && result is Address) {
        setState(() {
          _selectedAddress = result;
        });
      } else {
        return;
      }
    }

    // Get current user ID
    final userId = Supabase.instance.client.auth.currentUser?.id;
    print('Current user ID: $userId');
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order')),
      );
      return;
    }

    // Create order object
    final orderItems = cartProvider.items.map((item) => OrderItem(
      productId: item.product.id,
      productName: item.productName,
      productImageUrl: item.productImageUrl,
      price: item.productPrice,
      quantity: item.quantity,
    )).toList();

    final order = Order(
      id: '',
      userId: userId,
      items: orderItems,
      shippingAddress: _selectedAddress!,
      totalAmount: cartProvider.totalAmount,
      shippingCost: 99 / 83, // Convert back to USD
      paymentMethod: 'UPI',
      paymentStatus: 'Pending',
      orderStatus: 'Pending',
      createdAt: DateTime.now(),
    );

    // Create order first
    setState(() => _isProcessing = true);

    try {
      final createdOrder = await _orderService.createOrder(order);

      if (createdOrder != null && mounted) {
        // Navigate to UPI payment screen with actual order ID
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UpipaymentScreen(
              totalAmount: cartProvider.totalAmount,
              orderId: createdOrder.id,
            ),
          ),
        );

        // Clear cart after payment
        cartProvider.clear();

        // Navigate to orders screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const OrdersScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppColors.mediumBlack,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index];
                    return _buildCartItem(context, cartItem, cartProvider);
                  },
                ),
              ),
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mediumBlack,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Selected Address
                    if (_selectedAddress != null)
                      Card(
                        color: AppColors.darkBlack,
                        child: ListTile(
                          leading: const Icon(Icons.location_on, color: AppColors.gold),
                          title: Text(_selectedAddress!.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(_selectedAddress!.fullAddress, style: const TextStyle(color: AppColors.white70, fontSize: 12)),
                          trailing: TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddressSelectionScreen(),
                                ),
                              );
                              if (result != null && result is Address) {
                                setState(() {
                                  _selectedAddress = result;
                                });
                              }
                            },
                            child: const Text('Change', style: TextStyle(color: AppColors.gold)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: AppColors.white70)),
                        Text('₹${(cartProvider.totalAmount * 83).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping', style: TextStyle(color: AppColors.white70)),
                        const Text('₹99', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const Divider(color: AppColors.lightBlack),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('₹${(cartProvider.totalAmount * 83 + 99).toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _proceedToCheckout,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('Confirm Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(
                source: cartItem.productImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                iconSize: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(cartItem.productPrice * 83).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: cartItem.quantity > 1
                            ? () {
                                cartProvider.updateQuantity(
                                  cartItem.product.id,
                                  cartItem.quantity - 1,
                                );
                              }
                            : null,
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: cartItem.quantity < cartItem.product.stock
                            ? () {
                                cartProvider.updateQuantity(
                                  cartItem.product.id,
                                  cartItem.quantity + 1,
                                );
                              }
                            : null,
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          cartProvider.removeItem(cartItem.product.id);
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
