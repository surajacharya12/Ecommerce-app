// lib/services/product_details_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart'; // Assuming API_URL is defined here

typedef ProductDetailData = Map<String, dynamic>;

class ProductDetailsService {
  // Ensure API_URL does not have a trailing slash
  final String _baseUrl = API_URL;

  Future<ProductDetailData> fetchProductDetails(String productId) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Map<String, dynamic>.from(jsonResponse['data']);
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Product not found or API error.',
          );
        }
      } else {
        throw Exception(
          'Failed to load product details: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching product details for ID $productId: $e');
      throw Exception('Failed to load product details: $e');
    }
  }

  Future<void> submitProductReview({
    required String productId,
    required String userId,
    required double rating,
    String? review,
  }) async {
    final url = Uri.parse('$_baseUrl/ratings');
    print("📤 Submitting review:");
    print(
      jsonEncode({
        "productId": productId,
        "userId": userId,
        "rating": rating,
        "review": review ?? "",
      }),
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "productId": productId,
        "userId": userId,
        "rating": rating,
        "review": review ?? "",
      }),
    );
    if (response.statusCode != 200) {
      print("❌ Failed to submit: ${response.body}");
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
    print("✅ Review submitted: ${response.body}");
  }

  Future<List<Map<String, dynamic>>> fetchProductReviews(
    String productId,
  ) async {
    final url = Uri.parse('$_baseUrl/ratings/product/$productId');
    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception("Failed to load reviews");
    final jsonData = jsonDecode(response.body);
    if (jsonData['success'] == true) {
      return List<Map<String, dynamic>>.from(jsonData['data']);
    }
    return [];
  }
}
