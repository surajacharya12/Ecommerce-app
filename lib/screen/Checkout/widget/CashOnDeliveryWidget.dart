import 'package:flutter/material.dart';
import 'package:client/screen/Checkout/checkout.dart'; // Import enums/formatter

class CashOnDeliveryWidget extends StatefulWidget {
  final Map<String, dynamic> orderSummary;
  final DeliveryMethod deliveryMethod;
  final Map<String, dynamic>? selectedStore;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onSubmit;

  const CashOnDeliveryWidget({
    super.key,
    required this.orderSummary,
    required this.deliveryMethod,
    required this.selectedStore,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<CashOnDeliveryWidget> createState() => _CashOnDeliveryWidgetState();
}

class _CashOnDeliveryWidgetState extends State<CashOnDeliveryWidget> {
  final _formKey = GlobalKey<FormState>();
  String? address;
  String? phone;

  @override
  Widget build(BuildContext context) {
    final total = widget.orderSummary['total'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "3. Confirm Order (Cash On Delivery)",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const Divider(height: 25),
              // Display Delivery Info
              if (widget.deliveryMethod == DeliveryMethod.homeDelivery) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                  onSaved: (val) => address = val,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your phone number' : null,
                  onSaved: (val) => phone = val,
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text('Pickup Store: ${widget.selectedStore!['name']}'),
                Text('Address: ${widget.selectedStore!['address']}'),
                const SizedBox(height: 20),
              ],

              // Final Total Confirmation
              Text(
                'Grand Total: ${currencyFormatter.format(total)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    "PLACE ORDER & PAY CASH",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onSubmit({
                        'paymentMethod': 'COD',
                        'address': address,
                        'phone': phone,
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
