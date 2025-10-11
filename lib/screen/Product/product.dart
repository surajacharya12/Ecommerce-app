import 'package:client/screen/Home/widget/product_widgets.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:client/backend_services/product_services.dart';

typedef ProductData = Map<String, dynamic>;

class ProductPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const ProductPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<ProductData>> _productsFuture;
  List<ProductData> _products = [];
  List<ProductData> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _searchController.addListener(_onSearchChanged);
  }

  void _loadProducts() {
    _productsFuture = _productService.fetchProducts();
    _productsFuture.then((data) {
      setState(() {
        _products = data;
        _filteredProducts = _products;
      });
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProductDetails(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
          customerId: widget.userId,
          customerName: widget.userName,
          customerEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Products Grid
            Expanded(
              child: FutureBuilder<List<ProductData>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (_filteredProducts.isEmpty) {
                    return const Center(
                      child: Text("No products match your search."),
                    );
                  }

                  return GridView.builder(
                    itemCount: _filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final rawProductId = product['_id'];
                          String? productId;

                          if (rawProductId is String) {
                            productId = rawProductId;
                          } else if (rawProductId != null) {
                            productId = rawProductId.toString();
                          }

                          if (productId != null) {
                            _navigateToProductDetails(context, productId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Product ID not found or is invalid!',
                                ),
                              ),
                            );
                          }
                        },
                        child: GridProductCard(product: product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
