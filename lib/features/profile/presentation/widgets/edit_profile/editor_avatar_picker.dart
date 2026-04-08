import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/profile_editor_palette.dart';

class EditorAvatarPickerGroup extends StatelessWidget {
  const EditorAvatarPickerGroup({
    super.key,
    required this.imageUrls,
    required this.imageFiles,
    required this.loadingSlot,
    required this.onTapSlot,
    required this.onRemoveSlot,
  });

  final List<String?> imageUrls;
  final List<File?> imageFiles;
  final int? loadingSlot;
  final ValueChanged<int> onTapSlot;
  final ValueChanged<int> onRemoveSlot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final compact = maxWidth < 270;
        final slotSize = compact
            ? ((maxWidth - 16) / 2).clamp(64.0, 80.0)
            : ((maxWidth - 24) / 3).clamp(72.0, 80.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avatars (Max 3)',
              style: TextStyle(
                color: ProfileEditorPalette.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var index = 0; index < 3; index++)
                  _EditorAvatarSlot(
                    size: slotSize,
                    imageUrl: index < imageUrls.length
                        ? imageUrls[index]
                        : null,
                    imageFile: index < imageFiles.length
                        ? imageFiles[index]
                        : null,
                    isMain: index == 0,
                    isLoading: loadingSlot == index,
                    onTap: () => onTapSlot(index),
                    onRemove: () => onRemoveSlot(index),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _EditorAvatarSlot extends StatelessWidget {
  const _EditorAvatarSlot({
    required this.size,
    required this.imageUrl,
    required this.imageFile,
    required this.isMain,
    required this.isLoading,
    required this.onTap,
    required this.onRemove,
  });

  final double size;
  final String? imageUrl;
  final File? imageFile;
  final bool isMain;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (imageFile != null) {
      provider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      provider = NetworkImage(imageUrl!);
    }
    final hasImage = provider != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(1.2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isMain
                    ? ProfileEditorPalette.accent
                    : ProfileEditorPalette.outlineStrong,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.8),
              child: Container(
                color: ProfileEditorPalette.fieldFill,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : provider == null
                    ? const Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          size: 20,
                          color: ProfileEditorPalette.secondaryText,
                        ),
                      )
                    : Image(image: provider, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        if (isMain)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ProfileEditorPalette.accent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
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
        if (hasImage && !isLoading)
          Positioned(
            bottom: -8,
            right: -8,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ProfileEditorPalette.outlineStrong),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: ProfileEditorPalette.secondaryText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
