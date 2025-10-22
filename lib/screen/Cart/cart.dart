import 'package:client/backend_services/cart_services.dart';
import 'package:client/screen/Checkout/unified_checkout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat currencyFormatter = NumberFormat.currency(
  locale: "en_IN",
  symbol: "₹",
  decimalDigits: 2,
);

class CartScreen extends StatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? cartData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    setState(() => isLoading = true);
    final data = await CartService.getCart(widget.userId);
    if (!mounted) return;
    setState(() {
      cartData = data;
      isLoading = false;
    });
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (productId.isEmpty) return;
    final success = await CartService.updateCartItem(
      widget.userId,
      productId,
      quantity,
    );
    if (success && mounted) fetchCart();
  }

  Future<void> removeItem(String productId) async {
    if (productId.isEmpty) return;
    final success = await CartService.removeFromCart(widget.userId, productId);
    if (success && mounted) fetchCart();
  }

  Future<void> clearCart() async {
    final success = await CartService.clearCart(widget.userId);
    if (success && mounted) fetchCart();
  }

  double calculateTotal(List items) {
    double total = 0;
    for (var item in items) {
      total +=
          ((item['price'] as num?) ?? 0) * ((item['quantity'] as int?) ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final items = (cartData?['items'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // <-- removes back arrow
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: clearCart,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(
              child: Text(
                '🛒 Your cart is empty',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final product = item['productId'] is Map
                      ? item['productId']
                      : {
                          '_id': item['productId'] ?? '',
                          'name': 'Unknown Product',
                          'images': [],
                        };

                  final images = (product['images'] is List)
                      ? product['images']
                      : [];
                  final imageUrl = images.isNotEmpty
                      ? (images[0] is Map
                            ? images[0]['url'] ?? ''
                            : images[0].toString())
                      : null;

                  final quantity = (item['quantity'] ?? 0) as int;
                  final price = (item['price'] as num?)?.toDouble() ?? 0;
                  final totalPrice = price * quantity;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? 'Unnamed Product',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currencyFormatter.format(price),
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    // Decrease Quantity
                                    GestureDetector(
                                      onTap: quantity > 1
                                          ? () => updateQuantity(
                                              product['_id'] ?? '',
                                              quantity - 1,
                                            )
                                          : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: quantity > 1
                                              ? Colors.deepOrange
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    // Increase Quantity
                                    GestureDetector(
                                      onTap: () => updateQuantity(
                                        product['_id'] ?? '',
                                        quantity + 1,
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.deepOrange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Total & Delete
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    removeItem(product['_id'] ?? ''),
                              ),
                              Text(
                                currencyFormatter.format(totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${currencyFormatter.format(calculateTotal(items))}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UnifiedCheckout.cart(
                            userId: widget.userId,
                            cartData: cartData,
                          ),
                        ),
                      );
                      // Refresh the cart after returning from Checkout
                      fetchCart();
                    },

                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
