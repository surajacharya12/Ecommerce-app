import 'dart:convert';
import 'package:client/backend_services/cart_services.dart';
import 'package:client/screen/ProductDetails/wigets/bottom_action_buttons.dart';
import 'package:client/screen/ProductDetails/wigets/customer_reviews_list.dart';
import 'package:client/screen/ProductDetails/wigets/product_overview_card.dart';
import 'package:client/screen/ProductDetails/wigets/review_submission_section.dart';
import 'package:client/screen/chat/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/backend_services/productDetails_service.dart';
import 'package:client/backend_services/chat_service.dart';

typedef ProductDetailData = Map<String, dynamic>;

final NumberFormat currencyFormatter = NumberFormat.currency(
  locale: "en_IN",
  symbol: "₹",
  decimalDigits: 2,
);

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String customerId;
  final String customerName;
  final String customerEmail;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<ProductDetailData> _productDetailsFuture;
  final ProductDetailsService _detailsService = ProductDetailsService();
  final ChatService _chatService = ChatService();
  String? _existingChatId;
  List<Map<String, dynamic>> _productReviews = [];

  @override
  void initState() {
    super.initState();
    _fetchProductAndChatDetails();
  }

  Future<void> _fetchProductAndChatDetails() async {
    setState(() {
      _productDetailsFuture = _detailsService.fetchProductDetails(
        widget.productId,
      );
    });
    await _fetchProductReviews();
    await _checkExistingChat();
  }

  Future<void> _checkExistingChat() async {
    try {
      if (widget.productId.isEmpty ||
          widget.customerId.isEmpty ||
          widget.customerName.isEmpty ||
          widget.customerEmail.isEmpty) {
        debugPrint("⚠️ Missing chat parameters — skipping chat check");
        return;
      }

      debugPrint("🔍 Checking existing chat with:");
      debugPrint("productId: ${widget.productId}");
      debugPrint("customerId: ${widget.customerId}");
      debugPrint("customerName: ${widget.customerName}");
      debugPrint("customerEmail: ${widget.customerEmail}");

      final chat = await _chatService.startChat(
        productId: widget.productId,
        customerId: widget.customerId,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        initialMessage: '',
      );
      setState(() {
        _existingChatId = chat.id;
      });
    } catch (e) {
      debugPrint('❌ No existing chat or failed to start: $e');
      _existingChatId = null;
    }
  }

  Future<void> _fetchProductReviews() async {
    try {
      final reviews = await _detailsService.fetchProductReviews(
        widget.productId,
      );
      setState(() {
        _productReviews = reviews;
      });
    } catch (e) {
      debugPrint('❌ Error fetching product reviews: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load reviews: $e")));
      }
      setState(() {
        _productReviews = [];
      });
    }
  }

  Future<void> _submitUserReview(double rating, String comment) async {
    if (rating == 0.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide a rating.")),
        );
      }
      return;
    }

    try {
      await _detailsService.submitProductReview(
        productId: widget.productId,
        userId: widget.customerId,
        rating: rating,
        review: comment,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );
      }
      _fetchProductAndChatDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit review: $e")));
      }
    }
  }

  Future<void> _addToCart() async {
    final productId = widget.productId;
    final userId = widget.customerId;
    final quantity = 1;

    bool success = await CartService.addToCart(userId, productId, quantity);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Product added to cart!")));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product to cart.")),
        );
      }
    }
  }

  Future<void> _buyNow() async {
    final productId = widget.productId;
    final userId = widget.customerId;
    final quantity = 1;

    bool success = await CartService.addToCart(userId, productId, quantity);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product added to cart! Proceeding to checkout..."),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product to cart.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Product Details'), centerTitle: true),
      body: FutureBuilder<ProductDetailData>(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No product found.'));
          }

          final product = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ProductOverviewCard(
                        product: product,
                        currencyFormatter: currencyFormatter,
                        userId: widget.customerId,
                        onWishlistToggle: (isWishlisted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isWishlisted
                                    ? "Added to Wishlist"
                                    : "Removed from Wishlist",
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ReviewSubmissionSection(
                        onSubmitReview: _submitUserReview,
                      ),
                      const SizedBox(height: 16),
                      CustomerReviewsList(
                        productId: widget.productId,
                        customerId: widget.customerId,
                        customerName: widget.customerName,
                        customerEmail: widget.customerEmail,
                        reviews: _productReviews,
                      ),
                    ],
                  ),
                ),
              ),
              BottomActionButtons(onAddToCart: _addToCart, onBuyNow: _buyNow),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            debugPrint("🟠 Navigating to ChatScreen with:");
            debugPrint("productId: ${widget.productId}");
            debugPrint("customerId: ${widget.customerId}");
            debugPrint("customerName: ${widget.customerName}");
            debugPrint("customerEmail: ${widget.customerEmail}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  productId: widget.productId,
                  customerId: widget.customerId,
                  customerName: widget.customerName,
                  customerEmail: widget.customerEmail,
                  userId: widget.customerId,
                  existingChatId: _existingChatId,
                ),
              ),
            );
          },
          backgroundColor: Colors.deepOrange,
          label: const Text("Chat with Seller"),
          icon: const Icon(Icons.chat),
        ),
      ),
    );
  }
}
