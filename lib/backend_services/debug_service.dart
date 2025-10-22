import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class DebugService {
  static final String _baseUrl = API_URL;

  static Future<void> testCategoryFiltering(String categoryId) async {
    try {
      print('Testing category filtering for: $categoryId');

      // Test the new debug endpoint
      final testUrl = '$_baseUrl/products/test-category/$categoryId';
      print('Testing URL: $testUrl');

      final response = await http.get(Uri.parse(testUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Test Response: ${jsonResponse.toString()}');
      } else {
        print('Test failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Also test the regular products endpoint with filter
      final regularUrl = '$_baseUrl/products?proCategoryId=$categoryId';
      print('Testing regular URL: $regularUrl');

      final regularResponse = await http.get(Uri.parse(regularUrl));

      if (regularResponse.statusCode == 200) {
        final regularJsonResponse = json.decode(regularResponse.body);
        print(
          'Regular Response: Found ${regularJsonResponse['data']?.length ?? 0} products',
        );
        print('Filter applied: ${regularJsonResponse['filter']}');
      } else {
        print('Regular test failed with status: ${regularResponse.statusCode}');
      }
    } catch (e) {
      print('Debug test error: $e');
    }
  }
}
