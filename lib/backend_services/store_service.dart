import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class StoreService {
  static final String baseUrl = API_URL;

  static Future<List<Map<String, dynamic>>?> getStoreLocations() async {
    try {
      print('Fetching stores from: $baseUrl/stores');
      final response = await http.get(
        Uri.parse('$baseUrl/stores?isActive=true'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Store API Response Status: ${response.statusCode}');
      print('Store API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final stores = List<Map<String, dynamic>>.from(data['data']);
          print('Successfully fetched ${stores.length} stores');
          return stores;
        } else {
          print('API returned success: false or no data');
          return [];
        }
      } else {
        print('API returned status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching store locations: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      print('Fetching store by ID: $storeId from: $baseUrl/stores/$storeId');
      final response = await http.get(
        Uri.parse('$baseUrl/stores/$storeId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Store by ID API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('Successfully fetched store: ${data['data']['storeName']}');
          return data['data'];
        }
      }
      print('Failed to fetch store by ID');
      return null;
    } catch (e) {
      print('Error fetching store details: $e');
      return null;
    }
  }
}
