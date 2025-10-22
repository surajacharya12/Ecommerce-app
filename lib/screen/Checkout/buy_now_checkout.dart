import 'package:flutter/material.dart';
import 'package:client/backend_services/order_service.dart';
import 'package:client/Components /coupon_widget.dart';
import 'package:client/Components /order_success_animation.dart';
import 'package:client/screen/Checkout/widgets/buy_now_product_summary.dart';
import 'package:client/screen/Checkout/widgets/buy_now_delivery_method.dart';
import 'package:client/screen/Checkout/widgets/buy_now_shipping_form.dart';
import 'package:client/screen/Checkout/widgets/buy_now_customer_info.dart';
import 'package:client/screen/Checkout/widgets/buy_now_payment_method.dart';
import 'package:client/screen/Checkout/widgets/buy_now_order_summary.dart';

class BuyNowCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;

  const BuyNowCheckoutScreen({
    super.key,
    required this.productData,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  @override
  State<BuyNowCheckoutScreen> createState() => _BuyNowCheckoutScreenState();
}

class _BuyNowCheckoutScreenState extends State<BuyNowCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  // Checkout state
  String _selectedDeliveryMethod = 'homeDelivery';
  String _selectedPaymentMethod = 'cod';
  bool _isProcessing = false;
  Map<String, dynamic>? _appliedCoupon;
  Map<String, dynamic>? _selectedStore;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.customerName;
    _customerNameController.text = widget.customerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  double get _subtotal {
    final price =
        widget.productData['offerPrice'] ?? widget.productData['price'];
    return (price * widget.quantity).toDouble();
  }

  double get _deliveryFee {
    return _selectedDeliveryMethod == 'homeDelivery' ? 150.0 : 100.0;
  }

  double get _discountAmount {
    if (_appliedCoupon == null) return 0.0;
    return (_appliedCoupon!['discountAmount'] ?? 0.0).toDouble();
  }

  double get _total {
    return (_subtotal + _deliveryFee - _discountAmount).clamp(
      0.0,
      double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Now - Checkout'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Summary Card
              BuyNowProductSummary(
                productData: widget.productData,
                quantity: widget.quantity,
                selectedColor: widget.selectedColor,
                selectedSize: widget.selectedSize,
              ),
              const SizedBox(height: 20),

              // Delivery Method Selection
              BuyNowDeliveryMethod(
                selectedDeliveryMethod: _selectedDeliveryMethod,
                selectedStore: _selectedStore,
                onDeliveryMethodChanged: (method) {
                  setState(() {
                    _selectedDeliveryMethod = method;
                  });
                },
                onStoreSelected: (store) {
                  setState(() {
                    _selectedStore = store;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Shipping Address Form (only for home delivery)
              if (_selectedDeliveryMethod == 'homeDelivery') ...[
                BuyNowShippingForm(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  addressController: _addressController,
                  cityController: _cityController,
                  postalCodeController: _postalCodeController,
                ),
                const SizedBox(height: 20),
              ],

              // Customer Information Form (only for store delivery)
              if (_selectedDeliveryMethod == 'storeDelivery' &&
                  _selectedStore != null) ...[
                BuyNowCustomerInfo(
                  customerNameController: _customerNameController,
                  customerPhoneController: _customerPhoneController,
                ),
                const SizedBox(height: 20),
              ],

              // Payment Method Selection
              BuyNowPaymentMethod(
                selectedPaymentMethod: _selectedPaymentMethod,
                onPaymentMethodChanged: (method) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Coupon Input
              CouponInputWidget(
                onCouponApplied: (couponData) {
                  setState(() {
                    _appliedCoupon = couponData;
                  });
                },
                purchaseAmount: _subtotal,
                productIds: [widget.productData['_id']],
                appliedCoupon: _appliedCoupon,
              ),
              const SizedBox(height: 20),

              // Order Summary
              BuyNowOrderSummary(
                subtotal: _subtotal,
                deliveryFee: _deliveryFee,
                discountAmount: _discountAmount,
                total: _total,
                appliedCoupon: _appliedCoupon,
              ),
              const SizedBox(height: 30),

              // Place Order Button
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing Order...'),
                ],
              )
            : Text(
                'Place Order - ₹${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _processOrder() async {
    // Validate form based on delivery method
    if (_selectedDeliveryMethod == 'homeDelivery' &&
        !_formKey.currentState!.validate()) {
      return;
    }

    // Check if store is selected when store delivery is chosen
    if (_selectedDeliveryMethod == 'storeDelivery' && _selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a store for pickup'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate customer info for store delivery
    if (_selectedDeliveryMethod == 'storeDelivery') {
      if (_customerNameController.text.trim().isEmpty ||
          _customerPhoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please fill in your name and phone number for store pickup',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final shippingAddress =
          _selectedDeliveryMethod == 'storeDelivery' && _selectedStore != null
          ? <String, String>{
              'phone': (_selectedStore!['storePhoneNumber'] ?? 'N/A')
                  .toString(),
              'street': (_selectedStore!['storeLocation'] ?? 'Store Address')
                  .toString(),
              'city': (_selectedStore!['storeLocation'] ?? 'Store City')
                  .toString(),
              'state': 'Nepal',
              'postalCode': '00000',
              'country': 'Nepal',
            }
          : <String, String>{
              'phone': _phoneController.text,
              'street': _addressController.text,
              'city': _cityController.text,
              'state': 'Nepal',
              'postalCode': _postalCodeController.text,
              'country': 'Nepal',
            };

      // Prepare order items
      final items = [
        {
          'productID': widget.productData['_id'],
          'productName': widget.productData['name'],
          'quantity': widget.quantity,
          'price':
              (widget.productData['offerPrice'] ?? widget.productData['price'])
                  .toDouble(),
          'selectedColor': widget.selectedColor,
          'selectedSize': widget.selectedSize,
        },
      ];

      final orderResult = await OrderService.createOrder(
        userId: widget.customerId,
        items: items,
        shippingAddress: shippingAddress,
        paymentMethod: _selectedPaymentMethod == 'cod'
            ? 'cod'
            : 'onlinePayment',
        deliveryMethod: _selectedDeliveryMethod,
        totalPrice: _total,
        deliveryFee: _deliveryFee,
        selectedStore: _selectedStore,
        customerName: _selectedDeliveryMethod == 'storeDelivery'
            ? _customerNameController.text
            : null,
        customerPhone: _selectedDeliveryMethod == 'storeDelivery'
            ? _customerPhoneController.text
            : null,
        appliedCoupon: _appliedCoupon,
      );

      if (orderResult != null && mounted) {
        // Show success animation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessAnimation(
              orderData: orderResult,
              productData: widget.productData,
              onComplete: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
