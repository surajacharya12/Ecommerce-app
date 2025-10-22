import 'package:flutter/material.dart';

class BuyNowProductSummary extends StatelessWidget {
  final Map<String, dynamic> productData;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;

  const BuyNowProductSummary({
    super.key,
    required this.productData,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      productData['images'] != null &&
                          productData['images'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            productData['images'][0]['url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 40);
                            },
                          ),
                        )
                      : const Icon(Icons.image, size: 40),
                ),
                const SizedBox(width: 16),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productData['name'] ?? 'Product Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: $quantity',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (selectedColor != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Color: $selectedColor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (selectedSize != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Size: $selectedSize',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '₹${(productData['offerPrice'] ?? productData['price']).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
