import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';
import 'package:vibi/features/home/presentation/providers/feed_providers.dart';
import 'package:vibi/features/home/presentation/providers/feed_state.dart';

import 'post_item/action_row.dart';
import 'post_item/answer_author_row.dart';
import 'post_item/question_card.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final padding = isTablet ? 16.0 : 20.0;
    final bodyFontSize = isTablet ? 20.0 : 12.0;
    final questionFontSize = isTablet ? 20.0 : 18.0;

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
              const SizedBox(height: 12),
              QuestionCard(
                isAnonymous: currentItem.isAnonymous,
                questionText: currentItem.questionText,
                displayName: currentItem.displayName,
                displayAvatar: currentItem.displayAvatar,
                questionFontSize: questionFontSize,
              ),
              const SizedBox(height: 16),
              Text(
                currentItem.answerText,
                style: TextStyle(color: Colors.white, fontSize: bodyFontSize),
              ),
              const SizedBox(height: 20),
              ActionRow(
                answerId: currentItem.id,
                fallbackAnswerText: currentItem.answerText,
                fallbackQuestionText: currentItem.questionText,
                fallbackUsername: currentItem.answerAuthorUsername,
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
    answerText,
    isAnonymous,
  ];
}
