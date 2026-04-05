import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

class EditorButtonStyleTile extends StatelessWidget {
  const EditorButtonStyleTile({
    super.key,
    required this.label,
    required this.selected,
    required this.styleKey,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final String styleKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFilled = styleKey == 'filled' || styleKey == 'pill';
    final isPill = styleKey == 'pill' || styleKey == 'outline_pill';
    final hasShadow = styleKey == 'shadow' || styleKey == 'hard_shadow';
    final background = isFilled
        ? ProfileEditorPalette.primaryText
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 148,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ProfileEditorPalette.fieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? ProfileEditorPalette.primaryText
                : ProfileEditorPalette.outlineStrong,
          ),
        ),
        child: Center(
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(isPill ? 999 : 12),
              border: Border.all(color: ProfileEditorPalette.primaryText),
              boxShadow: hasShadow
                  ? const [
                      BoxShadow(
                        color: ProfileEditorPalette.primaryText,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isFilled
                      ? Colors.white
                      : ProfileEditorPalette.primaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
