import 'package:client/screen/Checkout/unified_checkout.dart';
import 'package:flutter/material.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';
import 'package:client/backend_services/cart_services.dart';

class ProductCardWithBuyNow extends StatelessWidget {
  final Map<String, dynamic> product;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final VoidCallback? onAddToCart;

  const ProductCardWithBuyNow({
    super.key,
    required this.product,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final price = product['offerPrice'] ?? product['price'];
    final originalPrice = product['price'];
    final hasDiscount =
        product['offerPrice'] != null && originalPrice > product['offerPrice'];
    final discountPercentage = hasDiscount
        ? ((originalPrice - product['offerPrice']) / originalPrice * 100)
              .round()
        : 0;
    final isOutOfStock = (product['stock'] ?? 0) <= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProductDetails(context),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                    ),
                    child:
                        product['images'] != null &&
                            product['images'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              product['images'][0]['url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),

                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Out of Stock Overlay
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] ?? 'Product Name',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating (if available)
                  if (product['rating'] != null)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index <
                                    (product['rating']['averageRating'] ?? 0)
                                        .floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '(${product['rating']['totalReviews'] ?? 0})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // Price
                  Row(
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Action Buttons
                  Row(
                    children: [
                      // Add to Cart Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isOutOfStock
                              ? null
                              : () => _addToCart(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isOutOfStock ? Colors.grey : Colors.blue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isOutOfStock ? 'No Stock' : 'Add',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOutOfStock ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Buy Now Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isOutOfStock
                              ? null
                              : () => _buyNow(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock
                                ? Colors.grey
                                : Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: product['_id'],
          customerId: customerId,
          customerName: customerName,
          customerEmail: customerEmail,
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      final success = await CartService.addToCart(
        customerId,
        product['_id'],
        1,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Added to cart successfully!' : 'Failed to add to cart',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }

      // Call the callback if provided
      if (success && onAddToCart != null) {
        onAddToCart!();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _buyNow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedCheckout.buyNow(
          userId: customerId,
          productData: product,
          quantity: 1,
          customerName: customerName,
          customerEmail: customerEmail,
        ),
      ),
    );
  }
}
