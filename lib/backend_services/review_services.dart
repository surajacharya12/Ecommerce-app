import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class RatingService {
  final String baseUrl = "$API_URL/ratings";

  // Get all ratings for a product
  Future<List<dynamic>> getRatings(String productId) async {
    final url = Uri.parse("$baseUrl/product/$productId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load ratings.');
      }
    } else {
      throw Exception('Failed to load ratings: ${response.statusCode}');
    }
  }

  // Get all ratings by user
  Future<List<dynamic>> getUserRatings(String userId) async {
    final url = Uri.parse("$baseUrl/user/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load user reviews.');
      }
    } else {
      throw Exception('Failed to load user reviews: ${response.statusCode}');
    }
  }

  // Add or update a rating
  Future<Map<String, dynamic>> addOrUpdateRating({
    required String productId,
    required String userId,
    required double rating,
    String? review,
  }) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "productId": productId,
        "userId": userId,
        "rating": rating,
        "review": review ?? "",
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to submit rating.');
    }
  }

  // Delete a rating
  Future<bool> deleteRating(String ratingId) async {
    final url = Uri.parse("$baseUrl/$ratingId");
    final response = await http.delete(url);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete rating.');
    }
  }
}
