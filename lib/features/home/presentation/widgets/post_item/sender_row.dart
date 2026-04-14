import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
          radius: 16,
          backgroundImage: displayAvatar != null
              ? ResizeImage(
                  CachedNetworkImageProvider(
                    displayAvatar!,
                    cacheManager: customCacheManager,
                  ),
                  width: 96,
                  height: 96,
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
                    : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                  size: 16,
                )
              : null,
        ),
        const SizedBox(width: 10),
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
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAnonymous)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Anon',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
Text(
                'Asked',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72), fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

