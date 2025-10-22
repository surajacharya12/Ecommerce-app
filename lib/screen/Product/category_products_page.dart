import 'package:flutter/material.dart';
import 'package:client/screen/Product/product.dart';

class CategoryProductsPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String categoryId;
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ProductPage(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
          selectedCategoryId: categoryId,
          selectedCategoryName: categoryName,
        ),
      ),
    );
  }
}
