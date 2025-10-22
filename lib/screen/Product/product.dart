import 'package:client/screen/Home/widget/product_widgets.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:client/backend_services/product_services.dart';
import 'package:client/backend_services/categories_services.dart';

typedef ProductData = Map<String, dynamic>;

class ProductPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String? selectedCategoryId; // New parameter to filter products
  final String? selectedCategoryName; // Fallback filter by name
  final String? initialQuery; // Initial search text from Home

  const ProductPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.selectedCategoryId, // Make it optional
    this.selectedCategoryName,
    this.initialQuery,
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

  // Keep track of the currently selected category ID internally
  String? _currentSelectedCategoryId;
  String? _currentSelectedCategoryName;

  @override
  void initState() {
    super.initState();
    _currentSelectedCategoryId = widget.selectedCategoryId;
    _currentSelectedCategoryName = widget.selectedCategoryName;
    if ((widget.initialQuery ?? '').isNotEmpty) {
      // Prefill the search field so user sees their query
      _searchController.text = widget.initialQuery!;
    }
    _loadProducts(categoryId: _currentSelectedCategoryId);

    _searchController.addListener(_onSearchChanged);
  }

  // This method is crucial to react to changes in the parent widget (HomePage)
  @override
  void didUpdateWidget(covariant ProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId ||
        widget.selectedCategoryName != oldWidget.selectedCategoryName) {
      setState(() {
        _currentSelectedCategoryId = widget.selectedCategoryId;
        _currentSelectedCategoryName = widget.selectedCategoryName;
        _searchController.clear(); // Clear search when category changes
        _loadProducts(categoryId: _currentSelectedCategoryId);
      });
    }
  }

  void _loadProducts({String? categoryId}) {
    print('Loading products with categoryId: $categoryId'); // Debug log

    // Always fetch all products first, then filter client-side for reliability
    _productsFuture = _productService.fetchProducts();
    _productsFuture
        .then((data) {
          print('Received ${data.length} products from API'); // Debug log
          setState(() {
            _products = data;

            // Apply category filter if specified
            if (categoryId != null && categoryId.trim().isNotEmpty) {
              print('Filtering products by categoryId: $categoryId');
              _filteredProducts = _products.where((product) {
                final productCategoryId = _extractCategoryId(
                  product['proCategoryId'],
                );
                final match = productCategoryId == categoryId.trim();
                if (match) {
                  print(
                    'Product "${product['name']}" matches category $categoryId',
                  );
                }
                return match;
              }).toList();
              print('Filtered to ${_filteredProducts.length} products');
            } else {
              _filteredProducts = _products;
            }
          });
        })
        .catchError((error) {
          // Handle error, e.g., show a SnackBar
          print('Failed to load products: $error');
          setState(() {
            _products = [];
            _filteredProducts = [];
          });
        });
  }

  String? _extractCategoryId(dynamic categoryData) {
    if (categoryData == null) return null;

    // Handle different formats of category ID
    if (categoryData is String) {
      return categoryData;
    }

    if (categoryData is Map) {
      // Handle populated category object
      final id = categoryData['_id'] ?? categoryData['id'];
      if (id is String) return id;

      // Handle MongoDB ObjectId format
      if (id is Map) {
        final oid = id['\$oid'] ?? id['oid'];
        if (oid is String) return oid;
      }
    }

    return categoryData.toString();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      // Apply search filter to current filtered products (respects category filter)
      List<Map<String, dynamic>> baseProducts = _products;

      // First apply category filter if active
      if (_currentSelectedCategoryId != null &&
          _currentSelectedCategoryId!.trim().isNotEmpty) {
        baseProducts = _products.where((product) {
          final productCategoryId = _extractCategoryId(
            product['proCategoryId'],
          );
          return productCategoryId == _currentSelectedCategoryId!.trim();
        }).toList();
      }

      // Then apply search filter
      _filteredProducts = baseProducts.where((product) {
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
    return Column(
      children: [
        // Quick category chips (modern nav)
        SizedBox(
          height: 44,
          child: FutureBuilder<List<Category>>(
            future: CategoryService.fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              final cats = snapshot.data ?? [];
              if (cats.isEmpty) return const SizedBox.shrink();

              // Add "All Categories" option at the beginning
              final allCategoriesOption = Category(
                id: '',
                name: 'All Categories',
                image: '',
              );
              final allCats = [allCategoriesOption, ...cats];

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final c = allCats[index];
                  final bool isSelected =
                      (c.id.isEmpty && _currentSelectedCategoryId == null) ||
                      (c.id == _currentSelectedCategoryId);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        print(
                          'Category tapped: ${c.name} (ID: ${c.id})',
                        ); // Debug log
                        setState(() {
                          if (c.id.isEmpty) {
                            // "All Categories" selected
                            print('All Categories selected'); // Debug log
                            _currentSelectedCategoryId = null;
                            _currentSelectedCategoryName = null;
                          } else {
                            print(
                              'Category selected: ${c.name} with ID: ${c.id}',
                            ); // Debug log
                            _currentSelectedCategoryId = c.id;
                            _currentSelectedCategoryName = c.name;
                          }
                          _searchController.clear();
                          _loadProducts(categoryId: _currentSelectedCategoryId);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrange : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepOrange
                                : Colors.grey.shade300,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.deepOrange.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          c.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemCount: allCats.length,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: TextField(
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
                  child: Text("No products match your search or category."),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ), // Add padding for grid
                itemCount: _filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
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
    );
  }
}
