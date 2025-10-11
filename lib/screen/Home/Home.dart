// home_screen.dart
import 'package:flutter/material.dart';
import 'package:client/screen/Home/widget/app_bar_widget.dart';
import 'package:client/screen/Home/widget/bottom_nav_bar_widget.dart';
import 'package:client/screen/Home/widget/categories_widgets.dart';
import 'package:client/screen/Home/widget/productGritd_widget.dart';
import 'package:client/screen/Home/widget/sections.dart';
import 'package:client/screen/Product/product.dart';
import 'package:client/screen/Profile/profile.dart';
import 'package:client/screen/wishlist/wishlist.dart';
import 'package:client/screen/Cart/cart.dart';

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
    return Scaffold(
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
          // Home
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchBarWidget(),
                const BannerSliderWidget(),
                const CategoriesSection(),
                ProductGridSection(
                  userId: widget.userId,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                ),
              ],
            ),
          ),
          // Products
          ProductPage(
            userId: widget.userId,
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
          // Cart
          CartScreen(userId: widget.userId),
          // Profile
          ProfilePage(userId: widget.userId),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
