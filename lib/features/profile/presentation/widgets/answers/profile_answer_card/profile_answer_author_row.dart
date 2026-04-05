import 'package:flutter/material.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';

class ProfileAnswerAuthorRow extends StatelessWidget {
  final AnsweredQuestion answer;

  const ProfileAnswerAuthorRow({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: answer.answererAvatarUrl != null
              ? NetworkImage(answer.answererAvatarUrl!)
              : null,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          child: answer.answererAvatarUrl == null
              ? const Icon(Icons.person, color: Colors.white24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answer.answererUsername ?? 'You',
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
