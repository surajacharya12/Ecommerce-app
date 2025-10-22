import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config/api.dart';

class Category {
  final String id;
  final String name;
  final String image; // Assuming category has an image URL

  Category({required this.id, required this.name, required this.image});

  factory Category.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        final oid = value['\$oid'] ?? value['oid'] ?? value['_id'];
        if (oid is String) return oid;
        if (oid is Map) {
          final nested = oid['\$oid'] ?? oid['oid'] ?? oid['_id'];
          if (nested is String) return nested;
        }
      }
      return value.toString();
    }

    return Category(
      id: extractId(json['_id']),
      name: json['name'] as String,
      image: (json['image'] ?? '')
          .toString(), // Adjust key based on your API response
    );
  }
}

class CategoryService {
  static final String _baseUrl = API_URL;

  static Future<List<Category>> fetchCategories() async {
    final url = '$_baseUrl/categories'; // Adjust your category API endpoint
    try {
      print('Fetching categories from: $url'); // Debug log
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> categoryList = jsonResponse['data'];
          print('Fetched ${categoryList.length} categories'); // Debug log

          final categories = categoryList
              .map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList();

          // Debug: Print first few categories
          for (int i = 0; i < categories.length && i < 3; i++) {
            print(
              'Category ${i + 1}: ${categories[i].name} (ID: ${categories[i].id})',
            );
          }

          return categories;
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Failed to load categories: API error',
          );
        }
      } else {
        throw Exception(
          'Failed to load categories: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }
}
