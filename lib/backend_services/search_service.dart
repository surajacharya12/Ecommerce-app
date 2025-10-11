import 'package:client/backend_services/categories_services.dart';
import 'package:client/backend_services/product_services.dart';

class SearchService {
  final ProductService _productService = ProductService();

  Future<Map<String, dynamic>> search(String query) async {
    final results = <String, dynamic>{};

    try {
      final products = await _productService.fetchProducts();
      results['products'] = products.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();

      final categories = await CategoryService.fetchCategories();
      results['categories'] = categories.where((category) {
        return category.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error during search: $e');
    }

    return results;
  }
}
