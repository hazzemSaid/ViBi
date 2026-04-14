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
            backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
            backgroundImage: imageFile != null
                ? FileImage(imageFile!)
                : (currentImageUrl != null
                          ? NetworkImage(currentImageUrl!)
                          : null)
                      as ImageProvider?,
            child: imageFile == null && currentImageUrl == null
                ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.35))
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(AppSizes.s8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

