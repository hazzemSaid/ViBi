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
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          child: answer.answererAvatarUrl == null
              ? Icon(
                  Icons.person,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answer.answererUsername ?? 'You',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
                  fontSize: 12,
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
          onPressed: () {},
        ),
      ],
    );
  }
}
