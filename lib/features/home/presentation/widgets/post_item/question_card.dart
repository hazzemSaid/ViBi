import 'package:flutter/material.dart';

import 'sender_row.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.isAnonymous,
    required this.questionText,
    required this.displayName,
    required this.displayAvatar,
    required this.questionFontSize,
  });

  final bool isAnonymous;
  final String questionText;
  final String displayName;
  final String? displayAvatar;
  final double questionFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SenderRow(
            isAnonymous: isAnonymous,
            displayName: displayName,
            displayAvatar: displayAvatar,
          ),
          const SizedBox(height: 12),
          Text(
            'TELL',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
SizedBox(height: 8),
          Text(
            questionText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: questionFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

