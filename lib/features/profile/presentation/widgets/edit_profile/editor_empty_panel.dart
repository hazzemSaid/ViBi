import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/profile_editor_palette.dart';

class EditorEmptyPanel extends StatelessWidget {
  const EditorEmptyPanel({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileEditorPalette.fieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ProfileEditorPalette.outlineStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ProfileEditorPalette.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: ProfileEditorPalette.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
