import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/profile_editor_palette.dart';

class EditorInputBlock extends StatelessWidget {
  const EditorInputBlock({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.maxLines = 1,
    this.prefixText,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final int maxLines;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ProfileEditorPalette.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: ProfileEditorPalette.primaryText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: ProfileEditorPalette.placeholder),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: ProfileEditorPalette.secondaryText,
            ),
            filled: true,
            fillColor: ProfileEditorPalette.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ProfileEditorPalette.outlineStrong,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ProfileEditorPalette.outlineStrong,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ProfileEditorPalette.primaryText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
