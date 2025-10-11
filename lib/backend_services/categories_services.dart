import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class Category {
  final String name;
  final String image;

  Category({required this.name, required this.image});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}

class CategoryService {
  static Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$API_URL/categories');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success']) {
        List<dynamic> categoriesJson = data['data'];
        return categoriesJson
            .map<Category>((cat) => Category.fromJson(cat))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load categories');
      }
    } else {
      throw Exception('Failed to fetch categories from backend');
    }
  }
}
