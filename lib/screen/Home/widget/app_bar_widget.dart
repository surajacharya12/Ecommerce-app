import 'package:client/backend_services/cart_services.dart';
import 'package:client/backend_services/notification_service.dart';
import 'package:client/backend_services/wishlist_services.dart';
import 'package:client/screen/Cart/cart.dart';
import 'package:client/screen/Notification/notification.dart';
import 'package:client/screen/wishlist/wishlist.dart';
import 'package:flutter/material.dart';

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
  int wishlistCount = 0;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final cCount = await CartService.getCartCount(widget.userId);
      final wCount = await FavoriteService.getFavorites(
        widget.userId,
      ).then((list) => list.length);
      final nCount = await NotificationService().fetchAllNotifications().then(
        (list) => list.length,
      );

      setState(() {
        cartCount = cCount;
        wishlistCount = wCount;
        notificationCount = nCount;
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  Widget _buildIconWithBadge(IconData icon, int count, VoidCallback onTap) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.black87),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
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
        // Notifications
        _buildIconWithBadge(
          Icons.notifications_outlined,
          notificationCount,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ).then((_) => fetchCounts());
          },
        ),

        // Wishlist
        _buildIconWithBadge(Icons.favorite_outline, wishlistCount, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoritesScreen(
                userId: widget.userId,
                userName: widget.userName,
                userEmail: widget.userEmail,
              ),
            ),
          ).then((_) => fetchCounts());
        }),

        const SizedBox(width: 8),
      ],
    );
  }
}
