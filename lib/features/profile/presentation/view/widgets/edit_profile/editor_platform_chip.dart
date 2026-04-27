import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/view/widgets/common/social_link_platform.dart';
import 'package:vibi/features/profile/presentation/view/widgets/edit_profile/profile_editor_palette.dart';

class EditorPlatformChip extends StatelessWidget {
  const EditorPlatformChip({
    super.key,
    required this.platform,
    required this.label,
    required this.onTap,
  });

  final String platform;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: ProfileEditorPalette.secondaryText,
        side: BorderSide(color: ProfileEditorPalette.outlineStrong),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          socialPlatformVisual(
            platform,
            color: ProfileEditorPalette.secondaryText,
            size: 14,
          ),
          Text(label),
        ],
      ),
    );
  }
}
