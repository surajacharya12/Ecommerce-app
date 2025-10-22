import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/backend_services/cart_services.dart';
import 'package:client/backend_services/order_service.dart';
import 'package:client/Components /order_success_animation.dart';
import 'package:client/screen/Checkout/widget/CashOnDeliveryWidget.dart';
import 'package:client/screen/Checkout/widget/DeliveryMethodStepWidget.dart';
import 'package:client/screen/Checkout/widget/OnlinePaymentWidget.dart';
import 'package:client/screen/Checkout/widget/PaymentMethodStepWidget.dart';
import 'package:client/screen/Checkout/widget/OrderSummery.dart';
import 'package:client/screen/Checkout/checkout.dart'; // Import existing enums

enum CheckoutStep { deliveryMethod, paymentMethod, paymentForm }

enum CheckoutType { cart, buyNow }

const double homeDeliveryFee = 150.0;
const double storeDeliveryFee = 100.0;

final NumberFormat currencyFormatter = NumberFormat.currency(
  locale: "en_IN",
  symbol: "₹",
  decimalDigits: 2,
);

class UnifiedCheckout extends StatefulWidget {
  final String userId;
  final CheckoutType checkoutType;

  // For cart checkout
  final Map<String, dynamic>? cartData;

  // For buy now checkout
  final Map<String, dynamic>? productData;
  final int? quantity;
  final String? selectedColor;
  final String? selectedSize;
  final String? customerName;
  final String? customerEmail;

  const UnifiedCheckout({
    super.key,
    required this.userId,
    required this.checkoutType,
    this.cartData,
    this.productData,
    this.quantity,
    this.selectedColor,
    this.selectedSize,
    this.customerName,
    this.customerEmail,
  });

  // Factory constructor for cart checkout
  factory UnifiedCheckout.cart({
    required String userId,
    Map<String, dynamic>? cartData,
  }) {
    return UnifiedCheckout(
      userId: userId,
      checkoutType: CheckoutType.cart,
      cartData: cartData,
    );
  }

  // Factory constructor for buy now checkout
  factory UnifiedCheckout.buyNow({
    required String userId,
    required Map<String, dynamic> productData,
    required int quantity,
    String? selectedColor,
    String? selectedSize,
    String? customerName,
    String? customerEmail,
  }) {
    return UnifiedCheckout(
      userId: userId,
      checkoutType: CheckoutType.buyNow,
      productData: productData,
      quantity: quantity,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
      customerName: customerName,
      customerEmail: customerEmail,
    );
  }

  @override
  State<UnifiedCheckout> createState() => _UnifiedCheckoutState();
}

class _UnifiedCheckoutState extends State<UnifiedCheckout> {
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
    _initializeCheckout();
  }

  Future<void> _initializeCheckout() async {
    setState(() => isLoading = true);

    if (widget.checkoutType == CheckoutType.cart) {
      // For cart checkout, fetch cart data if not provided
      if (widget.cartData != null) {
        cartData = widget.cartData;
        _updateOrderSummary();
        setState(() => isLoading = false);
      } else {
        await _fetchCartData();
      }
    } else {
      // For buy now checkout, use provided product data
      _createBuyNowOrderSummary();
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCartData() async {
    final response = await CartService.getCart(widget.userId);
    if (!mounted) return;

    if (response != null && response['success'] == true) {
      cartData = response['data'] as Map<String, dynamic>?;
      _updateOrderSummary();
      setState(() => isLoading = false);
    } else {
      setState(() {
        cartData = null;
        orderSummary = null;
        isLoading = false;
      });
    }
  }

  double getDeliveryFee() {
    if (selectedDelivery == DeliveryMethod.homeDelivery) {
      return homeDeliveryFee;
    }
    if (selectedDelivery == DeliveryMethod.storeDelivery) {
      return storeDeliveryFee;
    }
    return 0.0;
  }

  void _updateOrderSummary() {
    if (widget.checkoutType == CheckoutType.cart) {
      _createCartOrderSummary();
    } else {
      _createBuyNowOrderSummary();
    }
  }

  void _createCartOrderSummary() {
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

  void _createBuyNowOrderSummary() {
    if (widget.productData == null || widget.quantity == null) {
      setState(() => orderSummary = null);
      return;
    }

    final price =
        widget.productData!['offerPrice'] ?? widget.productData!['price'];
    final subtotal = (price * widget.quantity!).toDouble();
    final deliveryFee = getDeliveryFee();

    final itemsList = [
      {
        'id': widget.productData!['_id'],
        'name': widget.productData!['name'],
        'price': price,
        'quantity': widget.quantity!,
        'image':
            (widget.productData!['images'] != null &&
                widget.productData!['images'].isNotEmpty)
            ? widget.productData!['images'][0]['url']
            : null,
        'selectedColor': widget.selectedColor,
        'selectedSize': widget.selectedSize,
      },
    ];

    setState(() {
      orderSummary = {
        'items': itemsList,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': subtotal + deliveryFee,
      };
    });
  }

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
    if (orderSummary == null) {
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

      List<Map<String, dynamic>> items;

      if (widget.checkoutType == CheckoutType.cart) {
        // Prepare cart items
        items = (cartData!['items'] as List).map((item) {
          final product = item['productId'];
          return {
            'productID': product['_id'],
            'productName': product['name'],
            'quantity': item['quantity'],
            'price': item['price'],
            'variant': item['variant'] ?? '',
          };
        }).toList();
      } else {
        // Prepare buy now item
        items = [
          {
            'productID': widget.productData!['_id'],
            'productName': widget.productData!['name'],
            'quantity': widget.quantity!,
            'price':
                widget.productData!['offerPrice'] ??
                widget.productData!['price'],
            'selectedColor': widget.selectedColor,
            'selectedSize': widget.selectedSize,
          },
        ];
      }

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
          'city': submissionData['city'] ?? 'City',
          'state': 'Nepal',
          'postalCode': submissionData['postalCode'] ?? '00000',
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
        // Clear cart after successful cart order
        if (widget.checkoutType == CheckoutType.cart) {
          await CartService.clearCart(widget.userId);
        }

        // Show success animation
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessAnimation(
                orderData: orderResult,
                productData: widget.checkoutType == CheckoutType.buyNow
                    ? widget.productData
                    : null,
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.checkoutType == CheckoutType.cart
              ? 'Cart Checkout'
              : 'Buy Now Checkout',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 207, 78, 84), // Indigo
                Color.fromARGB(255, 246, 92, 107), // Purple
                Color(0xFFEC4899), // Pink
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC), // Light gray
              Color(0xFFF1F5F9), // Slightly darker gray
              Color(0xFFE2E8F0), // Even darker gray
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading checkout...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : orderSummary == null
            ? Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.checkoutType == CheckoutType.cart
                            ? 'No items in your cart'
                            : 'Product data not available',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.checkoutType == CheckoutType.cart
                            ? 'Add some items to continue'
                            : 'Please try again',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.checkoutType == CheckoutType.cart
                                    ? 'Complete Your Order'
                                    : 'Buy Now Checkout',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.checkoutType == CheckoutType.cart
                                    ? 'Review your items and complete your purchase securely'
                                    : 'Fast and secure checkout for your selected item',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Column(
                          children: [
                            // Step Content
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _buildCheckoutStep(),
                              ),
                            ),

                            // Order Summary Below
                            if (currentStep != CheckoutStep.paymentForm)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: OrderSummaryCard(
                                  orderSummary: orderSummary!,
                                  selectedDelivery: selectedDelivery,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
