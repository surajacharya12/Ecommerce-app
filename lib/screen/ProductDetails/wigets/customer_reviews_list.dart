// lib/screen/ProductDetails/widgets/customer_reviews_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/backend_services/LoginAndSignupServices.dart';

class CustomerReviewsList extends StatefulWidget {
  final String productId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final List<Map<String, dynamic>> reviews;

  const CustomerReviewsList({
    super.key,
    required this.productId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.reviews,
  });

  @override
  State<CustomerReviewsList> createState() => _CustomerReviewsListState();
}

class _CustomerReviewsListState extends State<CustomerReviewsList> {
  final BackendService _backendService = BackendService();
  final Map<String, String> _userNamesCache = {}; // Cache userId -> name
  bool _isLoadingNames = false;

  @override
  void initState() {
    super.initState();
    _fetchAllReviewerNames();
  }

  Future<void> _fetchAllReviewerNames() async {
    setState(() => _isLoadingNames = true);

    for (var review in widget.reviews) {
      final userId = review['userId'];
      if (userId != null && !_userNamesCache.containsKey(userId)) {
        final profileResponse = await _backendService.getUserProfile(
          userId: userId.toString(),
        );
        if (profileResponse['success'] == true &&
            profileResponse['user'] != null) {
          final name = profileResponse['user']['name'] ?? 'Anonymous';
          _userNamesCache[userId] = name;
        } else {
          _userNamesCache[userId] = 'Anonymous';
        }
      }
    }

    setState(() => _isLoadingNames = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Reviews",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (widget.reviews.isEmpty)
              const Text("No reviews yet. Be the first to review!")
            else if (_isLoadingNames)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.reviews.map((review) {
                  final String reviewUserId = review['userId'] ?? 'Anonymous';
                  final String reviewerDisplayName =
                      _userNamesCache[reviewUserId] ??
                      (reviewUserId == widget.customerId
                          ? widget.customerName
                          : 'Anonymous');

                  final reviewRating =
                      (review['rating'] as num?)?.toDouble() ?? 0.0;
                  final reviewComment = review['review'] as String?;
                  final reviewDate = review['createdAt'] != null
                      ? DateFormat(
                          'MMM d, yyyy',
                        ).format(DateTime.parse(review['createdAt']))
                      : '';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                reviewerDisplayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                reviewDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < reviewRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                          if (reviewComment != null &&
                              reviewComment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              reviewComment,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
