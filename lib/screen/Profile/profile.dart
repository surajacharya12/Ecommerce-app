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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadProfile,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: Colors.blueAccent,
                          size: 26,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileSettingsPage(userId: widget.userId),
                            ),
                          );
                          loadProfile(); // Reload profile after returning from settings
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ProfileAvatar(
                        photoUrl: userData?['photo'],
                        size: 90,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        userData?['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        userData?['email'] ?? 'No email',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 40),
                    Center(
                      child: TextButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
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
