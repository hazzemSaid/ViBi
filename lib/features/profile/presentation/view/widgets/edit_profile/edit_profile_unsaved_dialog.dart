import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/view/widgets/edit_profile/edit_profile_widgets.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ProfileEditorPalette.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.save_rounded,
                    color: ProfileEditorPalette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unsaved changes',
                    style: TextStyle(
                      color: ProfileEditorPalette.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You edited your profile but those changes are not saved yet.',
              style: TextStyle(
                color: ProfileEditorPalette.secondaryText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If you discard, all new edits will be lost.',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                final saveButton = FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(UnsavedExitAction.save);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ProfileEditorPalette.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Save and Exit'),
                );

                final discardButton = OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(UnsavedExitAction.discard);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  label: Text(
                    'Discard Changes',
                    style: TextStyle(color: colorScheme.error),
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      saveButton,
                      const SizedBox(height: 10),
                      discardButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: discardButton),
                    const SizedBox(width: 10),
                    Expanded(child: saveButton),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(UnsavedExitAction.stay);
                },
                style: TextButton.styleFrom(
                  foregroundColor: ProfileEditorPalette.secondaryText,
                ),
                child: const Text('Keep Editing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
