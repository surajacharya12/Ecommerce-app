import 'package:flutter/material.dart';
import 'package:client/screen/Checkout/checkout.dart'; // Import enums/formatter

class OnlinePaymentWidget extends StatelessWidget {
  final Map<String, dynamic> orderSummary;
  final DeliveryMethod deliveryMethod;
  final Map<String, dynamic>? selectedStore;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onSubmit;

  const OnlinePaymentWidget({
    super.key,
    required this.orderSummary,
    required this.deliveryMethod,
    required this.selectedStore,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final total = orderSummary['total'];
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
                  "3. Online Payment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            const Center(
              child: Text(
                'Integration with a Payment Gateway (e.g., Stripe, Razorpay) goes here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Amount to Pay: ${currencyFormatter.format(total)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text(
                  "PROCEED TO ONLINE PAYMENT",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // In a real app, this would initiate the payment session and redirect.
                  onSubmit({'paymentMethod': 'Online'});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
