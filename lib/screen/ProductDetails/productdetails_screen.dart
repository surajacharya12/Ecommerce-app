import 'dart:convert';
import 'package:client/backend_services/cart_services.dart';
import 'package:client/backend_services/productDetails_service.dart';
import 'package:client/backend_services/chat_service.dart';
import 'package:client/screen/ProductDetails/wigets/bottom_action_buttons.dart';
import 'package:client/screen/ProductDetails/wigets/customer_reviews_list.dart';
import 'package:client/screen/ProductDetails/wigets/product_overview_card.dart';
import 'package:client/screen/ProductDetails/wigets/review_submission_section.dart';
import 'package:client/screen/chat/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool _chatLoading = false;
  List<Map<String, dynamic>> _productReviews = [];

  @override
  void initState() {
    super.initState();
    _fetchProductAndReviews();
  }

  Future<void> _fetchProductAndReviews() async {
    setState(() {
      _productDetailsFuture = _detailsService.fetchProductDetails(
        widget.productId,
      );
    });
    await _fetchProductReviews();
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
      debugPrint('Error fetching product reviews: $e');
      setState(() => _productReviews = []);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load reviews: $e")));
      }
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
      _fetchProductAndReviews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit review: $e")));
      }
    }
  }

  Future<void> _addToCart() async {
    final success = await CartService.addToCart(
      widget.customerId,
      widget.productId,
      1,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Product added to cart!"
                : "Failed to add product to cart.",
          ),
        ),
      );
    }
  }

  Future<void> _buyNow() async {
    final success = await CartService.addToCart(
      widget.customerId,
      widget.productId,
      1,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Product added to cart! Proceeding to checkout..."
                : "Failed to add product to cart.",
          ),
        ),
      );
    }
  }

  // Open chat with **real user info**
  Future<void> _openChat() async {
    setState(() => _chatLoading = true);

    try {
      final chat = await _chatService.startChat(
        productId: widget.productId,
        customerId: widget.customerId,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        initialMessage: '',
      );

      if (chat.id.isEmpty) throw Exception("Invalid chat returned");

      setState(() {
        _existingChatId = chat.id;
        _chatLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessageScreen(userId: widget.customerId, chat: chat),
        ),
      );
    } catch (e) {
      debugPrint('Failed to start chat: $e');
      setState(() => _chatLoading = false);

      if (_existingChatId != null) {
        try {
          final existingChat = await _chatService.getChatById(_existingChatId!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MessageScreen(userId: widget.customerId, chat: existingChat),
            ),
          );
        } catch (err) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Unable to open chat: $err")));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unable to start chat.")));
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
          onPressed: _chatLoading ? null : _openChat,
          backgroundColor: _chatLoading ? Colors.grey : Colors.deepOrange,
          label: _chatLoading
              ? const Text("Opening Chat...")
              : const Text("Chat with Seller"),
          icon: _chatLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : const Icon(Icons.chat),
        ),
      ),
    );
  }
}
