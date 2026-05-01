import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';
import 'package:vibi/core/common/widgets/media_card.dart';

import 'sender_row.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.isAnonymous,
    required this.questionText,
    required this.displayName,
    required this.displayAvatar,
    required this.questionFontSize,
    required this.questionType,
    this.mediaRec,
  });

  final bool isAnonymous;
  final String questionText;
  final String displayName;
  final String? displayAvatar;
  final double questionFontSize;
  final String questionType;
  final TmdbMedia? mediaRec;

  bool get _isRecommendation =>
      questionType == 'recommendation' && mediaRec != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.r16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SenderRow(
            isAnonymous: isAnonymous,
            displayName: displayName,
            displayAvatar: displayAvatar,
          ),
          AppSizes.gapH12,
          Text(
            _isRecommendation ? 'RECOMMENDATION' : 'Tell',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w900,
              fontSize: AppSizes.s10,
              letterSpacing: 1.5,
            ),
          ),
          AppSizes.gapH8,
          if (_isRecommendation)
            MediaCard(media: mediaRec!, compact: true, showOverview: true)
          else
            Text(
              questionText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: questionFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
