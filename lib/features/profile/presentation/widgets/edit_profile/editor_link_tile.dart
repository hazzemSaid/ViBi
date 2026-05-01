import 'package:flutter/material.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/widgets/common/social_link_platform.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/profile_editor_palette.dart';

class EditorLinkTile extends StatelessWidget {
  const EditorLinkTile({
    super.key,
    required this.link,
    required this.onTap,
    required this.onDelete,
    required this.onToggle,
    this.dragHandle,
  });

  final SocialLink link;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final title = link.title?.trim().isNotEmpty == true
        ? link.title!
        : (link.displayLabel?.trim().isNotEmpty == true
              ? link.displayLabel!
              : socialPlatformLabel(link.platform));

    return Material(
      color: Theme.of(context).colorScheme.onSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ProfileEditorPalette.outline),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.07),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              if (dragHandle != null) ...[
                dragHandle!,
                const SizedBox(width: 12),
              ] else ...[
                Icon(
                  socialPlatformIcon(link.platform),
                  color: ProfileEditorPalette.secondaryText,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ProfileEditorPalette.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ProfileEditorPalette.placeholder,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: link.isActive,
                activeColor: ProfileEditorPalette.accent,
                onChanged: onToggle,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: ProfileEditorPalette.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
