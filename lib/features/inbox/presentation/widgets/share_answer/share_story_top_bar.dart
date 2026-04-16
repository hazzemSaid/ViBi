import 'package:flutter/material.dart';

/**
 * Header bar for share-story composer.
 *
 * Takes:
 * - [onBack]: Callback to close the composer.
 * - [onPickImage]: Callback to open image picker.
 *
 * Returns:
 * - Top bar widget with title and two circular action buttons.
 *
 * Used for:
 * - Navigation and background image selection in share flow.
 */
class ShareStoryTopBar extends StatelessWidget {
  const ShareStoryTopBar({
    super.key,
    required this.onBack,
    required this.onPickImage,
  });

  final VoidCallback onBack;
  final VoidCallback onPickImage;

  /**
   * Builds the top row with back and gallery actions.
   *
   * Takes:
   * - [context]: Build context.
   *
   * Returns:
   * - Configured top-bar container widget.
   *
   * Used for:
   * - Displaying static header controls for [ShareAnswerScreen].
   */
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back, onTap: onBack),
          const Expanded(
            child: Text(
              'Share Story',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          _CircleButton(icon: Icons.photo_library_outlined, onTap: onPickImage),
        ],
      ),
    );
  }
}

/**
 * Internal circular icon button used in [ShareStoryTopBar].
 *
 * Takes:
 * - [icon]: Icon to display.
 * - [onTap]: Tap callback.
 *
 * Returns:
 * - Gesture-driven circular control.
 *
 * Used for:
 * - Keeping top-bar button styles consistent.
 */
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  /**
   * Builds one circular action button.
   *
   * Takes:
   * - [context]: Build context.
   *
   * Returns:
   * - Tappable circular icon container.
   *
   * Used for:
   * - Back and gallery actions in top bar.
   */
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
