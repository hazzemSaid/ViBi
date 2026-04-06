import 'package:flutter/material.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';

import 'profile_sender_row.dart';

class ProfileQuestionCard extends StatelessWidget {
  final AnsweredQuestion answer;
  final String displayName;
  final double questionFontSize;

  const ProfileQuestionCard({
    super.key,
    required this.answer,
    required this.displayName,
    required this.questionFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C212A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSenderRow(answer: answer, displayName: displayName),
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
            answer.questionText,
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
