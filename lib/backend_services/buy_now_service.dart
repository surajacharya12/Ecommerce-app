import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class BuyNowService {
  static final String baseUrl = API_URL;

  /// Prepare Buy Now checkout data for a single product
  static Future<Map<String, dynamic>?> prepareBuyNowCheckout({
    required String productId,
    required String userId,
    required int quantity,
    String? selectedColor,
    String? selectedSize,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
    required String deliveryMethod,
    Map<String, dynamic>? selectedStore,
    String? couponCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/buy-now'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
          'selectedColor': selectedColor,
          'selectedSize': selectedSize,
          'userID': userId,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          'deliveryMethod': deliveryMethod,
          'selectedStore': selectedStore,
          'couponCode': couponCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to prepare checkout');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error preparing buy now checkout: $e');
      return null;
    }
  }

  /// Create order directly (bypassing cart)
  static Future<Map<String, dynamic>?> createDirectOrder({
    required String userId,
    required String productId,
    required String productName,
    required int quantity,
    required double price,
    String? selectedColor,
    String? selectedSize,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
    required String deliveryMethod,
    Map<String, dynamic>? selectedStore,
    String? couponCode,
  }) async {
    try {
      // Calculate totals
      final subtotal = price * quantity;
      final deliveryFee = deliveryMethod == 'homeDelivery' ? 150.0 : 100.0;
      final total = subtotal + deliveryFee;

      final orderData = {
        'userID': userId,
        'items': [
          {
            'productID': productId,
            'productName': productName,
            'quantity': quantity,
            'price': price,
            'selectedColor': selectedColor,
            'selectedSize': selectedSize,
          },
        ],
        'totalPrice': total,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'deliveryMethod': deliveryMethod,
        'selectedStore': selectedStore,
        'couponCode': couponCode,
        'orderTotal': {
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'tax': 0,
          'discount': 0,
          'total': total,
        },
      };

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to create order');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error creating direct order: $e');
      return null;
    }
  }
}
