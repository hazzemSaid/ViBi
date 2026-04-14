import 'package:flutter/material.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

class EditProfileTopBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onPublish;

  const EditProfileTopBar({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border(
          bottom: BorderSide(color: ProfileEditorPalette.outlineStrong),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: ProfileEditorPalette.primaryText,
                ),
              ),
              Expanded(
                child: Text(
                  'Profile Editor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ProfileEditorPalette.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.cloud_upload_outlined,
                        color: ProfileEditorPalette.secondaryText,
                      ),
              ),
              FilledButton(
                onPressed: onPublish,
                style: FilledButton.styleFrom(
                  backgroundColor: ProfileEditorPalette.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 14,
                    vertical: 0,
                  ),
                ),
                child: Text(compact ? 'Go' : 'Publish'),
              ),
            ],
          );
        },
      ),
    );
  }
}
