import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final padding = isTablet ? 24.0 : 16.0;
    final bodyFontSize = isTablet ? 17.0 : 15.0;
    final questionFontSize = isTablet ? 20.0 : 18.0;

    final String displayName = item.isAnonymous
        ? 'Anonymous User'
        : item.username;
    final String? displayAvatar = item.isAnonymous ? null : item.avatarUrl;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnswerAuthorRow(item: item),
          const SizedBox(height: 12),
          _QuestionCard(
            item: item,
            displayName: displayName,
            displayAvatar: displayAvatar,
            questionFontSize: questionFontSize,
          ),
          const SizedBox(height: 16),
          Text(
            item.answerText,
            style: TextStyle(color: Colors.white, fontSize: bodyFontSize),
          ),
          const SizedBox(height: 20),
          _ActionRow(item: item),
        ],
      ),
    );
  }
}

class _AnswerAuthorRow extends StatelessWidget {
  const _AnswerAuthorRow({required this.item});

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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.item,
    required this.displayName,
    required this.displayAvatar,
    required this.questionFontSize,
  });

  final FeedItem item;
  final String displayName;
  final String? displayAvatar;
  final double questionFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C212A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SenderRow(
            item: item,
            displayName: displayName,
            displayAvatar: displayAvatar,
          ),
          const SizedBox(height: 12),
          const Text(
            'TELL',
            style: TextStyle(
              color: Color(0xFF6B8AFF),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.questionText,
            style: TextStyle(
              color: Colors.white,
              fontSize: questionFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SenderRow extends StatelessWidget {
  const _SenderRow({
    required this.item,
    required this.displayName,
    required this.displayAvatar,
  });

  final FeedItem item;
  final String displayName;
  final String? displayAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: displayAvatar != null
              ? CachedNetworkImageProvider(displayAvatar!)
              : null,
          backgroundColor: item.isAnonymous
              ? const Color(0xFF5A4FCF).withOpacity(0.3)
              : Colors.grey,
          child: displayAvatar == null
              ? Icon(
                  Icons.person,
                  color: item.isAnonymous
                      ? const Color(0xFF5A4FCF)
                      : Colors.white24,
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.isAnonymous)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A4FCF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Anon',
                          style: TextStyle(
                            color: Color(0xFF5A4FCF),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Text(
                'Asked',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Slightly compact action row on narrow screens
    final spacing = screenWidth < 360 ? 12.0 : 20.0;

    return Row(
      children: [
        const Icon(Icons.favorite_border, color: Color(0xFF5A4FCF), size: 22),
        const SizedBox(width: 6),
        Text(
          '${item.likesCount}',
          style: const TextStyle(
            color: Color(0xFF5A4FCF),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: spacing),
        const Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
        const SizedBox(width: 6),
        Text(
          '${item.commentsCount} Reply',
          style: const TextStyle(color: Colors.white54),
        ),
        SizedBox(width: spacing),
        const Icon(Icons.share_outlined, color: Colors.white54, size: 20),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C212A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Send Tell',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
