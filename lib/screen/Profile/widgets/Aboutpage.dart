import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  Text _buildHeader(String text, {required bool isDark}) => Text(
    text,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    ),
  );

  Text _buildBody(String text, {required bool isDark}) => Text(
    text,
    style: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: isDark ? Colors.white : Colors.black87,
    ),
  );

  Widget _buildInfoRow(IconData icon, String info, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(info, style: TextStyle(fontSize: 16, color: color)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About ShopSwift'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Logo or Icon
            Center(
              child: CircleAvatar(
                radius: 50, // circle size
                backgroundColor: const Color.fromARGB(255, 228, 224, 223),
                backgroundImage: AssetImage(
                  'assets/images/logo.png',
                ), // your logo
              ),
            ),

            const SizedBox(height: 16),

            // App Name
            Center(
              child: Text(
                "ShopSwift Nepal",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            _buildBody(
              "ShopSwift is a leading e-commerce platform in Nepal, providing a seamless shopping experience with a wide variety of products, secure payments, and fast delivery.",
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Version
            _buildHeader("Version", isDark: isDark),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final info = snapshot.data!;
                return _buildBody(
                  "${info.version} (Build ${info.buildNumber})",
                  isDark: isDark,
                );
              },
            ),
            const SizedBox(height: 20),

            // Contact Us
            _buildHeader("Contact Us", isDark: isDark),
            const SizedBox(height: 8),
            _buildBody(
              "For any inquiries or support, contact us at:",
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.email,
              "support@shopswift.com",
              Colors.deepOrange,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.phone, "+977 980XXXXXXX", Colors.deepOrange),
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.location_on,
              "Kathmandu, Nepal",
              Colors.deepOrange,
            ),
            const SizedBox(height: 20),

            // Social Media
            _buildHeader("Follow Us", isDark: isDark),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.facebook, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Facebook: /ShopSwiftNepal",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                FaIcon(FontAwesomeIcons.instagram, color: Colors.pink),
                SizedBox(width: 8),
                Text(
                  "Instagram: @ShopSwiftNepal",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mission
            _buildHeader("Our Mission", isDark: isDark),
            const SizedBox(height: 8),
            _buildBody(
              "To provide Nepali customers with a fast, reliable, and enjoyable online shopping experience, while supporting local businesses and products.",
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Privacy & Security
            _buildHeader("Privacy & Security", isDark: isDark),
            const SizedBox(height: 8),
            _buildBody(
              "We prioritize user privacy and secure transactions. All data is encrypted and handled according to our privacy policies.",
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            // Close Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text(
                  "Close",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
