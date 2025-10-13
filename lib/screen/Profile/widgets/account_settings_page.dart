import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/backend_services/profile_service.dart';

class AccountSettingsPage extends StatefulWidget {
  final String userId;
  const AccountSettingsPage({super.key, required this.userId});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final ProfileService profileService = ProfileService();
  bool loading = false;
  Map<String, dynamic>? userData;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  File? selectedImage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);
    final result = await profileService.getUserProfile(userId: widget.userId);
    if (result['success']) {
      userData = result['user'];
      usernameController.text = userData?['name'] ?? '';
      emailController.text = userData?['email'] ?? '';
      phoneController.text = userData?['phone'] ?? '';
    }
    setState(() => loading = false);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    bool success = true;

    // Upload photo
    if (selectedImage != null) {
      final photoResult = await profileService.uploadUserPhoto(
        userId: widget.userId,
        imageFile: selectedImage!,
      );
      if (!photoResult['success']) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(photoResult['message'] ?? 'Photo upload failed'),
          ),
        );
      } else {
        userData = photoResult['user'];
      }
    }

    // Update profile
    final result = await profileService.updateUserProfile(
      userId: widget.userId,
      name: usernameController.text,
      phone: phoneController.text,
      password: passwordController.text.isNotEmpty
          ? passwordController.text
          : null,
    );

    if (!result['success']) {
      success = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Update failed')),
      );
    } else {
      userData = result['user'];
    }

    setState(() => loading = false);
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepOrange.shade400,
                                  Colors.deepOrange.shade200,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : userData?['photo'] != null
                                  ? NetworkImage(userData!['photo'])
                                  : const AssetImage(
                                          'assets/default_avatar.png',
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.deepOrange,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form Fields Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: usernameController,
                              label: "Username",
                              icon: Icons.person,
                              validatorMessage: "Enter username",
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: emailController,
                              label: "Email",
                              icon: Icons.email,
                              readOnly: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: phoneController,
                              label: "Phone",
                              icon: Icons.phone,
                              validatorMessage: "Enter phone",
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: passwordController,
                              label: "New Password",
                              icon: Icons.lock,
                              obscureText: true,
                              validatorMessage: "Enter password",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Save Changes",
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
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMessage,
    bool readOnly = false,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
      ),
      validator: (v) {
        if (validatorMessage != null && (v == null || v.isEmpty)) {
          return validatorMessage;
        }
        return null;
      },
    );
  }
}
