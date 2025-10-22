import 'package:flutter/material.dart';

class OrderSelectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Map<String, dynamic>? selectedOrder;
  final Function(Map<String, dynamic>?) onOrderSelected;

  const OrderSelectionWidget({
    super.key,
    required this.orders,
    required this.selectedOrder,
    required this.onOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.deepOrange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Select Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedOrder,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Choose an order',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: orders.map((order) {
                return DropdownMenuItem(
                  value: order,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Order ${order['orderNumber']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: onOrderSelected,
              validator: (value) {
                if (value == null) {
                  return 'Please select an order';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
