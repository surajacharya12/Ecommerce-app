import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;

  const ProfileAvatar({super.key, required this.photoUrl, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
          ? NetworkImage(photoUrl!)
          : const AssetImage('assets/default_avatar.png') as ImageProvider,
    );
  }
}
