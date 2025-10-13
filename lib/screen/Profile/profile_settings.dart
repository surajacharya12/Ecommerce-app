import 'package:flutter/material.dart';
import 'package:client/backend_services/profile_service.dart';
import 'package:client/screen/Profile/widgets/account_settings_page.dart';
import 'package:client/screen/Profile/widgets/other_settings_page.dart';
import 'package:client/screen/Profile/widgets/password_settings_page.dart';
import 'package:client/screen/Profile/widgets/privacy_settings_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String userId;
  const ProfileSettingsPage({super.key, required this.userId});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final ProfileService profileService = ProfileService();
  bool loading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => loading = true);
    final result = await profileService.getUserProfile(userId: widget.userId);
    if (result['success']) {
      userData = result['user'];
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final username = userData?['name'] ?? 'User';
    final photoUrl = userData?['photo'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              color: Colors.deepOrange,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "Hello, $username",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildSettingCard(
                    context,
                    icon: Icons.person,
                    title: "Account",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AccountSettingsPage(userId: widget.userId),
                      ),
                    ),
                  ),
                  _buildSettingCard(
                    context,
                    icon: Icons.lock,
                    title: "Password",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PasswordSettingsPage(userId: widget.userId),
                      ),
                    ),
                  ),
                  _buildSettingCard(
                    context,
                    icon: Icons.privacy_tip,
                    title: "Privacy",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivacySettingsWithInfoPage(),
                      ),
                    ),
                  ),
                  _buildSettingCard(
                    context,
                    icon: Icons.settings,
                    title: "Other Settings",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OtherSettingsPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.deepOrange.withOpacity(0.1),
                child: Icon(icon, color: Colors.deepOrange, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
