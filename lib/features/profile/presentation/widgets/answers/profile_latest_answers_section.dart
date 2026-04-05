import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/widgets/answers/profile_answer_card.dart';

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
      child: BlocBuilder<UserAnswersCubit, ViewState<List<AnsweredQuestion>>>(
        builder: (context, answersAsync) {
          final answersCubit = context.read<UserAnswersCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LATEST ANSWERS',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSizes.s16),
              if (answersAsync.status == ViewStatus.success) ...[
                Builder(
                  builder: (context) {
                    final answers = answersAsync.data ?? [];
                    if (answers.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.s24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(height: AppSizes.s16),
                            Text(
                              'No answers yet',
                              style: TextStyle(
                                color: AppColors.textSecondary,
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
              ] else if (answersAsync.status == ViewStatus.loading)
                SizedBox(
                  width: double.infinity,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.s24),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: const Text(
                    'Failed to load answers',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
