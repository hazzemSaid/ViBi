import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';

import 'profile_answer_card/profile_answer_action_row.dart';
import 'profile_answer_card/profile_answer_author_row.dart';
import 'profile_answer_card/profile_question_card.dart';

class ProfileAnswerCard extends StatelessWidget {
  final AnsweredQuestion answer;
  final void Function(String answerId, int reactionsCount, int commentsCount)?
  onCountsChanged;
  final bool compactActions;

  const ProfileAnswerCard({
    super.key,
    required this.answer,
    this.onCountsChanged,
    this.compactActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final bodyFontSize = isTablet ? 17.0 : 15.0;
    final questionFontSize = isTablet ? 20.0 : 18.0;
    final displayName =
        answer.isAnonymous ? 'Anonymous User' : (answer.senderUsername ?? 'Someone');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAnswerAuthorRow(answer: answer),
          const SizedBox(height: 12),
          ProfileQuestionCard(
            answer: answer,
            displayName: displayName,
            questionFontSize: questionFontSize,
          ),
          const SizedBox(height: 16),
          Text(
            answer.answerText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: bodyFontSize,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ProfileAnswerActionRow(
            answer: answer,
            compact: compactActions,
            onShareTap: () {
              context.pushNamed<bool>(
                'share-answer',
                extra: {
                  'questionText': answer.questionText,
                  'answerText': answer.answerText,
                  'username': answer.answererUsername ?? 'me',
                  'isAnonymous': answer.isAnonymous,
                },
              );
            },
            onCountsChanged: onCountsChanged,
          ),
        ],
      ),
    );
  }
}
