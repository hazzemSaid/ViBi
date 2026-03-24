import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_dialog.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

class SocialLinkTile extends StatelessWidget {
  final String userId;
  final SocialLink link;
  final Future<void> Function()? onChanged;

  const SocialLinkTile({
    super.key,
    required this.userId,
    required this.link,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.s16,
        vertical: AppSizes.s8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: link.isActive ? 0.05 : 0.02),
        borderRadius: BorderRadius.circular(AppSizes.r14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            socialPlatformIcon(link.platform),
            color: link.isActive ? AppColors.textPrimary : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.displayLabel?.trim().isNotEmpty == true
                      ? link.displayLabel!
                      : (link.title?.trim().isNotEmpty == true
                            ? link.title!
                            : socialPlatformLabel(link.platform)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: link.isActive
                        ? AppColors.textPrimary
                        : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  link.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: link.isActive,
            activeColor: Colors.blueAccent,
            onChanged: (value) => _toggleLink(context, value),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                SocialLinkDialog.show(
                  context,
                  userId,
                  existingLink: link,
                  nextOrder: link.displayOrder,
                  onSaved: onChanged,
                );
              } else if (value == 'move-up') {
                _moveLink(context, moveUp: true);
              } else if (value == 'move-down') {
                _moveLink(context, moveUp: false);
              } else if (value == 'delete') {
                _deleteLink(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'move-up', child: Text('Move up')),
              PopupMenuItem(value: 'move-down', child: Text('Move down')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLink(BuildContext context, bool isActive) async {
    try {
      await Supabase.instance.client
          .from('social_links')
          .update({'is_active': isActive})
          .eq('id', link.id);
      if (onChanged != null) {
        await onChanged!();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update link: $error')),
        );
      }
    }
  }

  Future<void> _deleteLink(BuildContext context) async {
    try {
      await Supabase.instance.client
          .from('social_links')
          .delete()
          .eq('id', link.id);
      if (onChanged != null) {
        await onChanged!();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Social link deleted')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete link: $error')),
        );
      }
    }
  }

  Future<void> _moveLink(BuildContext context, {required bool moveUp}) async {
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('social_links')
          .select('id, display_order')
          .eq('user_id', userId)
          .order('display_order', ascending: true);

      final links = (rows as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();

      final index = links.indexWhere((row) => row['id'] == link.id);
      if (index == -1) return;

      final swapIndex = moveUp ? index - 1 : index + 1;
      if (swapIndex < 0 || swapIndex >= links.length) return;

      final current = links[index];
      final other = links[swapIndex];

      final currentOrder = current['display_order'] as int? ?? index;
      final otherOrder = other['display_order'] as int? ?? swapIndex;

      await client
          .from('social_links')
          .update({'display_order': otherOrder})
          .eq('id', current['id'] as String);
      await client
          .from('social_links')
          .update({'display_order': currentOrder})
          .eq('id', other['id'] as String);

      if (onChanged != null) {
        await onChanged!();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reorder links: $error')),
        );
      }
    }
  }
}
