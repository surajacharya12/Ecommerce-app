import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

typedef ProductData = Map<String, dynamic>;

class ProductService {
  final String _baseUrl = API_URL;

  Future<List<ProductData>> fetchProducts({String? categoryId}) async {
    String url = '$_baseUrl/products';
    if (categoryId != null && categoryId.isNotEmpty) {
      // Filter by category ID
      url = '$_baseUrl/products?proCategoryId=$categoryId';
    }

    try {
      print('Fetching products from: $url'); // Debug log
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> productList = jsonResponse['data'];
          print('Fetched ${productList.length} products'); // Debug log
          if (categoryId != null && categoryId.isNotEmpty) {
            print('Filtered by category: $categoryId'); // Debug log
          }
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

  Future<ProductData?> fetchProductById(String productId) async {
    final url = '$_baseUrl/products/$productId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          if (jsonResponse['data'] != null &&
              jsonResponse['data'] is Map<String, dynamic>) {
            return jsonResponse['data'] as ProductData;
          } else {
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
      return null;
    }
  }
}
