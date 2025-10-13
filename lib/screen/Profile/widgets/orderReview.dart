import 'package:client/backend_services/order_services.dart';
import 'package:client/backend_services/productDetails_service.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Orderreview extends StatefulWidget {
  final String userId;
  const Orderreview({super.key, required this.userId});

  @override
  State<Orderreview> createState() => _OrderreviewState();
}

class _OrderreviewState extends State<Orderreview> {
  late Future<List<dynamic>> _userOrdersFuture;
  final OrderService _orderService = OrderService();
  final ProductDetailsService _productService = ProductDetailsService();

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: "en_IN",
    symbol: "₹",
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _userOrdersFuture = _orderService.getOrdersByUser(widget.userId);
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  double _getProgress(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.2;
      case 'processing':
        return 0.4;
      case 'shipped':
        return 0.7;
      case 'delivered':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }

  // Helper widget for product image
  Widget _buildProductImage(String? imageUrl) {
    const double size = 50;
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
          errorBuilder: (context, error, stackTrace) => Container(
            width: size,
            height: size,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
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

  // Fetch product details safely
  Future<Map<String, dynamic>> _fetchProductDetail(String? productId) async {
    if (productId == null || productId.isEmpty) return {};
    try {
      final data = await _productService.fetchProductDetails(productId);
      if (data is Map<String, dynamic>) return data;
      return {};
    } catch (e) {
      print('Error fetching product $productId: $e');
      return {};
    }
  }

  String _getId(dynamic field) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) {
      if (field.containsKey('\$oid')) return field['\$oid'] ?? '';
      for (var value in field.values) {
        final id = _getId(value);
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Orders'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index] as Map<String, dynamic>? ?? {};
              final status = (order['orderStatus'] as String?) ?? 'unknown';
              final totalItems = (order['items'] as List?)?.length ?? 0;
              final totalPrice = (order['totalPrice'] as num?) ?? 0;
              final orderNumber = (order['orderNumber'] as String?) ?? 'N/A';
              final items = List<Map<String, dynamic>>.from(
                order['items'] ?? [],
              );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order header
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Order: $orderNumber',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Items: $totalItems, Total Price: ${currencyFormatter.format(totalPrice)}',
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _getProgress(status),
                        color: _getStatusColor(status),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),

                      // Order Items
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: Future.wait(
                          items.map((item) async {
                            final productId = _getId(
                              item['productID'] ?? item['product'] ?? '',
                            );
                            final productDetail = await _fetchProductDetail(
                              productId,
                            );
                            String imageUrl = '';
                            if (productDetail['images'] != null &&
                                productDetail['images'] is List) {
                              final images = productDetail['images'] as List;
                              if (images.isNotEmpty) {
                                imageUrl =
                                    (images[0]
                                        as Map<String, dynamic>)['url'] ??
                                    '';
                              }
                            }
                            return {
                              'id': productId,
                              'name':
                                  productDetail['name'] ??
                                  item['productName'] ??
                                  'Unnamed Product',
                              'quantity': item['quantity'] ?? 1,
                              'price':
                                  productDetail['price'] ?? item['price'] ?? 0,
                              'image': imageUrl,
                            };
                          }),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final orderItems = snapshot.data ?? [];
                          return Column(
                            children: orderItems.map((product) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        productId: product['id'] ?? '',
                                        customerId: widget.userId,
                                        customerName: 'Customer Name',
                                        customerEmail: 'customer@example.com',
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: _buildProductImage(product['image']),
                                  title: Text(product['name']),
                                  subtitle: Text(
                                    'Qty: ${product['quantity']} | Price: ${currencyFormatter.format(product['price'])}',
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Safe first element extension
extension FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
