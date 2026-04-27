import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

/**
 * Individual filter tab button for inbox filter bar.
 *
 * Takes:
 * - label text to display.
 * - isSelected flag for active state styling.
 * - onTap callback for selection.
 * - optional count badge number.
 *
 * Returns:
 * - Tappable filter tab widget with optional count badge.
 *
 * Used for:
 * - Switching QuestionFilter from top bar in inbox screen.
 */
class FilterTab extends StatelessWidget {
  const FilterTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 350 ? 11.0 : 13.0;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.r8),
      onTap: onTap,
      child: Container(
        height: AppSizes.buttonHeightSmall,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surface.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              AppSizes.gapW6,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.s6,
                  vertical: AppSizes.s4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.rMax),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
