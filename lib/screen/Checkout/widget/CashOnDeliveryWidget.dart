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

  // Home delivery address fields (like web version)
  String? name;
  String? phone;
  String? address;
  String? city;
  String? postalCode;
  String? alternatePhone;
  String? deliveryInstructions;

  // Store pickup fields
  String? customerName;
  String? customerPhone;

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
                  const Expanded(
                    child: Text(
                      "3. Confirm Order (Cash On Delivery)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const Divider(height: 25),
              // Home Delivery Address Form (like web version)
              if (widget.deliveryMethod == DeliveryMethod.homeDelivery) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Delivery Address Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your full name'
                            : null,
                        onSaved: (val) => name = val,
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your phone number'
                            : null,
                        onSaved: (val) => phone = val,
                      ),
                      const SizedBox(height: 16),

                      // Street Address
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Street Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your street address'
                            : null,
                        onSaved: (val) => address = val,
                      ),
                      const SizedBox(height: 16),

                      // City and Postal Code Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city_outlined),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your city'
                                  : null,
                              onSaved: (val) => city = val,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Postal Code *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.markunread_mailbox_outlined,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter postal code'
                                  : null,
                              onSaved: (val) => postalCode = val,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Alternate Phone (Optional)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Alternate Phone (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_callback_outlined),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => alternatePhone = val,
                      ),
                      const SizedBox(height: 16),

                      // Delivery Instructions (Optional)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Delivery Instructions (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              'e.g., Ring the doorbell, Leave at door, etc.',
                        ),
                        maxLines: 3,
                        onSaved: (val) => deliveryInstructions = val,
                      ),
                      const SizedBox(height: 16),

                      // Delivery Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFBBF7D0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF059669),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Your order will be delivered within 3-5 business days. Payment will be collected upon delivery.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF059669),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // Store Pickup Information Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Store Pickup Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.business,
                                  color: Color(0xFF3B82F6),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.selectedStore!['storeName'] ??
                                        widget.selectedStore!['name'] ??
                                        'ShopSwift Store',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.selectedStore!['storeLocation'] ??
                                            widget.selectedStore!['address'] ??
                                            'Store Address',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF475569),
                                          height: 1.4,
                                        ),
                                      ),
                                      const Text(
                                        'Nepal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.selectedStore!['storePhoneNumber'] !=
                                null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Color(0xFF8B5CF6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.selectedStore!['storePhoneNumber'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF475569),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF059669),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Your order will be ready for pickup within 2-3 business days. You\'ll receive a notification when it\'s ready.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF059669),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Customer Information for Store Pickup
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Customer Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your full name'
                            : null,
                        onSaved: (val) => customerName = val,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your phone number'
                            : null,
                        onSaved: (val) => customerPhone = val,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFFD97706),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This information will be used to contact you when your order is ready for pickup.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                        'customerName': customerName,
                        'customerPhone': customerPhone,
                        'deliveryMethod': widget.deliveryMethod,
                        'selectedStore': widget.selectedStore,
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
