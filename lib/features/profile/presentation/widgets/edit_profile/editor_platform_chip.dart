import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/profile_editor_palette.dart';

class EditorPlatformChip extends StatelessWidget {
  const EditorPlatformChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: ProfileEditorPalette.secondaryText,
        side: const BorderSide(color: ProfileEditorPalette.outlineStrong),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
