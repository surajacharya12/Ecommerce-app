import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class OrderService {
  final String baseUrl;

  OrderService({String? baseUrl}) : baseUrl = baseUrl ?? API_URL;

  // Fetch orders for a specific user
  Future<List<dynamic>> getOrdersByUser(String userId, {String? status}) async {
    try {
      Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/orders/orderByUserId/$userId',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) return data['data'];
        throw Exception(data['message']);
      } else {
        throw Exception(
          'Failed to fetch orders. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Cancel an order by ID
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/status');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderStatus': 'cancelled',
          if (reason != null) 'cancellationReason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to cancel order');
        }
      } else {
        throw Exception(
          'Failed to cancel order. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }
}
