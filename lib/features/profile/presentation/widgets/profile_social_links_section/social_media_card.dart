import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/widgets/social_link_platform.dart';

class SocialMediaCard extends StatelessWidget {
  const SocialMediaCard({
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
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: link.isActive ? 0.06 : 0.03),
        borderRadius: BorderRadius.circular(AppSizes.r14),
        border: Border.all(
          color: link.isActive ? Colors.white24 : Colors.white10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => onLongPress(),
          borderRadius: BorderRadius.circular(AppSizes.r14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.r14,
              vertical: AppSizes.s12,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Icon(
                    socialPlatformIcon(link.platform),
                    color: link.isActive
                        ? AppColors.textPrimary
                        : Colors.white54,
                    size: 22,
                  ),
                ),
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
                              ? AppColors.textPrimary
                              : Colors.white70,
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
                    color: Colors.redAccent.withValues(alpha: 0.7),
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
