import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/home/presentation/widgets/story_card.dart';

class AnswerAuthorRow extends StatelessWidget {
  const AnswerAuthorRow({
    super.key,
    required this.answerAuthorUsername,
    this.answerAuthorAvatarUrl,
  });

  final String answerAuthorUsername;
  final String? answerAuthorAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundImage: answerAuthorAvatarUrl != null
              ? ResizeImage(
                  CachedNetworkImageProvider(
                    answerAuthorAvatarUrl!,
                    cacheManager: customCacheManager,
                  ),
                  width: 126,
                  height: 126,
                )
              : null,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          child: answerAuthorAvatarUrl == null
              ? Icon(
                  Icons.person,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                )
              : null,
        ),
        AppSizes.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answerAuthorUsername,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.s16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Answered',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: AppSizes.s12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
          ),
          onPressed: () {
            //TODO: implement more options like ->{
            // - report
            // - block
            // - share
            // - copy
            // - save
            // - etc
            // }
          },
        ),
      ],
    );
  }
}
