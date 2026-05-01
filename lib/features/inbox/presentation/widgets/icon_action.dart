import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

/**
 * Compact icon-only action button with ink well effect.
 *
 * Takes:
 * - icon to display.
 * - onTap callback for action.
 * - color for icon tint.
 * - optional background color (defaults to surface with low opacity).
 *
 * Returns:
 * - InkWell-based icon action widget.
 *
 * Used for:
 * - Secondary actions such as delete in question cards.
 */
class IconAction extends StatelessWidget {
  const IconAction({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
    this.background,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.r14),
      onTap: onTap,
      child: Ink(
        width: AppSizes.s40,
        height: AppSizes.s40,
        decoration: BoxDecoration(
          color:
              background ?? theme.colorScheme.surface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.r14),
        ),
        child: Icon(icon, color: color, size: AppSizes.iconNormal),
      ),
    );
  }
}
