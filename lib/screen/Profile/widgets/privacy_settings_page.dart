import 'package:flutter/material.dart';

class PrivacySettingsWithInfoPage extends StatefulWidget {
  const PrivacySettingsWithInfoPage({super.key});

  @override
  State<PrivacySettingsWithInfoPage> createState() =>
      _PrivacySettingsWithInfoPageState();
}

class _PrivacySettingsWithInfoPageState
    extends State<PrivacySettingsWithInfoPage> {
  bool showProfile = true;
  bool allowMessages = true;
  bool shareUsageData = true;
  bool allowPayments = true;
  bool saveLoading = false;

  Future<void> saveSettings() async {
    setState(() => saveLoading = true);

    // Simulate saving settings
    await Future.delayed(const Duration(seconds: 1));

    setState(() => saveLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Privacy settings saved successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Text(description, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text("Enable"),
            value: value,
            activeColor: Colors.deepOrange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Settings"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingCard(
            title: "Show Profile to Everyone",
            description:
                "Allow other users to view your profile, including your name, photo, and courses you are enrolled in. "
                "Disabling this will hide your profile from others.",
            icon: Icons.person_outline,
            value: showProfile,
            onChanged: (val) => setState(() => showProfile = val),
          ),
          _buildSettingCard(
            title: "Allow Messages from Others",
            description:
                "If enabled, other users can send you messages. You can turn this off to prevent unsolicited messages.",
            icon: Icons.message_outlined,
            value: allowMessages,
            onChanged: (val) => setState(() => allowMessages = val),
          ),
          _buildSettingCard(
            title: "Share Usage Data",
            description:
                "Help us improve the app by sharing anonymous usage data like courses accessed, features used, and app performance.",
            icon: Icons.analytics_outlined,
            value: shareUsageData,
            onChanged: (val) => setState(() => shareUsageData = val),
          ),
          _buildSettingCard(
            title: "Allow Payment Information Storage",
            description:
                "If enabled, we store your payment info securely to make future transactions faster. Your card details are encrypted and never shared.",
            icon: Icons.payment_outlined,
            value: allowPayments,
            onChanged: (val) => setState(() => allowPayments = val),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: saveLoading ? null : saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: saveLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Privacy Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 16),

          _buildInfoSection(
            "Privacy Policy Summary",
            "We respect your privacy and provide full transparency on how we collect, use, and store your data. You can control your visibility, messaging, and payment preferences.",
          ),
          _buildInfoSection(
            "1. Information We Collect",
            "• Profile information: Name, email, photo.\n"
                "• Usage data: Courses viewed, features used, analytics.\n"
                "• Payment info (optional): Card data encrypted and stored securely.\n"
                "• Device info: Type, OS, unique IDs.\n"
                "• Cookies & preferences: To improve user experience.",
          ),
          _buildInfoSection(
            "2. How We Use Your Information",
            "• Improve and personalize services.\n"
                "• Secure and process payments.\n"
                "• Communicate important updates.\n"
                "• Analyze usage trends to enhance app features.",
          ),
          _buildInfoSection(
            "3. Data Security",
            "• All sensitive data is encrypted.\n"
                "• We follow best practices to protect your data.\n"
                "• No method is 100% secure, but we work hard to protect your info.",
          ),
          _buildInfoSection(
            "4. Cookies & Tracking",
            "• We use cookies to remember your preferences and enhance navigation.\n"
                "• You can disable cookies in your device settings, but some features may be limited.",
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
