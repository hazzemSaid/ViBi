import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/inbox/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/public_profile_state.dart';
import 'package:vibi/features/profile/presentation/widgets/answers/profile_answer_card.dart';

class PublicProfileAnswersSection extends StatelessWidget {
  final UserAnswersState answersState;
  final bool compactActions;

  const PublicProfileAnswersSection({
    super.key,
    required this.answersState,
    this.compactActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final answersCubit = context.read<UserAnswersCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANSWERS',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        if (answersState is UserAnswersLoaded) ...[
          Builder(
            builder: (context) {
              final answers = (answersState as UserAnswersLoaded).answers;
              if (answers.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.s24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.r20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                      ),
                      SizedBox(height: AppSizes.s16),
                      Text(
                        'No answers yet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: answers
                    .map(
                      (answer) => ProfileAnswerCard(
                        answer: answer,
                        compactActions: compactActions,
                        onCountsChanged:
                            (answerId, reactionsCount, commentsCount) {
                              answersCubit.patchAnswerCounts(
                                answerId: answerId,
                                reactionsCount: reactionsCount,
                                commentsCount: commentsCount,
                              );
                            },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ] else if (answersState is UserAnswersLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.s24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (answersState is UserAnswersFailure)
          Container(
            padding: EdgeInsets.all(AppSizes.s16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.r12),
            ),
            child: Text(
              'Failed to load answers: ${(answersState as UserAnswersFailure).message}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: AppSizes.s40),
      ],
    );
  }
}
