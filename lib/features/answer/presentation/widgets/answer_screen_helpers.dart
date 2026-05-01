import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/inbox/presentation/helpers/user_identity_helpers.dart';

/**
 * Primary pink accent color used throughout the answer screen.
 *
 * Takes:
 * - no arguments.
 *
 * Returns:
 * - Constant Color value (0xFFFE2C55).
 *
 * Used for:
 * - Consistent pink branding on answer composer elements.
 */
const Color pinkColor = Color(0xFFFE2C55);

/**
 * Resolves username from profile cubit or falls back to Supabase metadata.
 *
 * Takes:
 * - BuildContext to watch ProfileCubit.
 *
 * Returns:
 * - Best-effort username string for share attribution.
 *
 * Used for:
 * - Passing user handle into ShareAnswerScreen.
 */
String getUsername(BuildContext context) {
  return resolveCurrentUsername(fallback: 'me');
}

/**
 * Shows validation dialog when user attempts to post empty answer.
 *
 * Takes:
 * - build context for showing dialog.
 *
 * Returns:
 * - void; displays alert dialog with validation message.
 *
 * Used for:
 * - Blocking empty submissions with clear feedback.
 */
void showEmptyAnswerError(BuildContext context) {
  final theme = Theme.of(context);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r18),
      ),
      title: Text(
        'Answer required',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        'Please type your answer before posting.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'OK',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
