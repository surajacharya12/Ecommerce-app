import 'dart:async';
import 'package:client/backend_services/product_services.dart';
import 'package:client/screen/ProductDetails/productdetails_screen.dart';
import 'package:flutter/material.dart';
import 'product_widgets.dart' hide ProductData;

class ProductGridSection extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const ProductGridSection({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProductGridSection> createState() => _ProductGridSectionState();
}

class _ProductGridSectionState extends State<ProductGridSection> {
  // Assuming ProductData is an alias for Map<String, dynamic>
  // or a class with Map-like access based on the usage `product['_id']`
  late Future<List<ProductData>> _productsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProducts();
  }

  void _navigateToProductDetails(BuildContext context, String productId) {
    // This part is now correct because the caller ensures productId is a String
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Popular Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ProductData>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No popular products found.'));
              } else {
                final products = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
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
                      borderRadius: BorderRadius.circular(12),
                      child: GridProductCard(product: product),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
