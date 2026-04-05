import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_constants.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/editor_color_swatch.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/editor_font_option_tile.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/editor_section_card.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/editor_theme_swatch.dart';

class ProfileEditorAppearanceTab extends StatelessWidget {
  const ProfileEditorAppearanceTab({
    super.key,
    required this.publicThemeKey,
    required this.linkButtonStyle,
    required this.favColor,
    required this.publicFontFamily,
    required this.parseHexColor,
    required this.fontFamilyFor,
    required this.onThemeChanged,
    required this.onButtonStyleChanged,
    required this.onFavColorChanged,
    required this.onFontFamilyChanged,
  });

  final String publicThemeKey;
  final String linkButtonStyle;
  final String favColor;
  final String publicFontFamily;
  final Color Function(String) parseHexColor;
  final String? Function(String) fontFamilyFor;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<String> onButtonStyleChanged;
  final ValueChanged<String> onFavColorChanged;
  final ValueChanged<String> onFontFamilyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionCard(
          title: 'Background',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final themeKey in ProfileConstants.publicThemeOptions)
                EditorThemeSwatch(
                  themeKey: themeKey,
                  selected: publicThemeKey == themeKey,
                  onTap: () => onThemeChanged(themeKey),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // TODOs : for now we're only offering one button style, so this section is hidden until we add this feature
        // EditorSectionCard(
        //   title: 'Button Style',
        //   child: Wrap(
        //     spacing: 8,
        //     runSpacing: 8,
        //     children: [
        //       for (final styleKey in ProfileConstants.linkButtonStyleOptions)
        //         EditorButtonStyleTile(
        //           label:
        //               ProfileConstants.linkButtonStyleLabels[styleKey] ??
        //               styleKey,
        //           selected: linkButtonStyle == styleKey,
        //           styleKey: styleKey,
        //           onTap: () => onButtonStyleChanged(styleKey),
        //         ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 16),
        EditorSectionCard(
          title: 'Accent Color',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final colorHex in ProfileConstants.favColorOptions)
                EditorColorSwatch(
                  color: parseHexColor(colorHex),
                  selected: favColor == colorHex,
                  onTap: () => onFavColorChanged(colorHex),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EditorSectionCard(
          title: 'Font',
          child: Column(
            children: [
              for (final fontKey
                  in ProfileConstants.publicFontFamilyOptions) ...[
                EditorFontOptionTile(
                  label:
                      ProfileConstants.publicFontFamilyLabels[fontKey] ??
                      fontKey,
                  sample: 'Aa Bb Cc',
                  fontFamily: fontFamilyFor(fontKey),
                  selected: publicFontFamily == fontKey,
                  onTap: () => onFontFamilyChanged(fontKey),
                ),
                if (fontKey != ProfileConstants.publicFontFamilyOptions.last)
                  const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
