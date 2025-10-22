import 'package:client/screen/Checkout/widget/OrderSummery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/backend_services/cart_services.dart';
import 'package:client/backend_services/order_service.dart';
import 'package:client/Components /order_success_animation.dart';
import 'package:client/screen/Checkout/widget/CashOnDeliveryWidget.dart';
import 'package:client/screen/Checkout/widget/DeliveryMethodStepWidget.dart';
import 'package:client/screen/Checkout/widget/OnlinePaymentWidget.dart';
import 'package:client/screen/Checkout/widget/PaymentMethodStepWidget.dart';

enum DeliveryMethod { homeDelivery, storeDelivery }

enum PaymentMethod { cashOnDelivery, onlinePayment }

enum CheckoutStep { deliveryMethod, paymentMethod, paymentForm }

const double HOME_DELIVERY_FEE = 150.0;
const double STORE_DELIVERY_FEE = 100.0;

final NumberFormat currencyFormatter = NumberFormat.currency(
  locale: "en_IN",
  symbol: "₹",
  decimalDigits: 2,
);

class Checkout extends StatefulWidget {
  final String userId;
  const Checkout({super.key, required this.userId});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  CheckoutStep currentStep = CheckoutStep.deliveryMethod;
  DeliveryMethod? selectedDelivery;
  Map<String, dynamic>? selectedStore;
  PaymentMethod? selectedPayment;
  Map<String, dynamic>? cartData;
  Map<String, dynamic>? orderSummary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  // ---------------- DATA FETCH ----------------
  Future<void> fetchCartData() async {
    setState(() => isLoading = true);

    final response = await CartService.getCart(widget.userId);
    if (!mounted) return;

    if (response != null && response['success'] == true) {
      cartData = response['data'] as Map<String, dynamic>?;
      _updateOrderSummary(); // ensures orderSummary is built
      setState(() => isLoading = false);
    } else {
      setState(() {
        cartData = null;
        orderSummary = null;
        isLoading = false;
      });
    }
  }

  // ---------------- CALCULATIONS ----------------
  double getDeliveryFee() {
    if (selectedDelivery == DeliveryMethod.homeDelivery)
      return HOME_DELIVERY_FEE;
    if (selectedDelivery == DeliveryMethod.storeDelivery)
      return STORE_DELIVERY_FEE;
    return 0.0;
  }

