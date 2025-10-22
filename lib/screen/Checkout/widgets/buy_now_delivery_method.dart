import 'package:flutter/material.dart';
import 'package:client/backend_services/store_service.dart';

class BuyNowDeliveryMethod extends StatefulWidget {
  final String selectedDeliveryMethod;
  final Map<String, dynamic>? selectedStore;
  final Function(String) onDeliveryMethodChanged;
  final Function(Map<String, dynamic>) onStoreSelected;

  const BuyNowDeliveryMethod({
    super.key,
    required this.selectedDeliveryMethod,
    required this.selectedStore,
    required this.onDeliveryMethodChanged,
    required this.onStoreSelected,
  });

  @override
  State<BuyNowDeliveryMethod> createState() => _BuyNowDeliveryMethodState();
}

class _BuyNowDeliveryMethodState extends State<BuyNowDeliveryMethod> {
  List<Map<String, dynamic>> _storeLocations = [];
  List<Map<String, dynamic>> _filteredStores = [];
  bool _isLoadingStores = false;
  final TextEditingController _storeSearchController = TextEditingController();

  @override
  void dispose() {
    _storeSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStoreLocations() async {
    setState(() {
      _isLoadingStores = true;
    });

    try {
      final stores = await StoreService.getStoreLocations();
      if (stores != null && stores.isNotEmpty) {
        setState(() {
          _storeLocations = stores;
          _filteredStores = stores;
        });
      } else {
        setState(() {
          _storeLocations = [];
          _filteredStores = [];
        });
      }
    } catch (e) {
      print('Error fetching stores: $e');
      setState(() {
        _storeLocations = [];
        _filteredStores = [];
      });
    } finally {
      setState(() {
        _isLoadingStores = false;
      });
    }
  }

  void _filterStores(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStores = _storeLocations;
      } else {
        _filteredStores = _storeLocations.where((store) {
          final storeName = (store['storeName'] ?? '').toLowerCase();
          final storeLocation = (store['storeLocation'] ?? '').toLowerCase();
          final searchQuery = query.toLowerCase();

          return storeName.contains(searchQuery) ||
              storeLocation.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _showStoreSelectionDialog() {
    // Fetch stores if not already loaded
    if (_storeLocations.isEmpty && !_isLoadingStores) {
      _fetchStoreLocations();
    }

    // Reset search
    _storeSearchController.clear();
    _filteredStores = _storeLocations;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.store, color: Colors.blue),
              SizedBox(width: 8),
              Text('Select Store for Pickup'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _storeSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search by store name or address...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _storeSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                _storeSearchController.clear();
                                _filterStores('');
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      _filterStores(value);
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Store List
                Expanded(
                  child: _isLoadingStores
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading store locations...'),
                            ],
                          ),
                        )
                      : _filteredStores.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _storeSearchController.text.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.store_mall_directory_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _storeSearchController.text.isNotEmpty
                                    ? 'No stores found for "${_storeSearchController.text}"'
                                    : 'No store locations available',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_storeSearchController.text.isEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Please contact support or try again later',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredStores.length,
                          itemBuilder: (context, index) {
                            final store = _filteredStores[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  store['storeName'] ?? 'Store',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            store['storeLocation'] ??
                                                'Address not available',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (store['storePhoneNumber'] != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            store['storePhoneNumber'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () {
                                  widget.onStoreSelected(store);
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

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
              'Delivery Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Home Delivery (₹150)'),
              subtitle: const Text('Delivered to your address'),
              value: 'homeDelivery',
              groupValue: widget.selectedDeliveryMethod,
              onChanged: (value) {
                widget.onDeliveryMethodChanged(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Store Pickup (₹100)'),
              subtitle: widget.selectedStore != null
                  ? Text(
                      'Selected: ${widget.selectedStore!['storeName'] ?? 'Store'}',
                    )
                  : const Text('Collect from nearest store'),
              value: 'storeDelivery',
              groupValue: widget.selectedDeliveryMethod,
              onChanged: (value) {
                widget.onDeliveryMethodChanged(value!);
                if (value == 'storeDelivery') {
                  _showStoreSelectionDialog();
                }
              },
            ),
            if (widget.selectedDeliveryMethod == 'storeDelivery' &&
                widget.selectedStore != null) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
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
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.selectedStore!['storeName'] ??
                                'Selected Store',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.selectedStore!['storeLocation'] ??
                                'Store Address',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (widget.selectedStore!['storePhoneNumber'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.selectedStore!['storePhoneNumber'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
