import 'package:flutter/material.dart';
import 'package:client/screen/Home/widget/app_bar_widget.dart';
import 'package:client/screen/Home/widget/bottom_nav_bar_widget.dart';
import 'package:client/screen/Home/widget/categories_widgets.dart';
import 'package:client/screen/Home/widget/productGritd_widget.dart';
import 'package:client/screen/Home/widget/sections.dart';
import 'package:client/screen/Product/product.dart';
import 'package:client/screen/Product/category_products_page.dart';
import 'package:client/screen/Profile/profile.dart';
import 'package:client/screen/Cart/cart.dart';
import 'package:client/screen/Coupons/coupons_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🔒 Disable back button
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          userId: widget.userId,
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: [
            // Home Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(
                    userId: widget.userId,
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                  ),
                  const BannerSliderWidget(),
                  CategoriesSection(
                    onCategoryTap: (categoryId, categoryName) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsPage(
                            userId: widget.userId,
                            userName: widget.userName,
                            userEmail: widget.userEmail,
                            categoryId: categoryId,
                            categoryName: categoryName,
                          ),
                        ),
                      );
                    },
                  ),
                  ProductGridSection(
                    userId: widget.userId,
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Products Tab
            ProductPage(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
            ),
            // Cart Tab
            CartScreen(userId: widget.userId),
            // Coupons Tab
            CouponsScreen(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
            ),
            // Profile Tab
            ProfilePage(userId: widget.userId),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
