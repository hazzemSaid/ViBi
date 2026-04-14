import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';

class SearchContentTile extends StatelessWidget {
  final ContentSearchResult content;

  const SearchContentTile({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the answer detail or user profile
        context.push('/profile/${content.userId}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.s16,
          vertical: AppSizes.s8,
        ),
        padding: EdgeInsets.all(AppSizes.s16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
                  backgroundImage: content.avatarUrl != null
                      ? ResizeImage(
                          CachedNetworkImageProvider(content.avatarUrl!),
                          width: 96,
                          height: 96,
                        )
                      : null,
                  child: content.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                  child: Text(
                    content.isAnonymous
                        ? 'Anonymous'
                        : '@${content.username ?? "unknown"}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  _formatDate(content.createdAt),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.s12),
            // Question
            Text(
              content.questionText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.s8),
            // Answer
            Text(
              content.answerText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.s12),
            // Stats
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                ),
SizedBox(width: 4),
                Text(
                  '${content.likesCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}



