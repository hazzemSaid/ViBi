import 'package:flutter/material.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';

import 'post_item/action_row.dart';
import 'post_item/answer_author_row.dart';
import 'post_item/question_card.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final padding = isTablet ? 24.0 : 16.0;
    final bodyFontSize = isTablet ? 17.0 : 15.0;
    final questionFontSize = isTablet ? 20.0 : 18.0;

    final String displayName = item.isAnonymous
        ? 'Anonymous User'
        : item.username;
    final String? displayAvatar = item.isAnonymous ? null : item.avatarUrl;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnswerAuthorRow(item: item),
          const SizedBox(height: 12),
          QuestionCard(
            item: item,
            displayName: displayName,
            displayAvatar: displayAvatar,
            questionFontSize: questionFontSize,
          ),
          const SizedBox(height: 16),
          Text(
            item.answerText,
            style: TextStyle(color: Colors.white, fontSize: bodyFontSize),
          ),
          const SizedBox(height: 20),
          ActionRow(item: item),
        ],
      ),
    );
  }
}
