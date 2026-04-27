import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/view/widgets/edit_profile/profile_editor_palette.dart';

class EditorSwitchRow extends StatelessWidget {
  const EditorSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: ProfileEditorPalette.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: ProfileEditorPalette.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: ProfileEditorPalette.accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
