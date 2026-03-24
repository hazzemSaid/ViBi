import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final File? imageFile;
  final String? currentImageUrl;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    super.key,
    required this.imageFile,
    required this.currentImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white10,
            backgroundImage: imageFile != null
                ? FileImage(imageFile!)
                : (currentImageUrl != null
                          ? NetworkImage(currentImageUrl!)
                          : null)
                      as ImageProvider?,
            child: imageFile == null && currentImageUrl == null
                ? const Icon(Icons.person, size: 60, color: Colors.white24)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.s8),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
