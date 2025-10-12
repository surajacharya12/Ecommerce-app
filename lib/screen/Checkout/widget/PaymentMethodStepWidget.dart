import 'package:flutter/material.dart';
import 'package:client/screen/Checkout/checkout.dart'; // Import enums

class PaymentMethodStepWidget extends StatelessWidget {
  final DeliveryMethod? selectedDelivery;
  final Map<String, dynamic>? selectedStore;
  final Function(PaymentMethod) onPaymentMethodSelect;
  final VoidCallback onBack;

  const PaymentMethodStepWidget({
    super.key,
    required this.selectedDelivery,
    required this.selectedStore,
    required this.onPaymentMethodSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                const SizedBox(width: 8),
                const Text(
                  "2. Choose Payment Method",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Delivery: ${selectedDelivery == DeliveryMethod.homeDelivery ? 'Home' : 'Store Pickup'}',
              ),
              subtitle: selectedStore != null
                  ? Text('Store: ${selectedStore!['name']}')
                  : null,
              leading: const Icon(Icons.local_shipping),
            ),
            const Divider(),
            RadioListTile<PaymentMethod>(
              title: const Text('Cash On Delivery'),
              value: PaymentMethod.cashOnDelivery,
              groupValue:
                  null, // Group value not needed here, selection triggers event
              onChanged: (val) => onPaymentMethodSelect(val!),
              secondary: const Icon(Icons.payments),
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('Online Payment (Card/UPI)'),
              value: PaymentMethod.onlinePayment,
              groupValue: null,
              onChanged: (val) => onPaymentMethodSelect(val!),
              secondary: const Icon(Icons.credit_card),
            ),
          ],
        ),
      ),
    );
  }
}
