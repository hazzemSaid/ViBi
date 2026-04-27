import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/constants/question_filter_enum.dart';
import 'package:vibi/features/inbox/presentation/view/widgets/filter_tab.dart';

/**
 * Header section with title and filter tabs for inbox screen.
 *
 * Takes:
 * - totalQuestions count for badge display.
 * - selectedFilter for tab highlighting.
 * - onFilterSelected callback for tab changes.
 * - filterQuestionsCount function for badge count.
 *
 * Returns:
 * - Widget containing inbox title, question count badge, and filter tabs.
 *
 * Used for:
 * - Displaying inbox identity and filter controls at top of screen.
 */
class InboxTopBar extends StatelessWidget {
  const InboxTopBar({
    super.key,
    required this.totalQuestions,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.filterQuestionsCount,
  });

  final int totalQuestions;
  final QuestionFilter selectedFilter;
  final void Function(BuildContext, QuestionFilter) onFilterSelected;
  final int Function(int) filterQuestionsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isSmallScreen ? AppSizes.s8 : AppSizes.r12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Inbox',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              AppSizes.gapW12,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.s10,
                  vertical: AppSizes.s4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSizes.rMax),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.whatshot,
                      color: theme.colorScheme.primary,
                      size: AppSizes.iconSmall,
                    ),
                    AppSizes.gapW4,
                    Text(
                      '${filterQuestionsCount(totalQuestions)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? AppSizes.s8 : AppSizes.r12),
          Container(
            padding: AppSizes.p4,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppSizes.r14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilterTab(
                    label: 'All',
                    isSelected: selectedFilter == QuestionFilter.all,
                    onTap: () => onFilterSelected(context, QuestionFilter.all),
                  ),
                ),
                Expanded(
                  child: FilterTab(
                    label: 'Anonymous',
                    isSelected: selectedFilter == QuestionFilter.anonymous,
                    onTap: () =>
                        onFilterSelected(context, QuestionFilter.anonymous),
                  ),
                ),
                Expanded(
                  child: FilterTab(
                    label: 'Friends',
                    isSelected: selectedFilter == QuestionFilter.fromUsers,
                    onTap: () =>
                        onFilterSelected(context, QuestionFilter.fromUsers),
                  ),
                ),
                Expanded(
                  child: FilterTab(
                    label: 'Archived',
                    isSelected: selectedFilter == QuestionFilter.archived,
                    onTap: () =>
                        onFilterSelected(context, QuestionFilter.archived),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
