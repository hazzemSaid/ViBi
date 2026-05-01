import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

/**
 * Share card with profile link copy functionality.
 *
 * Takes:
 * - shareProfileUrl to display and copy.
 * - onCopyProfileLink callback for copy action.
 *
 * Returns:
 * - Promotional card widget encouraging profile sharing.
 *
 * Used for:
 * - Encouraging users to share profile to receive more messages.
 */
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.shareProfileUrl,
    required this.onCopyProfileLink,
  });

  final String shareProfileUrl;
  final VoidCallback onCopyProfileLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.r12),
      padding: EdgeInsets.all(AppSizes.s2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: theme.colorScheme.surface.withValues(alpha: 0.06),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? AppSizes.s10 : AppSizes.r14,
          vertical: isSmallScreen ? AppSizes.s10 : AppSizes.r12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.r14),
          color: Colors.black.withValues(alpha: 0.22),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.s40,
              height: AppSizes.s40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.r14),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                color: theme.colorScheme.primary,
                size: AppSizes.iconSmall,
              ),
            ),
            AppSizes.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share to get messages',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSizes.gapH4,
                  Text(
                    shareProfileUrl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onCopyProfileLink,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: Size(AppSizes.s80, AppSizes.buttonHeightSmall),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
              ),
              icon: Icon(Icons.copy_rounded, size: AppSizes.iconSmall),
              label: Text(
                'Copy',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
