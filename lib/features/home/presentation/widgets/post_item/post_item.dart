import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/presentation/view/cubit/feed_cubit.dart';
import 'package:vibi/features/feed/presentation/view/cubit/feed_state.dart';
import 'package:vibi/features/home/presentation/widgets/post_item/UserAnswerText.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

import 'action_row.dart';
import 'answer_author_row.dart';
import 'question_card.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    final padding = isTablet ? AppSizes.s16 : AppSizes.s20;
    final bodyFontSize = isTablet ? AppSizes.s20 : AppSizes.s12;
    final questionFontSize = isTablet ? AppSizes.s20 : AppSizes.s16;

    return BlocSelector<GlobalFeedCubit, FeedState, _PostBodyData>(
      selector: (state) {
        final source = state is FeedLoaded
            ? (feedCubit.getItemById(item.id) ?? item)
            : item;
        return _PostBodyData.fromFeedItem(source);
      },
      builder: (context, currentItem) {
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnswerAuthorRow(
                answerAuthorUsername: currentItem.answerAuthorUsername,
                answerAuthorAvatarUrl: currentItem.answerAuthorAvatarUrl,
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
              ),
              AppSizes.gapH16,
              UserAnswerText(answerText: currentItem.answerText),
              AppSizes.gapH20,
              ActionRow(
                answerId: currentItem.id,
                fallbackAnswerText: currentItem.answerText,
                fallbackQuestionText: currentItem.questionText,
                fallbackUsername: currentItem.answerAuthorUsername,
                fallbackIsAnonymous: currentItem.isAnonymous,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostBodyData extends Equatable {
  const _PostBodyData({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.answerAuthorUsername,
    required this.answerAuthorAvatarUrl,
    required this.questionText,
    required this.questionType,
    required this.mediaRec,
    required this.answerText,
    required this.isAnonymous,
  });

  factory _PostBodyData.fromFeedItem(FeedItem item) {
    return _PostBodyData(
      id: item.id,
      username: item.username,
      avatarUrl: item.avatarUrl,
      answerAuthorUsername: item.answerAuthorUsername,
      answerAuthorAvatarUrl: item.answerAuthorAvatarUrl,
      questionText: item.questionText,
      questionType: item.questionType,
      mediaRec: item.mediaRec,
      answerText: item.answerText,
      isAnonymous: item.isAnonymous,
    );
  }

  final String id;
  final String username;
  final String? avatarUrl;
  final String answerAuthorUsername;
  final String? answerAuthorAvatarUrl;
  final String questionText;
  final String questionType;
  final TmdbMedia? mediaRec;
  final String answerText;
  final bool isAnonymous;

  String get displayName => isAnonymous ? 'Anonymous User' : username;
  String? get displayAvatar => isAnonymous ? null : avatarUrl;

  @override
  List<Object?> get props => [
    id,
    username,
    avatarUrl,
    answerAuthorUsername,
    answerAuthorAvatarUrl,
    questionText,
    questionType,
    mediaRec,
    answerText,
    isAnonymous,
  ];
}
