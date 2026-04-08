import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
          radius: 20,
          backgroundImage: answerAuthorAvatarUrl != null
              ? ResizeImage(
                  CachedNetworkImageProvider(
                    answerAuthorAvatarUrl!,
                    cacheManager: customCacheManager,
                  ),
                  width: 120,
                  height: 120,
                )
              : null,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          child: answerAuthorAvatarUrl == null
              ? const Icon(Icons.person, color: Colors.white24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answerAuthorUsername,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Answered',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white54),
          onPressed: () {},
        ),
      ],
    );
  }
}
