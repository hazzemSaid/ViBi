import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatarGrid extends StatelessWidget {
  const ProfileAvatarGrid({
    super.key,
    required this.urls,
    required this.files,
    required this.onTap,
    required this.onRemove,
  });

  final List<String?> urls;
  final List<File?> files;
  final void Function(int) onTap;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final hasImage = files[i] != null || urls[i] != null;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
            child: _AvatarSlot(
              file: files[i],
              url: urls[i],
              isPrimary: i == 0,
              onTap: () => onTap(i),
              onRemove: hasImage ? () => onRemove(i) : null,
            ),
          ),
        );
      }),
    );
  }
}

class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({
    required this.file,
    required this.url,
    required this.isPrimary,
    required this.onTap,
    this.onRemove,
  });

  final File? file;
  final String? url;
  final bool isPrimary;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = file != null || url != null;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background / image
              if (file != null)
                Image.file(file!, fit: BoxFit.cover)
              else if (url != null)
                Image.network(url!, fit: BoxFit.cover)
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

              // Camera icon overlay
              if (!hasImage)
                Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                )
              else
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),

              // Remove button (top-right)
              if (onRemove != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ),

              // Primary badge
              if (isPrimary)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Main',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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
}
