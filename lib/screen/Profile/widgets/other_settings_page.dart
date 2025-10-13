import 'package:client/screen/Profile/widgets/Aboutpage.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OtherSettingsPage extends StatefulWidget {
  const OtherSettingsPage({super.key});

  @override
  State<OtherSettingsPage> createState() => _OtherSettingsPageState();
}

class _OtherSettingsPageState extends State<OtherSettingsPage> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  void _toggleNotifications(bool value) {
    setState(() => notificationsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationsEnabled
              ? "Notifications Enabled"
              : "Notifications Disabled",
        ),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  void _toggleTheme(bool value) {
    setState(() => darkMode = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(darkMode ? "Dark Theme Enabled" : "Light Theme Enabled"),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Future<void> _showAboutApp() async {
    final packageInfo = await PackageInfo.fromPlatform();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About App"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("App Name: ${packageInfo.appName}"),
            Text("Package: ${packageInfo.packageName}"),
            Text("Version: ${packageInfo.version}"),
            Text("Build Number: ${packageInfo.buildNumber}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required Widget leading,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          leading: leading,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: trailing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Other Settings"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Notifications
            _buildSettingCard(
              leading: const Icon(
                Icons.notifications,
                color: Colors.deepOrange,
              ),
              title: "Notifications",
              trailing: Switch(
                value: notificationsEnabled,
                activeColor: Colors.deepOrange,
                onChanged: _toggleNotifications,
              ),
            ),

            // Theme
            _buildSettingCard(
              leading: const Icon(Icons.color_lens, color: Colors.deepOrange),
              title: "Dark Mode",
              trailing: Switch(
                value: darkMode,
                activeColor: Colors.deepOrange,
                onChanged: _toggleTheme,
              ),
            ),

            // About App
            _buildSettingCard(
              leading: const Icon(Icons.info, color: Colors.deepOrange),
              title: "About App",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutAppPage()),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
