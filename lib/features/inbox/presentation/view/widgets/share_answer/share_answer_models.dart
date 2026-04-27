import 'package:flutter/material.dart';

/**
 * Represents one selectable background option for the share-story composer.
 *
 * Takes:
 * - [gradient]: Gradient used for generated backgrounds.
 * - [assetPath]: Asset image path for photo-style backgrounds.
 *
 * Returns:
 * - Immutable model consumed by preview and controls widgets.
 *
 * Used for:
 * - Rendering and selecting story backgrounds in the inbox share flow.
 */
class ShareBackgroundPreset {
  const ShareBackgroundPreset({this.gradient, this.assetPath});

  final LinearGradient? gradient;
  final String? assetPath;

  bool get isAsset => assetPath != null;
}

/**
 * Available story background presets for [ShareAnswerScreen].
 *
 * Takes:
 * - No runtime input; static list.
 *
 * Returns:
 * - Ordered list of gradient and image presets.
 *
 * Used for:
 * - Horizontal background picker and preview rendering.
 */
const List<ShareBackgroundPreset> shareBackgroundPresets =
    <ShareBackgroundPreset>[
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F0F), Color(0xFF1A1A2E)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFE2C55), Color(0xFF25F4EE)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF857A6), Color(0xFFFF5858)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0ED2F7), Color(0xFF09A6C3)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA8FF78), Color(0xFF78FFD6)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFC4A1A), Color(0xFFF7B733)],
        ),
      ),
      ShareBackgroundPreset(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232526), Color(0xFF414345)],
        ),
      ),
      ShareBackgroundPreset(assetPath: 'assets/images/background1.jpg'),
      ShareBackgroundPreset(assetPath: 'assets/images/background2.jpg'),
      ShareBackgroundPreset(assetPath: 'assets/images/background3.jpg'),
      ShareBackgroundPreset(assetPath: 'assets/images/background4.jpg'),
    ];

/**
 * Accent colors available for the answer sticker/card.
 *
 * Takes:
 * - No runtime input; static list.
 *
 * Returns:
 * - Ordered color palette for card theme selection.
 *
 * Used for:
 * - Sticker accent picker and card styling in preview.
 */
const List<Color> shareCardColors = <Color>[
  Color(0xFFFE2C55),
  Color(0xFFF43F5E),
  Color(0xFF8B5CF6),
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF0EA5E9),
  Color(0xFF000000),
  Color(0xFFFFFFFF),
];
