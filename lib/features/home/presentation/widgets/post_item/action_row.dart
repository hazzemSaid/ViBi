import 'package:flutter/material.dart';
import 'package:vibi/core/services/instagram_share_service.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';

class ActionRow extends StatefulWidget {
  const ActionRow({super.key, required this.item});

  final FeedItem item;

  @override
  State<ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<ActionRow> {
  @override
  Future<void> showShareDialogHome(
    String answeredText,
    String questionText,
    String username,
  ) async {
    if (!mounted) return;
    await InstagramShareService.showShareSheet(
      context,
      questionText: questionText,
      answerText: answeredText,
      username: username,
    );
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Slightly compact action row on narrow screens
    final spacing = screenWidth < 360 ? 12.0 : 20.0;

    return Row(
      children: [
        const Icon(Icons.favorite_border, color: Color(0xFF5A4FCF), size: 22),
        const SizedBox(width: 6),
        Text(
          '${widget.item.likesCount}',
          style: const TextStyle(
            color: Color(0xFF5A4FCF),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: spacing),
        const Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
        const SizedBox(width: 6),
        Text(
          '${widget.item.commentsCount} Reply',
          style: const TextStyle(color: Colors.white54),
        ),
        SizedBox(width: spacing),
        IconButton(
          onPressed: () => showShareDialogHome(
            widget.item.answerText,
            widget.item.questionText,
            widget.item.answerAuthorUsername,
          ),
          icon: const Icon(
            Icons.share_outlined,
            color: Colors.white54,
            size: 20,
          ),
        ),
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
