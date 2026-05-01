import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/profile/presentation/cubit/answer_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/answer_state.dart';
import 'package:vibi/features/answer/presentation/widgets/profile_answer_card/profile_answer_card.dart';

class ProfileLatestAnswersSection extends StatelessWidget {
  const ProfileLatestAnswersSection({
    super.key,
    required this.userId,
    this.compactActions = false,
  });
  final String userId;
  final bool compactActions;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserAnswersCubit>()..load(userId),
      child: BlocBuilder<UserAnswersCubit, UserAnswersState>(
        builder: (context, state) {
          final answersCubit = context.read<UserAnswersCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LATEST ANSWERS',
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
              if (state is UserAnswersLoaded) ...[
                Builder(
                  builder: (context) {
                    final answers = state.answers;
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.72),
                            ),
                            SizedBox(height: AppSizes.s16),
                            Text(
                              'No answers yet',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: answers
                          .take(3)
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
              ] else if (state is UserAnswersLoading)
                SizedBox(
                  width: double.infinity,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.s24),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (state is UserAnswersFailure)
                Container(
                  padding: EdgeInsets.all(AppSizes.s16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Text(
                    'Failed to load answers',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
