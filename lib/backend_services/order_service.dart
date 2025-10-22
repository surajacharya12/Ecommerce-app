import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class OrderService {
  static final String baseUrl = API_URL;

  static Future<Map<String, dynamic>?> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
    required String deliveryMethod,
    required double totalPrice,
    required double deliveryFee,
    Map<String, dynamic>? selectedStore,
    String? customerName,
    String? customerPhone,
    Map<String, dynamic>? appliedCoupon,
  }) async {
    try {
      print('Creating order with data:');
      print('User ID: $userId');
      print('Items: $items');
      print('Payment Method: $paymentMethod');
      print('Delivery Method: $deliveryMethod');

      final orderData = {
        'userID': userId,
        'items': items,
        'totalPrice': totalPrice,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'deliveryMethod': deliveryMethod,
        'deliveryFee': deliveryFee,
        'selectedStore': selectedStore,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'appliedCoupon': appliedCoupon,
        'orderTotal': {
          'subtotal': totalPrice - deliveryFee,
          'deliveryFee': deliveryFee,
          'discount': appliedCoupon?['discountAmount'] ?? 0,
          'total': totalPrice,
        },
      };

      print('Sending order data: ${jsonEncode(orderData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      print('Order API Response Status: ${response.statusCode}');
      print('Order API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Order created successfully: ${data['data']['_id']}');
          return data['data'];
        } else {
          print('Order creation failed: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to create order');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}: Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getUserOrders(
    String userId,
  ) async {
    try {
      print('Fetching orders for user: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('User Orders API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final orders = List<Map<String, dynamic>>.from(data['data']);
          print('Successfully fetched ${orders.length} orders');
          return orders;
        }
      }

      print('Failed to fetch user orders');
      return [];
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      print('Fetching order by ID: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Order by ID API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('Successfully fetched order: ${data['data']['_id']}');
          return data['data'];
        }
      }

      print('Failed to fetch order by ID');
      return null;
    } catch (e) {
      print('Error fetching order by ID: $e');
      return null;
    }
  }
}
