import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Checkout/checkout.dart'; // for DeliveryMethod + currencyFormatter

class OrderSummaryCard extends StatelessWidget {
  final Map<String, dynamic> orderSummary;
  final DeliveryMethod? selectedDelivery;

  /// Function to get delivery fee
  final double Function()? getDeliveryFee;

  const OrderSummaryCard({
    super.key,
    required this.orderSummary,
    required this.selectedDelivery,
    this.getDeliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    final items = orderSummary['items'] as List;
    final subtotal = orderSummary['subtotal'] as double;
    final total = orderSummary['total'] as double;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: const [
              Text(
                '📋 Order Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 20),

          // Item list
          Column(
            children: items.map((item) {
              final price = (item['price'] as num) * (item['quantity'] as int);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1e293b),
                          ),
                        ),
                        Text(
                          'Qty: ${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormatter.format(price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Totals
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFf1f5f9), width: 2),
              ),
            ),
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                _summaryRow("Subtotal:", currencyFormatter.format(subtotal)),
                const SizedBox(height: 8),
                _summaryRow(
                  "Delivery:",
                  selectedDelivery != null
                      ? currencyFormatter.format(getDeliveryFee?.call() ?? 0)
                      : 'Select delivery method',
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  "Total:",
                  currencyFormatter.format(total),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? const Color(0xFF1e293b) : const Color(0xFF64748b),
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1e293b),
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
