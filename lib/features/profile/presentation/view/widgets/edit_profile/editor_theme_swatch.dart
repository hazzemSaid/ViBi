import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/view/widgets/edit_profile/profile_editor_palette.dart';

class EditorThemeSwatch extends StatelessWidget {
  const EditorThemeSwatch({
    super.key,
    required this.themeKey,
    required this.selected,
    required this.onTap,
  });

  final String themeKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = _ThemePreviewLibrary.preview(themeKey);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 64,
        padding: EdgeInsets.all(selected ? 2 : 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? ProfileEditorPalette.primaryText
                : ProfileEditorPalette.outlineStrong,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: preview.gradient,
            color: preview.color,
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewLibrary {
  static _ThemePreview preview(String key) {
    switch (key) {
      case 'minimal_dark':
        return const _ThemePreview(color: Color(0xFF1A1A2E));
      case 'clean_light':
        return const _ThemePreview(color: Color(0xFFF9FAFB));
      case 'noir_dark':
        return const _ThemePreview(color: Color(0xFF0A0A0A));
      case 'ocean_dark':
        return const _ThemePreview(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1628), Color(0xFF0B1A2A), Color(0xFF0A1E1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'forest_dark':
        return const _ThemePreview(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F14), Color(0xFF0A1A0A), Color(0xFF0B0F14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'sunset_dark':
        return const _ThemePreview(
          gradient: LinearGradient(
            colors: [Color(0xFF2D1B1B), Color(0xFF1A1A0A), Color(0xFF2D1B1B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'violet_dark':
        return const _ThemePreview(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A2E), Color(0xFF0B0F14), Color(0xFF1A0A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'amber_dark':
        return const _ThemePreview(
          gradient: LinearGradient(
            colors: [Color(0xFF2E1A0A), Color(0xFF1A0F0B), Color(0xFF2E1A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'tellonym_dark':
      default:
        return const _ThemePreview(
          gradient: LinearGradient(
            colors: [Color(0xFF2D1B30), Color(0xFF0B0F14), Color(0xFF1A0A1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}

class _ThemePreview {
  const _ThemePreview({this.color, this.gradient});

  final Color? color;
  final Gradient? gradient;
}
