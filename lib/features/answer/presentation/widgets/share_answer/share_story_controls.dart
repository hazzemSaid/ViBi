import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vibi/features/answer/presentation/widgets/share_answer/share_answer_models.dart';

/**
 * Bottom controls panel for story composer actions and style options.
 *
 * Takes:
 * - background presets, card colors, selected indexes and callbacks.
 * - sharing state and gallery image state for visual selection behavior.
 *
 * Returns:
 * - A composed widget section with selectors and share action pills.
 *
 * Used for:
 * - Updating story appearance and triggering save/Instagram share actions.
 */
class ShareStoryControls extends StatelessWidget {
  const ShareStoryControls({
    super.key,
    required this.backgroundPresets,
    required this.cardColors,
    required this.galleryImage,
    required this.selectedBackgroundIndex,
    required this.selectedCardColorIndex,
    required this.isSharing,
    required this.onBackgroundSelected,
    required this.onCardColorSelected,
    required this.onSave,
    required this.onInstagram,
  });

  final List<ShareBackgroundPreset> backgroundPresets;
  final List<Color> cardColors;
  final File? galleryImage;
  final int selectedBackgroundIndex;
  final int selectedCardColorIndex;
  final bool isSharing;
  final ValueChanged<int> onBackgroundSelected;
  final ValueChanged<int> onCardColorSelected;
  final VoidCallback onSave;
  final VoidCallback onInstagram;

  /**
   * Builds the controls area below the preview.
   *
   * Takes:
   * - build context.
   *
   * Returns:
   * - Controls layout with background selector, accent selector, and actions.
   *
   * Used for:
   * - Main interaction surface for share customization.
   */
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('  BACKGROUND'),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: backgroundPresets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _backgroundChip(i),
            ),
          ),
          const SizedBox(height: 10),
          _sectionLabel('  STICKER ACCENT'),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: cardColors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _cardChip(i),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _pill(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  bg: Colors.white.withValues(alpha: 0.07),
                  fg: Colors.white.withValues(alpha: 0.50),
                  onTap: onSave,
                ),
                const SizedBox(width: 8),
                _pill(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1306C), Color(0xFFC13584)],
                  ),
                  onTap: onInstagram,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Builds a compact section title label.
   *
   * Takes:
   * - label text.
   *
   * Returns:
   * - Styled text widget used for control grouping.
   *
   * Used for:
   * - Separating background and sticker accent groups.
   */
  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Inter',
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7,
      color: Colors.white.withValues(alpha: 0.25),
    ),
  );

  /**
   * Builds one selectable background preset chip.
   *
   * Takes:
   * - preset index.
   *
   * Returns:
   * - Tappable animated chip that reflects selected state.
   *
   * Used for:
   * - Choosing gradient or asset-based story backgrounds.
   */
  Widget _backgroundChip(int index) {
    final preset = backgroundPresets[index];
    final isSelected = galleryImage == null && selectedBackgroundIndex == index;

    return GestureDetector(
      onTap: () => onBackgroundSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: preset.isAsset ? null : preset.gradient,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.white.withValues(alpha: 0.10)),
          image: preset.isAsset
              ? DecorationImage(
                  image: AssetImage(preset.assetPath!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  /**
   * Builds one selectable sticker accent color chip.
   *
   * Takes:
   * - card color index.
   *
   * Returns:
   * - Circular color chip with active checkmark when selected.
   *
   * Used for:
   * - Styling the sticker/card accent color.
   */
  Widget _cardChip(int index) {
    final color = cardColors[index];
    final isSelected = selectedCardColorIndex == index;
    final isWhite = color == Colors.white;

    return GestureDetector(
      onTap: () => onCardColorSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(
                  color: isWhite
                      ? Colors.white38
                      : Colors.white.withValues(alpha: 0.10),
                ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 14,
                color: isWhite ? Colors.black : Colors.white,
              )
            : null,
      ),
    );
  }

  /**
   * Builds a pill-shaped action button.
   *
   * Takes:
   * - optional icon, label, optional colors/gradient, and tap callback.
   *
   * Returns:
   * - Expanded pill button that can show loading while sharing.
   *
   * Used for:
   * - Save and Instagram actions in composer footer.
   */
  Widget _pill({
    IconData? icon,
    required String label,
    Color? bg,
    Color? fg,
    LinearGradient? gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isSharing ? null : onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: gradient == null ? (bg ?? Colors.white10) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: isSharing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white54,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, size: 12, color: fg ?? Colors.white),
                      if (icon != null) const SizedBox(width: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: fg ?? Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
