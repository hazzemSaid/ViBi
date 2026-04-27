import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/view/widgets/common/social_link_platform.dart';

class SocialMediaCard extends StatelessWidget {
  const SocialMediaCard({
    super.key,
    required this.link,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  final SocialLink link;
  final VoidCallback onTap;
  final Future<void> Function() onLongPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.s12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: link.isActive ? 0.06 : 0.03),
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(
          color: link.isActive
              ? Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35)
              : Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => onLongPress(),
          borderRadius: BorderRadius.circular(AppSizes.r24),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s16,
              vertical: AppSizes.s12,
            ),
            child: Row(
              children: [
                _SocialPlatformImage(link: link),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.s8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialPlatformImage extends StatelessWidget {
  const _SocialPlatformImage({required this.link});

  final SocialLink link;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.22),
          ),
        ),
        child: Center(
          child: socialPlatformVisual(
            link.platform,
            color: link.isActive
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            size: 22,
          ),
        ),
      ),
    );
  }
}
