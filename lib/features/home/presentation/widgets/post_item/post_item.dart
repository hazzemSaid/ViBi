import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_state.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/UserAnswerText.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/action_row.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/answer_author_row.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/post_body_data.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/question_card.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    final horizontalPadding = isTablet ? AppSizes.s24 : AppSizes.s16;
    final questionFontSize = isTablet ? AppSizes.s20 : AppSizes.s16;
    final cardPadding = EdgeInsets.all(isTablet ? AppSizes.s18 : AppSizes.s16);
    final cardMaxWidth = isTablet ? 640.0 : double.infinity;

    return BlocSelector<GlobalFeedCubit, FeedState, PostBodyData>(
      selector: (state) {
        final source = state is FeedLoaded
            ? (feedCubit.getItemById(item.id) ?? item)
            : item;
        return PostBodyData.fromFeedItem(source);
      },
      builder: (context, currentItem) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSizes.s8,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.r24),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnswerAuthorRow(
                        answerAuthorUsername: currentItem.answerAuthorUsername,
                        answerAuthorAvatarUrl:
                            currentItem.answerAuthorAvatarUrl,
                      ),
                      AppSizes.gapH12,
                      QuestionCard(
                        isAnonymous: currentItem.isAnonymous,
                        questionText: currentItem.questionText,
                        displayName: currentItem.displayName,
                        displayAvatar: currentItem.displayAvatar,
                        questionFontSize: questionFontSize,
                        questionType: currentItem.questionType,
                        mediaRec: currentItem.mediaRec,
                        drawingUrl: currentItem.drawingUrl,
                      ),
                      AppSizes.gapH12,
                      UserAnswerText(answerText: currentItem.answerText),
                      AppSizes.gapH12,
                      Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.06),
                      ),
                      AppSizes.gapH4,
                      ActionRow(
                        answerId: currentItem.id,
                        fallbackAnswerText: currentItem.answerText,
                        fallbackQuestionText: currentItem.questionText,
                        fallbackUsername: currentItem.answerAuthorUsername,
                        fallbackIsAnonymous: currentItem.isAnonymous,
                        fallbackDrawingUrl: currentItem.drawingUrl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
