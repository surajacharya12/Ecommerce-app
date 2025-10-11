import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/backend_services/profile_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String userId;
  const ProfileSettingsPage({super.key, required this.userId});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final ProfileService profileService = ProfileService();
  bool loading = false;
  Map<String, dynamic>? userData;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final result = await profileService.getUserProfile(userId: widget.userId);
    if (result['success']) {
      setState(() {
        userData = result['user'];
        nameController.text = userData?['name'] ?? '';
      });
    }
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

  /**
   * UPDATED: Separates photo upload from name/password update.
   */
  Future<void> updateProfile() async {
    setState(() => loading = true);

    bool shouldNavigate = true;

    // 1. Handle Photo Upload if a new image is selected
    if (selectedImage != null) {
      final photoUploadResult = await profileService.uploadUserPhoto(
        userId: widget.userId,
        imageFile: selectedImage!,
      );

      if (!photoUploadResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              photoUploadResult['message'] ?? 'Failed to upload photo',
            ),
          ),
        );
        shouldNavigate = false; // Prevent navigation on photo upload failure
      } else {
        // Update local userData with new photo URL
        setState(() {
          userData = photoUploadResult['user'];
        });
      }
    }

    // 2. Update Name and Password only if a name change or password change is requested
    if (nameController.text != userData?['name'] ||
        passwordController.text.isNotEmpty) {
      final result = await profileService.updateUserProfile(
        userId: widget.userId,
        name: nameController.text,
        password: passwordController.text.isEmpty
            ? null
            : passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error updating profile')),
      );

      if (!result['success']) {
        shouldNavigate = false; // Prevent navigation on profile data failure
      }
    } else if (selectedImage != null) {
      // If only the photo was changed, display the photo success message from step 1
    } else {
      // No change made
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save.')));
      shouldNavigate = true;
    }

    setState(() => loading = false);

    // Pop after successful updates (or if no changes were made)
    if (shouldNavigate) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : userData?['photo'] != null
                              ? NetworkImage(userData!['photo'])
                                    as ImageProvider
                              : const AssetImage('assets/default_avatar.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blueAccent,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password (Leave blank to keep current)",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: updateProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
