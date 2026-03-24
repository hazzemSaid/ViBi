import 'package:flutter/material.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';

import 'sender_row.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
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
          SenderRow(
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