  void _updateOrderSummary() {
    if (cartData == null ||
        cartData!['items'] == null ||
        (cartData!['items'] as List).isEmpty) {
      setState(() => orderSummary = null);
      return;
    }

    final itemsList = (cartData!['items'] as List)
        .map((item) {
          final product = item['productId'];
          if (product == null) return null;

          return {
            'id': product['_id'],
            'name': product['name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'image': (product['images'] != null && product['images'].isNotEmpty)
                ? product['images'][0]['url']
                : null,
          };
        })
        .where((element) => element != null)
        .toList();

    final subtotal = (cartData!['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final deliveryFee = getDeliveryFee();

    setState(() {
      orderSummary = {
        'items': itemsList,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': subtotal + deliveryFee,
      };
    });
  }

  // ---------------- STEP HANDLERS ----------------
  void handleDeliveryMethodSelect(DeliveryMethod method) {
    setState(() {
      selectedDelivery = method;
      _updateOrderSummary();
      currentStep = CheckoutStep.paymentMethod;
    });
  }

  void handleStoreSelect(Map<String, dynamic> store) {
    setState(() {
      selectedStore = store;
      currentStep = CheckoutStep.paymentMethod;
    });
  }

  void handlePaymentMethodSelect(PaymentMethod method) {
    setState(() {
      selectedPayment = method;
      currentStep = CheckoutStep.paymentForm;
    });
  }

  Future<void> handleOrderSubmit(Map<String, dynamic> submissionData) async {
    if (orderSummary == null || cartData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order data not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare order items
      final items = (cartData!['items'] as List).map((item) {
        final product = item['productId'];
        return {
          'productID': product['_id'],
          'productName': product['name'],
          'quantity': item['quantity'],
          'price': item['price'],
          'variant': item['variant'] ?? '',
        };
      }).toList();

      // Prepare shipping address
      Map<String, String> shippingAddress;
      if (selectedDelivery == DeliveryMethod.storeDelivery &&
          selectedStore != null) {
        shippingAddress = {
          'phone': selectedStore!['storePhoneNumber']?.toString() ?? 'N/A',
          'street':
              selectedStore!['storeLocation']?.toString() ?? 'Store Address',
          'city': selectedStore!['storeLocation']?.toString() ?? 'Store City',
          'state': 'Nepal',
          'postalCode': '00000',
          'country': 'Nepal',
        };
      } else {
        shippingAddress = {
          'phone': submissionData['phone'] ?? '',
          'street': submissionData['address'] ?? '',
          'city': 'City',
          'state': 'Nepal',
          'postalCode': '00000',
          'country': 'Nepal',
        };
      }

      // Create order
      final orderResult = await OrderService.createOrder(
        userId: widget.userId,
        items: items,
        shippingAddress: shippingAddress,
        paymentMethod: submissionData['paymentMethod'] ?? 'COD',
        deliveryMethod: selectedDelivery == DeliveryMethod.homeDelivery
            ? 'homeDelivery'
            : 'storeDelivery',
        totalPrice: orderSummary!['total'].toDouble(),
        deliveryFee: orderSummary!['deliveryFee'].toDouble(),
        selectedStore: selectedStore,
        customerName: submissionData['customerName'],
        customerPhone: submissionData['customerPhone'],
      );

      // Hide loading
      if (mounted) Navigator.pop(context);

      if (orderResult != null) {
        // Clear cart after successful order
        await CartService.clearCart(widget.userId);

        // Show success animation
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessAnimation(
                orderData: orderResult,
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
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to place order. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void handleBackToPaymentSelection() {
    setState(() {
      currentStep = CheckoutStep.paymentMethod;
      selectedPayment = null;
    });
  }

  void handleBackToDeliverySelection() {
    setState(() {
      currentStep = CheckoutStep.deliveryMethod;
      selectedDelivery = null;
      selectedStore = null;
      selectedPayment = null;
      _updateOrderSummary();
    });
  }

  // ---------------- UI BUILDERS ----------------
  Widget _buildCheckoutStep() {
    switch (currentStep) {
      case CheckoutStep.deliveryMethod:
        return DeliveryMethodStepWidget(
          selectedDelivery: selectedDelivery,
          selectedStore: selectedStore,
          onDeliveryMethodSelect: handleDeliveryMethodSelect,
          onStoreSelect: handleStoreSelect,
        );
      case CheckoutStep.paymentMethod:
        return PaymentMethodStepWidget(
          selectedDelivery: selectedDelivery,
          selectedStore: selectedStore,
          onPaymentMethodSelect: handlePaymentMethodSelect,
          onBack: handleBackToDeliverySelection,
        );
      case CheckoutStep.paymentForm:
        if (selectedPayment == PaymentMethod.cashOnDelivery) {
          return CashOnDeliveryWidget(
            orderSummary: orderSummary!,
            deliveryMethod: selectedDelivery!,
            selectedStore: selectedStore,
            onBack: handleBackToPaymentSelection,
            onSubmit: handleOrderSubmit,
          );
        } else if (selectedPayment == PaymentMethod.onlinePayment) {
          return OnlinePaymentWidget(
            orderSummary: orderSummary!,
            deliveryMethod: selectedDelivery!,
            selectedStore: selectedStore,
            onBack: handleBackToPaymentSelection,
            onSubmit: handleOrderSubmit,
          );
        }
        return const Center(child: Text("Select a payment method."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderSummary == null
          ? const Center(
              child: Text(
                '🛒 No items in your order.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Content
                      Expanded(
                        flex: currentStep == CheckoutStep.paymentForm ? 10 : 7,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCheckoutStep(),
                        ),
                      ),
                      if (currentStep != CheckoutStep.paymentForm)
                        const SizedBox(width: 30),
                      if (currentStep != CheckoutStep.paymentForm)
                        Expanded(
                          flex: 3,
                          child: OrderSummaryCard(
                            orderSummary: orderSummary!,
                            selectedDelivery: selectedDelivery,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
