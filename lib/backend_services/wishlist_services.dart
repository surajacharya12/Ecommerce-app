import 'dart:convert';
import 'package:client/config/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

final String url = API_URL;

class FavoriteService {
  static Future<bool> addToFavorites(String userId, String productId) async {
    final response = await http.post(
      Uri.parse("$url/favorites"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "productId": productId}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> removeFromFavorites(
    String userId,
    String productId,
  ) async {
    final response = await http.delete(
      Uri.parse("$url/favorites/$userId/$productId"),
    );
    return response.statusCode == 200;
  }

  static Future<List<String>> getFavorites(String userId) async {
    final response = await http.get(Uri.parse("$url/favorites/$userId"));
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['data'] is List) {
          // Add null checks for 'data' and 'fav' elements
          return List<String>.from(
            data['data'].map((fav) {
              if (fav is Map<String, dynamic> &&
                  fav['productId'] is Map<String, dynamic> &&
                  fav['productId']['_id'] is String) {
                return fav['productId']['_id'] as String;
              }
              return null; // Return null for invalid items
            }).whereType<String>(), // Filter out nulls
          );
        }
      } catch (e) {
        Text('Error decoding or processing favorites data: $e');
        // Fall through to return []
      }
    }
    return [];
  }
}
