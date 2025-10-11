import 'package:flutter/material.dart';

class ReviewSubmissionSection extends StatefulWidget {
  final Function(double rating, String comment) onSubmitReview;

  const ReviewSubmissionSection({super.key, required this.onSubmitReview});

  @override
  State<ReviewSubmissionSection> createState() =>
      _ReviewSubmissionSectionState();
}

class _ReviewSubmissionSectionState extends State<ReviewSubmissionSection> {
  double userRating = 0.0;
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
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
              "Your Review",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < userRating
                        ? Icons.star
                        : Icons.star_border_outlined,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      userRating = (index + 1).toDouble();
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Write your comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (userRating == 0.0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select a rating before submitting.',
                        ),
                      ),
                    );
                    return;
                  }

                  widget.onSubmitReview(
                    userRating,
                    commentController.text.trim(),
                  );

                  commentController.clear();
                  setState(() => userRating = 0.0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
