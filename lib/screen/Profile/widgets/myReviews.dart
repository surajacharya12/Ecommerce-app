import 'package:client/backend_services/review_services.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';
import 'package:flutter/material.dart';

class Myreviews extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const Myreviews({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<Myreviews> createState() => _MyreviewsState();
}

class _MyreviewsState extends State<Myreviews> {
  final RatingService _ratingService = RatingService();
  late Future<List<dynamic>> _userReviews;

  @override
  void initState() {
    super.initState();
    _userReviews = _ratingService.getUserRatings(widget.userId);
  }

  // Helper to extract product object if it's populated
  Map<String, dynamic>? _getProductData(dynamic productField) {
    if (productField is Map<String, dynamic>) return productField;
    return null;
  }

  // ✅ Navigate to ProductDetailsScreen
  void _navigateToProductDetails(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
          customerId: widget.userId,
          customerName: widget.userName,
          customerEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reviews"),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading reviews: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No reviews found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final reviews = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _userReviews = _ratingService.getUserRatings(widget.userId);
              });
            },
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final product = _getProductData(review['productId']);
                final rating = review['rating'];
                final reviewText = review['review'] ?? '';

                // Extract productId safely
                final rawProductId = review['productId'];
                String? productId;
                if (rawProductId is String) {
                  productId = rawProductId;
                } else if (rawProductId is Map<String, dynamic>) {
                  productId = rawProductId['_id']?.toString();
                }

                // Extract image URL
                final imageUrl =
                    (product?['images'] != null &&
                        product!['images'].isNotEmpty)
                    ? (product['images'][0] is String
                          ? product['images'][0]
                          : (product['images'][0]['url'] ?? null))
                    : null;

                final productName = product?['name'] ?? "Unknown Product";

                return InkWell(
                  onTap: () {
                    if (productId != null) {
                      _navigateToProductDetails(context, productId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Product details unavailable."),
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.broken_image,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                ),
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 30,
                                color: Colors.grey,
                              ),
                      ),
                      title: Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text("Rating: $rating"),
                            ],
                          ),
                          if (reviewText.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              '"$reviewText"',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
