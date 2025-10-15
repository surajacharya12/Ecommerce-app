import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  final List<Map<String, dynamic>> paymentMethods = const [
    {'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {'name': 'PayPal', 'icon': Icons.account_balance_wallet},
    {'name': 'UPI', 'icon': Icons.payment},
    {'name': 'Wallet', 'icon': Icons.account_balance},
    {'name': 'Cash on Delivery', 'icon': Icons.money},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Payment Methods'),
        backgroundColor: Colors.deepOrange,
      ),
      backgroundColor: const Color(0xFFF2F7FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'We accept the following payment methods:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: paymentMethods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepOrange.withOpacity(0.1),
                          child: Icon(
                            method['icon'],
                            size: 28,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          method['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
