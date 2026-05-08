import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/common/widgets/drawing_question_card.dart';
import 'package:vibi/core/common/widgets/full_screen_media_viewer.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';

import 'profile_sender_row.dart';

class ProfileQuestionCard extends StatelessWidget {
  final AnsweredQuestion answer;
  final String displayName;
  final double questionFontSize;

  const ProfileQuestionCard({
    super.key,
    required this.answer,
    required this.displayName,
    required this.questionFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSenderRow(answer: answer, displayName: displayName),
          AppSizes.gapH12,
          Text(
            answer.isDrawing ? 'DRAWING' : 'Tell',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          AppSizes.gapH8,
          if (answer.isDrawing)
            DrawingQuestionCard(
              drawingUrl: answer.drawingUrl!,
              onTap: () => FullScreenMediaViewer.show(
                context,
                answer.drawingUrl!,
              ),
            )
          else
            Text(
              answer.questionText,
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
