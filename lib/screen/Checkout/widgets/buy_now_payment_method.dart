import 'package:flutter/material.dart';

class BuyNowPaymentMethod extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const BuyNowPaymentMethod({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
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
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Pay when you receive the product'),
              value: 'cod',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                onPaymentMethodChanged(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Online Payment'),
              subtitle: const Text('Pay now using card/UPI'),
              value: 'online',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                onPaymentMethodChanged(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
