import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Assuming ProductData is a type alias for a Map or a defined class
typedef ProductData = Map<String, dynamic>;

final NumberFormat currencyFormatter = NumberFormat.currency(
  locale: "en_IN", // Indian locale
  symbol: "₹", // Indian Rupee symbol
  decimalDigits: 2,
);

class ProductCard extends StatelessWidget {
  final ProductData product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product['price'];
    final offerPrice = product['offerPrice'];
    final displayPrice = offerPrice ?? price;
    final formattedPrice = displayPrice != null
        ? currencyFormatter.format(displayPrice)
        : 'N/A';

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: product['images'] != null && product['images'].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(product['images'][0]['url']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product['images'] == null || product['images'].isEmpty
                ? Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      ' ${product['rating']?['averageRating']?.toStringAsFixed(1) ?? '0.0'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

class GridProductCard extends StatelessWidget {
  final ProductData product;

  const GridProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'Unknown Product';
    final price = product['price'];
    final offerPrice = product['offerPrice'];
    final displayPrice = offerPrice ?? price;
    final rating =
        product['rating']?['averageRating']?.toStringAsFixed(1) ?? '0.0';
    final imageUrl = product['images'] != null && product['images'].isNotEmpty
        ? product['images'][0]['url']
        : null;

    final formattedPrice = displayPrice != null
        ? currencyFormatter.format(displayPrice)
        : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    )
                  : null,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(
                        ' $rating',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
