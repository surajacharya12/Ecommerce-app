import 'package:flutter/material.dart';
import 'package:client/screen/Home/widget/app_bar_widget.dart';
import 'package:client/screen/Home/widget/bottom_nav_bar_widget.dart';
import 'package:client/screen/Home/widget/categories_widgets.dart'; // Ensure this path is correct
import 'package:client/screen/Home/widget/productGritd_widget.dart'; // Spelling: ProductGrid_widget.dart?
import 'package:client/screen/Home/widget/sections.dart'; // Assuming SearchBarWidget and BannerSliderWidget are here
import 'package:client/screen/Product/product.dart';
import 'package:client/screen/Profile/profile.dart';
import 'package:client/screen/wishlist/wishlist.dart'; // You import wishlist but don't seem to use it in PageView
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
        // Prevents manual swiping between pages, only navigation via bottom nav bar
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          // Update selected index when PageView is programmatically changed (e.g., via _onItemTapped)
          // or if you later decide to allow swiping.
          setState(() => _selectedIndex = index);
        },
        children: [
          // Home Tab Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchBarWidget(), // Assuming this is defined in sections.dart
                const BannerSliderWidget(), // Assuming this is defined in sections.dart
                const CategoriesSection(), // Your categories list
                ProductGridSection(
                  // Your product grid
                  userId: widget.userId,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                ),
                // Add more home screen sections here if needed
                const SizedBox(height: 20), // Add some padding at the bottom
              ],
            ),
          ),
          // Products Tab Content
          ProductPage(
            userId: widget.userId,
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
          // Cart Tab Content
          CartScreen(userId: widget.userId),
          // Profile Tab Content
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
