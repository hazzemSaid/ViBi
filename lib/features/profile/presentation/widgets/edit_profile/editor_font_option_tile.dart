import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/profile_editor_palette.dart';

class EditorFontOptionTile extends StatelessWidget {
  const EditorFontOptionTile({
    super.key,
    required this.label,
    required this.sample,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sample;
  final String? fontFamily;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: ProfileEditorPalette.fieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? ProfileEditorPalette.primaryText
                : ProfileEditorPalette.outlineStrong,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ProfileEditorPalette.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: fontFamily,
                ),
              ),
            ),
            Text(
              sample,
              style: TextStyle(
                color: ProfileEditorPalette.placeholder,
                fontSize: 12,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
