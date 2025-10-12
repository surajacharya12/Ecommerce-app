import 'package:flutter/material.dart';
import 'package:client/screen/Checkout/checkout.dart'; // Import enums

class DeliveryMethodStepWidget extends StatelessWidget {
  final DeliveryMethod? selectedDelivery;
  final Map<String, dynamic>? selectedStore;
  final Function(DeliveryMethod) onDeliveryMethodSelect;
  final Function(Map<String, dynamic>) onStoreSelect;
  // Add storeLocations and loadingStores props as needed

  const DeliveryMethodStepWidget({
    super.key,
    required this.selectedDelivery,
    required this.selectedStore,
    required this.onDeliveryMethodSelect,
    required this.onStoreSelect,
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
            const Text(
              "1. Choose Delivery Method",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(),
            RadioListTile<DeliveryMethod>(
              title: const Text('Home Delivery (₹150)'),
              value: DeliveryMethod.homeDelivery,
              groupValue: selectedDelivery,
              onChanged: (val) => onDeliveryMethodSelect(val!),
            ),
            RadioListTile<DeliveryMethod>(
              title: const Text('Store Pickup (₹100)'),
              subtitle: selectedStore != null
                  ? Text('Selected: ${selectedStore!['name']}')
                  : null,
              value: DeliveryMethod.storeDelivery,
              groupValue: selectedDelivery,
              onChanged: (val) {
                onDeliveryMethodSelect(val!);
                // In a real app, this would trigger a modal or new UI to select a store
                if (val == DeliveryMethod.storeDelivery &&
                    selectedStore == null) {
                  // Placeholder for showing store selection UI
                  _showStoreSelectionDialog(context);
                }
              },
            ),
            if (selectedDelivery == DeliveryMethod.storeDelivery &&
                selectedStore == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Please select a store location.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            // Example of a 'Next' button logic for Store Pickup
            if (selectedDelivery == DeliveryMethod.storeDelivery &&
                selectedStore != null)
              ElevatedButton(
                onPressed: () {
                  // This is already handled by onStoreSelect setting the next step, but a dedicated button can enforce flow.
                  // For now, no explicit next needed here if logic in main Checkout handles the state change.
                },
                child: const Text('Confirm Store & Proceed'),
              ),
          ],
        ),
      ),
    );
  }

  void _showStoreSelectionDialog(BuildContext context) {
    // A mock store selection for demonstration
    final mockStores = [
      {'id': 's1', 'name': 'City Mall Store', 'address': '123 Main St.'},
      {'id': 's2', 'name': 'Tech Hub Branch', 'address': '456 Innovation Ave.'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Store for Pickup'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: mockStores
                .map(
                  (store) => ListTile(
                    title: Text(store['name']!),
                    subtitle: Text(store['address']!),
                    onTap: () {
                      onStoreSelect(store);
                      Navigator.pop(ctx);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
