import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_constants.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: ProfileEditorPalette.outlineStrong),
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
                  child: const Icon(
                    Icons.save_rounded,
                    color: ProfileEditorPalette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Save your changes?',
                    style: TextStyle(
                      color: ProfileEditorPalette.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'You have unsaved edits on your profile. Save now before leaving this screen?',
              style: TextStyle(
                color: ProfileEditorPalette.secondaryText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 170,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(UnsavedExitAction.discard);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: ProfileEditorPalette.primaryText,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Discard',
                      style: TextStyle(color: ProfileEditorPalette.primaryText),
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(UnsavedExitAction.save);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: ProfileEditorPalette.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Save & Exit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(UnsavedExitAction.stay);
                },
                child: const Text('Keep Editing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
