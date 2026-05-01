import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/constants/question_filter_enum.dart';

/**
 * Empty-state content for inbox when no questions match filter.
 *
 * Takes:
 * - selectedFilter to determine message text.
 *
 * Returns:
 * - Centered empty-state widget with icon and message.
 *
 * Used for:
 * - Communicating no-data conditions in inbox list.
 */
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.selectedFilter});

  final QuestionFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    String message;
    switch (selectedFilter) {
      case QuestionFilter.all:
        message = 'No questions yet';
        break;
      case QuestionFilter.fromUsers:
        message = 'No questions from users';
        break;
      case QuestionFilter.anonymous:
        message = 'No anonymous questions';
        break;
      case QuestionFilter.archived:
        message = 'No archived questions';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppSizes.p24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: screenHeight * 0.08,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          AppSizes.gapH24,
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSizes.gapH12,
          Text(
            selectedFilter == QuestionFilter.all
                ? 'Questions sent to you will appear here'
                : 'Try selecting a different filter',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
