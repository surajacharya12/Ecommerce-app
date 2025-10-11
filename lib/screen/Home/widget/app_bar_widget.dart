// app_bar_widget.dart
import 'package:client/backend_services/cart_services.dart';
import 'package:client/screen/Cart/cart.dart';
import 'package:flutter/material.dart';
import 'package:client/screen/Notification/notification.dart';
import 'package:client/screen/wishlist/wishlist.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const CustomAppBar({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCartCount();
  }

  Future<void> fetchCartCount() async {
    final count = await CartService.getCartCount(widget.userId);
    setState(() => cartCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'ShopEase',
        style: TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_outline, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                      userId: widget.userId,
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                    ),
                  ),
                ).then((_) => fetchCartCount());
              },
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
