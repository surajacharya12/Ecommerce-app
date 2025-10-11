import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

typedef ProductData = Map<String, dynamic>;

class ProductService {
  final String _baseUrl = API_URL;

  Future<List<ProductData>> fetchProducts() async {
    final url = '$_baseUrl/products';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> productList = jsonResponse['data'];
          return productList.map((item) => item as ProductData).toList();
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Failed to load products: API error',
          );
        }
      } else {
        throw Exception('Failed to load products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  // --- ADDED THIS METHOD ---
  Future<ProductData?> fetchProductById(String productId) async {
    final url =
        '$_baseUrl/products/$productId'; // Assuming your API endpoint for a single product is /products/:id
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          // Assuming the data for a single product is directly in 'data'
          // or is the root object if 'success' is not used for single fetches.
          if (jsonResponse['data'] != null &&
              jsonResponse['data'] is Map<String, dynamic>) {
            return jsonResponse['data'] as ProductData;
          } else {
            // Handle cases where 'data' might be empty or not a map
            print(
              'Product data not found or invalid format for ID: $productId',
            );
            return null;
          }
        } else {
          print(
            'Failed to load product by ID $productId: ${jsonResponse['message'] ?? 'API error'}',
          );
          return null;
        }
      } else if (response.statusCode == 404) {
        print('Product with ID $productId not found.');
        return null;
      } else {
        print(
          'Failed to load product by ID $productId: HTTP ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching product by ID $productId: $e');
      return null; // Return null on error for individual product fetches
    }
  }
}
