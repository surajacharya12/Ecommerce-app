import 'package:client/screen/Profile/widgets/orderReview.dart';
import 'package:client/screen/Profile/widgets/shipping.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:client/backend_services/profile_service.dart';
import 'package:client/Auth/login.dart';
import 'package:client/screen/Profile/profile_settings.dart';
import 'package:client/screen/Profile/widgets/profile_avatar.dart';
import 'package:client/screen/Profile/widgets/HelpCenter.dart';
import 'package:client/screen/Profile/widgets/PaymentOptions.dart';
import 'package:client/screen/Profile/widgets/Myreviews.dart';
import 'package:client/screen/Profile/widgets/Order.dart';
import 'package:client/screen/chat/chat_list_screen.dart';
import 'package:client/screen/Profile/returns_screen.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService profileService = ProfileService();
  bool loading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);
    final result = await profileService.getUserProfile(userId: widget.userId);
    if (result['success']) {
      setState(() => userData = result['user']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load profile')),
      );
    }
    setState(() => loading = false);
  }

  Future<void> logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color bgColor = Colors.white,
    Color iconColor = Colors.black87,
    double size = 60,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(2, 6),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [Colors.white, bgColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: size,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = userData?['name'] ?? 'N/A';
    final userEmail = userData?['email'] ?? 'No email';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FF),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadProfile,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileSettingsPage(userId: widget.userId),
                            ),
                          );
                          loadProfile();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ProfileAvatar(photoUrl: userData?['photo'], size: 80),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userData?['phone'] ?? 'No phone number',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // My Orders Section
                    const Text(
                      "My Orders",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        buildActionButton(
                          icon: FontAwesomeIcons.boxOpen,
                          label: "Orders",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserOrdersPage(userId: widget.userId),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.blue.shade50,
                          iconColor: Colors.blueAccent,
                        ),
                        buildActionButton(
                          icon: FontAwesomeIcons.truckFast,
                          label: "Shipping",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Shipping(userId: widget.userId),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.orange.shade50,
                          iconColor: Colors.orangeAccent,
                        ),
                        buildActionButton(
                          icon: FontAwesomeIcons.starHalfStroke,
                          label: "Reviews",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    Orderreview(userId: widget.userId),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.purple.shade50,
                          iconColor: Colors.purpleAccent,
                        ),
                        buildActionButton(
                          icon: FontAwesomeIcons.rotateLeft,
                          label: "Returns",
                          onTap: () {
                            print("Returns button tapped!"); // Debug print
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReturnsScreen(userId: widget.userId),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.red.shade50,
                          iconColor: Colors.redAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Content Management Section
                    const Text(
                      "Content Management",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        buildActionButton(
                          icon: FontAwesomeIcons.envelopeOpenText,
                          label: "Messages",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatListScreen(
                                  customerId: widget.userId,
                                  customerName: userName,
                                  customerEmail: userEmail,
                                ),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.teal.shade50,
                          iconColor: Colors.teal,
                        ),
                        buildActionButton(
                          icon: FontAwesomeIcons.circleQuestion,
                          label: "Help Center",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HelpCenterPage(),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.deepPurple.shade50,
                          iconColor: Colors.deepPurple,
                        ),
                        buildActionButton(
                          icon: FontAwesomeIcons.solidStar,
                          label: "My Reviews",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Myreviews(
                                  userId: widget.userId,
                                  userName: userName,
                                  userEmail: userEmail,
                                ),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.indigo.shade50,
                          iconColor: Colors.indigo,
                        ),
                        buildActionButton(
                          icon: FontAwesomeIcons.creditCard,
                          label: "Payment Options",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentMethodsPage(),
                              ),
                            ).then((_) {
                              if (mounted) loadProfile();
                            });
                          },
                          bgColor: Colors.green.shade50,
                          iconColor: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
