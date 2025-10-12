// app_bar_widget.dart
import 'package:client/backend_services/cart_services.dart';
import 'package:client/screen/Cart/cart.dart';
import 'package:flutter/material.dart';
import 'package:client/screen/Notification/notification.dart';
import 'package:client/screen/wishlist/wishlist.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/backend_services/notification_service.dart';

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
    try {
      final count = await CartService.getCartCount(widget.userId);
      setState(() => cartCount = count);
    } catch (e) {
      print('Error fetching cart count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'ShopSwift',
        style: TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        // Notifications Icon
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () async {
            // Optionally fetch latest notifications before opening
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),

        // Wishlist Icon
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
            ).then((_) => fetchCartCount()); // Refresh cart count if needed
          },
        ),

        // Cart Icon with count badge
        const SizedBox(width: 8),
      ],
    );
  }
}
