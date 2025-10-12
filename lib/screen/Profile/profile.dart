import 'package:client/screen/Profile/widgets/HelpCenter.dart';
import 'package:client/screen/Profile/widgets/PaymentOptions.dart';
import 'package:client/screen/Profile/widgets/contactUs.dart';
import 'package:flutter/material.dart';
import 'package:client/backend_services/profile_service.dart';
import 'package:client/screen/Profile/profile_settings.dart';
import 'package:client/screen/Profile/widgets/profile_avatar.dart';
import 'package:client/Auth/login.dart';

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

  Widget buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color bgColor = Colors.white,
    Color iconColor = const Color.fromARGB(255, 69, 69, 70),
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    // Settings Button
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

                    // Profile Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ProfileAvatar(photoUrl: userData?['photo'], size: 70),
                          const SizedBox(height: 12),
                          Text(
                            userData?['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData?['email'] ?? 'No email',
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
                          Icons.local_shipping_rounded,
                          "Orders",
                          () {},
                          bgColor: Colors.white,
                          iconColor: Colors.blueAccent,
                        ),
                        buildActionButton(
                          Icons.local_shipping_outlined,
                          "Shipping",
                          () {},
                          bgColor: Colors.white,
                          iconColor: Colors.orangeAccent,
                        ),
                        buildActionButton(
                          Icons.reviews_outlined,
                          "Reviews",
                          () {},
                          bgColor: Colors.white,
                          iconColor: Colors.purpleAccent,
                        ),
                        buildActionButton(
                          Icons.repeat_rounded,
                          "Returns",
                          () {},
                          bgColor: Colors.white,
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
                          Icons.mail_outline_rounded,
                          "Messages",
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContactUsPage(),
                              ),
                            );
                            loadProfile();
                          },
                          bgColor: Colors.white,
                          iconColor: Colors.teal,
                        ),
                        buildActionButton(
                          Icons.help_center_outlined,
                          "Help Center",
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HelpCenterPage(),
                              ),
                            );
                            loadProfile();
                          },
                          bgColor: Colors.white,
                          iconColor: Colors.deepPurple,
                        ),
                        buildActionButton(
                          Icons.reviews_outlined,
                          "My Reviews",
                          () {},
                          bgColor: Colors.white,
                          iconColor: Colors.indigo,
                        ),
                        buildActionButton(
                          Icons.payment,
                          "Payments \nOptions",
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentMethodsPage(),
                              ),
                            );
                            loadProfile();
                          },
                          bgColor: Colors.white,
                          iconColor: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Logout Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Color.fromARGB(255, 79, 78, 78),
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
