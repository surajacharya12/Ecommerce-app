import 'dart:convert';
import 'package:client/config/api.dart';
import 'package:http/http.dart' as http;

final String baseUrl = "$API_URL/cart";

class CartService {
  /// Add item to cart
  static Future<bool> addToCart(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      print("❌ addToCart failed: ${response.body}");
    } catch (e) {
      print("❌ addToCart error: $e");
    }
    return false;
  }

  /// Update item quantity in cart
  static Future<bool> updateCartItem(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      print("❌ updateCartItem failed: ${response.body}");
    } catch (e) {
      print("❌ updateCartItem error: $e");
    }
    return false;
  }

  /// Remove item from cart
  static Future<bool> removeFromCart(String userId, String productId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/remove"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "productId": productId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      print("❌ removeFromCart failed: ${response.body}");
    } catch (e) {
      print("❌ removeFromCart error: $e");
    }
    return false;
  }

  /// Clear entire cart
  static Future<bool> clearCart(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/clear/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      print("❌ clearCart failed: ${response.body}");
    } catch (e) {
      print("❌ clearCart error: $e");
    }
    return false;
  }

  /// Get total cart item count
  static Future<int> getCartCount(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/count/$userId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']?['totalItems'] ?? 0;
      }
      print("❌ getCartCount failed: ${response.body}");
    } catch (e) {
      print("❌ getCartCount error: $e");
    }
    return 0;
  }

  /// Get full cart details
  static Future<Map<String, dynamic>?> getCart(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🛒 Cart data fetched: $data');
        return data['data'] ?? data;
      }
      print("❌ getCart failed: ${response.body}");
    } catch (e) {
      print("❌ getCart error: $e");
    }
    return null;
  }
}
