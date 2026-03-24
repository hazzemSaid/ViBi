import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';

class AnswerAuthorRow extends StatelessWidget {
  const AnswerAuthorRow({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: item.answerAuthorAvatarUrl != null
              ? CachedNetworkImageProvider(item.answerAuthorAvatarUrl!)
              : null,
          backgroundColor: Colors.grey.withOpacity(0.3),
          child: item.answerAuthorAvatarUrl == null
              ? const Icon(Icons.person, color: Colors.white24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.answerAuthorUsername,
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
