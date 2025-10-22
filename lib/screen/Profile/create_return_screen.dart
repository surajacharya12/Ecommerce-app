import 'package:flutter/material.dart';
import 'package:client/backend_services/return_service.dart';
import '../../models/return_item_selection.dart';
import '../../widgets/return/empty_state_widget.dart';
import '../../widgets/return/order_selection_widget.dart';
import '../../widgets/return/item_selection_widget.dart';
import '../../widgets/return/return_details_widget.dart';
import '../../widgets/return/submit_button_widget.dart';

class CreateReturnScreen extends StatefulWidget {
  final String userId;

  const CreateReturnScreen({super.key, required this.userId});

  @override
  State<CreateReturnScreen> createState() => _CreateReturnScreenState();
}

class _CreateReturnScreenState extends State<CreateReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _selectedOrder;
  String? _selectedReason;
  String _returnType = 'refund';
  String _refundMethod = 'original_payment';
  List<ReturnItemSelection> _selectedItems = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
    });

    try {
      final deliveredOrders = await ReturnService().getDeliveredOrders(
        widget.userId,
      );

      if (mounted) {
        setState(() {
          _orders = deliveredOrders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onOrderSelected(Map<String, dynamic>? order) {
    setState(() {
      _selectedOrder = order;
      _selectedItems.clear();

      if (order != null && order['items'] != null) {
        for (var item in order['items']) {
          // Extract product image and ID from productID object
          String? productImage;
          String productID = '';

          if (item['productID'] is Map<String, dynamic>) {
            final productData = item['productID'] as Map<String, dynamic>;
            productID = productData['_id']?.toString() ?? '';

            final images = productData['images'] as List<dynamic>?;
            if (images != null && images.isNotEmpty) {
              if (images[0] is Map<String, dynamic>) {
                productImage = (images[0] as Map<String, dynamic>)['url']
                    ?.toString();
              } else {
                productImage = images[0]?.toString();
              }
            }
          } else if (item['productID'] is String) {
            productID = item['productID'] as String;
          }

          _selectedItems.add(
            ReturnItemSelection(
              productID: productID,
              productName: item['productName']?.toString() ?? '',
              quantity: (item['quantity'] as num?)?.toInt() ?? 0,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              variant: item['variant']?.toString(),
              productImage: productImage,
              returnQuantity: 0,
              selected: false,
            ),
          );
        }
      }
    });
  }

  void _updateItemSelection(int index, bool selected, int returnQuantity) {
    setState(() {
      _selectedItems[index].selected = selected;
      _selectedItems[index].returnQuantity = selected ? returnQuantity : 0;
    });
  }

  Future<void> _submitReturn() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if order is selected
    if (_selectedOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if items are selected
    final selectedItems = _selectedItems
        .where((item) => item.selected)
        .toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to return'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if reason is selected
    if (_selectedReason == null || _selectedReason!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason for return'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if description is provided
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final returnItems = selectedItems
          .map(
            (item) => ReturnItem(
              productID: item.productID,
              productName: item.productName,
              quantity: item.quantity,
              price: item.price,
              variant: item.variant,
              returnQuantity: item.returnQuantity,
              condition: 'used',
            ),
          )
          .toList();

      final returnRequest = ReturnRequest(
        id: '',
        returnNumber: '',
        orderID: _selectedOrder!['_id'],
        orderNumber: _selectedOrder!['orderNumber'] ?? '',
        userID: widget.userId,
        returnDate: DateTime.now(),
        returnStatus: 'requested',
        returnType: _returnType,
        returnReason: _selectedReason!,
        returnDescription: _descriptionController.text.trim(),
        items: returnItems,
        returnAmount: selectedItems.fold(
          0.0,
          (sum, item) => sum + (item.price * item.returnQuantity),
        ),
        refundMethod: _refundMethod,
        images: [],
      );

      await ReturnService().createReturn(returnRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Return request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting return: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Return Request'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            )
          : _orders.isEmpty
          ? const EmptyStateWidget()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderSelectionWidget(
                      orders: _orders,
                      selectedOrder: _selectedOrder,
                      onOrderSelected: _onOrderSelected,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedOrder != null) ...[
                      ItemSelectionWidget(
                        selectedItems: _selectedItems,
                        onUpdateItemSelection: _updateItemSelection,
                      ),
                      const SizedBox(height: 16),
                      ReturnDetailsWidget(
                        returnType: _returnType,
                        selectedReason: _selectedReason,
                        descriptionController: _descriptionController,
                        refundMethod: _refundMethod,
                        onReturnTypeChanged: (value) {
                          setState(() {
                            _returnType = value;
                          });
                        },
                        onReasonChanged: (value) {
                          setState(() {
                            _selectedReason = value;
                          });
                        },
                        onRefundMethodChanged: (value) {
                          setState(() {
                            _refundMethod = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SubmitButtonWidget(
                        selectedItems: _selectedItems,
                        submitting: _submitting,
                        onSubmit: _submitReturn,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
