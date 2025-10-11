import 'package:client/screen/Home/widget/product_widgets.dart';
import 'package:flutter/material.dart';
import 'package:client/backend_services/wishlist_services.dart';
import 'package:client/backend_services/product_services.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';

import 'package:intl/intl.dart';

typedef ProductData = Map<String, dynamic>;

final NumberFormat currencyFormatter = NumberFormat.currency(
  locale: "en_IN",
  symbol: "₹",
  decimalDigits: 2,
);

class FavoritesScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const FavoritesScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<ProductData>> _favoritesFuture;
  final ProductService _productService =
      ProductService(); // Initialize ProductService

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _getFavoriteProducts();
  }

  Future<List<ProductData>> _getFavoriteProducts() async {
    List<String> productIds = await FavoriteService.getFavorites(widget.userId);
    List<ProductData> products = [];

    for (String id in productIds) {
      var product = await _productService.fetchProductById(id);
      if (product != null) products.add(product);
    }
    return products;
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _getFavoriteProducts();
    });
  }

  void _navigateToProductDetails(String productId) {
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
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<ProductData>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No favorites yet."));
          }

          final favorites = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshFavorites,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return InkWell(
                  onTap: () {
                    final dynamic rawProductId = product['_id'];
                    String? productId;

                    if (rawProductId is String) {
                      productId = rawProductId;
                    } else if (rawProductId != null) {
                      productId = rawProductId.toString();
                    }

                    if (productId != null) {
                      _navigateToProductDetails(productId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product ID not found or invalid'),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      GridProductCard(product: product),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool success =
                                await FavoriteService.removeFromFavorites(
                                  widget.userId,
                                  product['_id'],
                                );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Removed from favorites"),
                                ),
                              );
                              _refreshFavorites();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to remove"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
