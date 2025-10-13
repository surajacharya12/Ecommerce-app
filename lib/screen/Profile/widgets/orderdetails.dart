import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/backend_services/productDetails_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderData});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ProductDetailsService _productService = ProductDetailsService();
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: "en_IN",
    symbol: "₹",
    decimalDigits: 2,
  );

  late List<Map<String, dynamic>> _orderItems;

  @override
  void initState() {
    super.initState();
    _orderItems = List<Map<String, dynamic>>.from(
      widget.orderData['items'] ?? [],
    );
  }

  Future<Map<String, dynamic>> _fetchProductDetail(String? productId) async {
    if (productId == null || productId.isEmpty) return {};
    try {
      final productDetail = await _productService.fetchProductDetails(
        productId,
      );
      return productDetail;
    } catch (e) {
      print('Error fetching product details for ID $productId: $e');
      return {};
    }
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

  Widget _buildProductImage(String? imageUrl) {
    const double size = 60;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size,
              height: size,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  String getId(dynamic field) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) {
      if (field.containsKey('\$oid')) return field['\$oid'] ?? '';
      for (var value in field.values) {
        final id = getId(value);
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber = (widget.orderData['orderNumber'] as String?) ?? 'N/A';
    final totalPrice = (widget.orderData['totalPrice'] as num?) ?? 0;
    final orderStatus =
        (widget.orderData['orderStatus'] as String?) ?? 'pending';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order: $orderNumber'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Order Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Items: ${_orderItems.length}'),
                      Text(
                        'Total Price: ${currencyFormatter.format(totalPrice)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Status: '),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(orderStatus).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          orderStatus.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(orderStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Order Items
          ..._orderItems.map((item) {
            final productId = getId(
              item['productID'] ?? item['productId'] ?? item['product'] ?? '',
            );

            return FutureBuilder<Map<String, dynamic>>(
              future: productId.isNotEmpty
                  ? _fetchProductDetail(productId)
                  : Future.value({}),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final productData = snapshot.data ?? {};
                final productName =
                    productData['name'] ??
                    item['productName'] ??
                    'Unnamed Product';
                final quantity = item['quantity'] ?? 1;
                final price = productData['price'] ?? item['price'] ?? 0;

                String imageUrl = '';
                if (productData['images'] != null &&
                    productData['images'] is List) {
                  final images = productData['images'] as List;
                  if (images.isNotEmpty) {
                    imageUrl = (images[0] as Map<String, dynamic>)['url'] ?? '';
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: _buildProductImage(imageUrl),
                    title: Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Price: ${currencyFormatter.format(price)} | Qty: $quantity',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// Extension helper for safe first element access (optional)
extension FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
