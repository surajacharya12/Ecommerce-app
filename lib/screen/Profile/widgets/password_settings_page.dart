import 'package:flutter/material.dart';
import 'package:client/backend_services/profile_service.dart';

class PasswordSettingsPage extends StatefulWidget {
  final String userId;
  const PasswordSettingsPage({super.key, required this.userId});

  @override
  State<PasswordSettingsPage> createState() => _PasswordSettingsPageState();
}

class _PasswordSettingsPageState extends State<PasswordSettingsPage> {
  final ProfileService profileService = ProfileService();
  bool loading = false;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool hideCurrentPassword = true;
  bool hideNewPassword = true;

  Future<void> changePassword() async {
    if (newPasswordController.text.isEmpty) return;

    setState(() => loading = true);

    final result = await profileService.updateUserProfile(
      userId: widget.userId,
      name: '', // backend ignores if only password changes
      password: newPasswordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Error updating password'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );

    setState(() => loading = false);
    if (result['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Settings"),
        backgroundColor: Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Form Card
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildPasswordField(
                            controller: currentPasswordController,
                            label: "Current Password",
                            hidePassword: hideCurrentPassword,
                            onToggle: () => setState(
                              () => hideCurrentPassword = !hideCurrentPassword,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: newPasswordController,
                            label: "New Password",
                            hidePassword: hideNewPassword,
                            onToggle: () => setState(
                              () => hideNewPassword = !hideNewPassword,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool hidePassword,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: hidePassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Colors.deepOrange),
        suffixIcon: IconButton(
          icon: Icon(
            hidePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.deepOrange,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
    );
  }
}
