import 'package:client/backend_services/order_services.dart';
import 'package:client/backend_services/product_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Shipping extends StatefulWidget {
  final String userId;
  const Shipping({super.key, required this.userId});

  @override
  State<Shipping> createState() => _ShippingState();
}

class _ShippingState extends State<Shipping> {
  late Future<List<dynamic>> _userOrdersFuture;
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

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

  void _cancelOrder(String orderId) async {
    try {
      await _orderService.cancelOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
      }
      setState(() {
        _userOrdersFuture = _orderService.getOrdersByUser(widget.userId);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
      }
    }
  }

  Widget _buildOrderProgressStepper(String currentStatus) {
    final statusList = ['Pending', 'Processing', 'Shipped', 'Delivered'];
    final statusIcons = {
      'pending': Icons.hourglass_empty,
      'processing': Icons.settings_outlined,
      'shipped': Icons.local_shipping,
      'delivered': Icons.check_circle_outline,
    };

    final currentStatusLower = currentStatus.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: statusList.map((status) {
          final statusLower = status.toLowerCase();
          final currentIndex = statusList.indexWhere(
            (s) => s.toLowerCase() == currentStatusLower,
          );
          final stepIndex = statusList.indexOf(status);
          final isCompleted = stepIndex < currentIndex;
          final isActive = stepIndex == currentIndex;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? _getStatusColor(statusLower)
                        : Colors.white,
                    border: Border.all(
                      color: isActive
                          ? _getStatusColor(statusLower)
                          : Colors.grey.shade400,
                      width: isActive ? 3 : 2,
                    ),
                  ),
                  child: Icon(
                    statusIcons[statusLower] ?? Icons.help_outline,
                    color: isCompleted || isActive ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                ),
                if (stepIndex < statusList.length - 1)
                  SizedBox(
                    height: 4,
                    width: double.infinity,
                    child: Container(
                      color: isCompleted
                          ? _getStatusColor(statusLower)
                          : Colors.grey.shade300,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive || isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isActive || isCompleted
                        ? _getStatusColor(statusLower)
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['orderStatus'] as String?) ?? 'unknown';
    final orderNumber = (order['orderNumber'] as String?) ?? 'N/A';
    final orderId = getId(order['_id']);
    final totalPrice = (order['totalPrice'] as num?) ?? 0;

    final items =
        (order['items'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        <Map<String, dynamic>>[];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: _getStatusColor(status)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Order: $orderNumber',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total Price: ${currencyFormatter.format(totalPrice)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            if (status.toLowerCase() == 'pending' ||
                status.toLowerCase() == 'processing')
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _cancelOrder(orderId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

            _buildOrderProgressStepper(status),
            const Divider(),

            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                final productId = getId(
                  item['productID'] ??
                      item['productId'] ??
                      item['product'] ??
                      '',
                );
                final fallbackName = item['productName'] ?? 'Unnamed Product';
                final quantity = item['quantity'] ?? 1;

                return FutureBuilder<Map<String, dynamic>?>(
                  future: productId.isNotEmpty
                      ? _productService.fetchProductById(productId)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(minHeight: 2),
                      );
                    }

                    Map<String, dynamic>? product = snapshot.data;

                    final name = product?['name'] ?? fallbackName;
                    String imageUrl = '';
                    if (product?['images'] != null &&
                        product!['images'] is List) {
                      final images = product['images'] as List;
                      if (images.isNotEmpty) {
                        imageUrl = images[0]['url'] ?? '';
                      }
                    }

                    final price = product?['price'] ?? item['price'] ?? 0;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            )
                          : const Icon(Icons.image),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Price: ₹${price.toStringAsFixed(2)} | Qty: $quantity',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
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
            padding: const EdgeInsets.all(8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = (orders[index] is Map)
                  ? Map<String, dynamic>.from(orders[index])
                  : <String, dynamic>{};
              if (order.isEmpty) return const SizedBox.shrink();
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }
}
