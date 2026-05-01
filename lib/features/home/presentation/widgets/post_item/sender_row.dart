import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/home/presentation/widgets/story_card.dart';

class SenderRow extends StatelessWidget {
  const SenderRow({
    super.key,
    required this.isAnonymous,
    required this.displayName,
    required this.displayAvatar,
  });

  final bool isAnonymous;
  final String displayName;
  final String? displayAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: AppSizes.s18,
          backgroundImage: displayAvatar != null
              ? ResizeImage(
                  CachedNetworkImageProvider(
                    displayAvatar!,
                    cacheManager: customCacheManager,
                  ),
                  width: AppSizes.s96.toInt(),
                  height: AppSizes.s96.toInt(),
                )
              : null,
          backgroundColor: isAnonymous
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.onSurfaceVariant,
          child: displayAvatar == null
              ? Icon(
                  Icons.person,
                  color: isAnonymous
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                  size: AppSizes.iconSmall,
                )
              : null,
        ),
        AppSizes.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.s14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                'Asked',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: AppSizes.s10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
