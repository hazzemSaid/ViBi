import 'package:flutter/material.dart';
import 'package:vibi/core/common/widgets/drawing_question_card.dart';
import 'package:vibi/core/common/widgets/full_screen_media_viewer.dart';
import 'package:vibi/core/common/widgets/media_card.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

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
    this.drawingUrl,
  });

  final bool isAnonymous;
  final String questionText;
  final String displayName;
  final String? displayAvatar;
  final double questionFontSize;
  final String questionType;
  final TmdbMedia? mediaRec;
  final String? drawingUrl;

  bool get _isRecommendation =>
      questionType == 'recommendation' && mediaRec != null;

  bool get _isDrawing => questionType == 'drawing' && drawingUrl != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeStyle = _QuestionTypeStyle.fromType(questionType, colorScheme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.s14),
      decoration: BoxDecoration(
        color: typeStyle.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSizes.r20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SenderRow(
                  isAnonymous: isAnonymous,
                  displayName: displayName,
                  displayAvatar: displayAvatar,
                ),
              ),
              AppSizes.gapW8,
              _QuestionTypePill(style: typeStyle),
            ],
          ),
          AppSizes.gapH12,
          if (_isRecommendation) ...[
            MediaCard(
              media: mediaRec!,
              compact: true,
              showOverview: true,
              onTap: () =>
                  FullScreenMediaViewer.show(context, mediaRec!.posterUrl),
            ),
          ] else if (_isDrawing) ...[
            DrawingQuestionCard(
              drawingUrl: drawingUrl!,
              onTap: () => FullScreenMediaViewer.show(context, drawingUrl!),
            ),
          ] else ...[
            Text(
              questionText,
              style: TextStyle(
                fontSize: questionFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionTypePill extends StatelessWidget {
  const _QuestionTypePill({required this.style});

  final _QuestionTypeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.s10,
        vertical: AppSizes.s6,
      ),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.rMax),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: AppSizes.s14, color: style.color),
          AppSizes.gapW4,
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontSize: AppSizes.s10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTypeStyle {
  const _QuestionTypeStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  factory _QuestionTypeStyle.fromType(String type, ColorScheme colorScheme) {
    return switch (type) {
      'recommendation' => _QuestionTypeStyle(
        label: 'Pick',
        icon: Icons.movie_filter_outlined,
        color: colorScheme.tertiary,
      ),
      'drawing' => _QuestionTypeStyle(
        label: 'Draw',
        icon: Icons.brush_outlined,
        color: colorScheme.secondary,
      ),
      _ => _QuestionTypeStyle(
        label: 'Ask',
        icon: Icons.chat_bubble_outline_rounded,
        color: colorScheme.primary,
      ),
    };
  }
}
