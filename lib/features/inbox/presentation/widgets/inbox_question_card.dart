import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/constants/question_filter_enum.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/presentation/helpers/question_media_helpers.dart';
import 'package:vibi/features/inbox/presentation/widgets/icon_action.dart';
import 'package:vibi/core/common/widgets/media_card.dart';

/**
 * Individual question card with answer, delete, and archive actions.
 *
 * Takes:
 * - question entity with question data.
 * - accentColor for card left border and avatar background.
 * - onAnswer callback to open reply composer.
 * - onDelete callback to remove question.
 * - onArchive callback to archive question.
 * - onUnarchive callback to restore from archive.
 * - deletingQuestionIds set to track deleting state.
 * - archivingQuestionIds set to track archiving state.
 * - selectedFilter to determine archive/unarchive action.
 * - getTimeAgo function to format creation time.
 *
 * Returns:
 * - Fully styled card widget for one inbox question.
 *
 * Used for:
 * - Rendering each item in the inbox question list.
 */
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.accentColor,
    required this.onAnswer,
    required this.onDelete,
    required this.onArchive,
    required this.onUnarchive,
    required this.deletingQuestionIds,
    required this.archivingQuestionIds,
    required this.selectedFilter,
    required this.getTimeAgo,
  });

  final InboxQuestion question;
  final Color accentColor;
  final VoidCallback onAnswer;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onUnarchive;
  final Set<String> deletingQuestionIds;
  final Set<String> archivingQuestionIds;
  final QuestionFilter selectedFilter;
  final String Function(DateTime) getTimeAgo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final timeAgo = getTimeAgo(question.createdAt);
    final displayName = question.isAnonymous
        ? 'Anonymous'
        : '@${question.senderUsername ?? 'user'}';
    final isArchiving = archivingQuestionIds.contains(question.id);
    final recommendationMedia = buildRecommendationMedia(
      question.mediaRec,
      question.questionText,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r16),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.04),
                border: Border.all(
                  color: theme.colorScheme.surface.withValues(alpha: 0.07),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: AppSizes.s4, color: accentColor),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isSmallScreen ? AppSizes.s10 : AppSizes.r14,
              isSmallScreen ? AppSizes.s10 : AppSizes.r14,
              isSmallScreen ? AppSizes.s10 : AppSizes.r14,
              isSmallScreen ? AppSizes.s10 : AppSizes.r14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: AppSizes.s32,
                      height: AppSizes.s32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: deletingQuestionIds.contains(question.id)
                          ? Center(
                              child: SizedBox(
                                width: AppSizes.s14,
                                height: AppSizes.s14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          : question.isAnonymous
                          ? Padding(
                              padding: EdgeInsets.only(top: AppSizes.s8),
                              child: SvgPicture.asset(
                                'assets/images/anoynemance.svg',
                                colorFilter: ColorFilter.mode(
                                  accentColor,
                                  BlendMode.srcIn,
                                ),
                                width: AppSizes.s32,
                                height: AppSizes.s32,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: question.senderAvatarUrl ?? '',
                              width: AppSizes.s32,
                              height: AppSizes.s32,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) {
                                return Container(
                                  width: AppSizes.s32,
                                  height: AppSizes.s32,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    size: AppSizes.iconNormal,
                                  ),
                                );
                              },
                            ),
                    ),
                    AppSizes.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                displayName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (question.isAnonymous) ...[
                                AppSizes.gapW8,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.s6,
                                    vertical: AppSizes.s4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withValues(
                                      alpha: 0.06,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.r8,
                                    ),
                                  ),
                                  child: Text(
                                    'hidden',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          AppSizes.gapH4,
                          Text(
                            timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isArchiving
                          ? null
                          : (selectedFilter == QuestionFilter.archived
                                ? onUnarchive
                                : onArchive),
                      icon: isArchiving
                          ? SizedBox(
                              width: AppSizes.s18,
                              height: AppSizes.s18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            )
                          : Icon(
                              selectedFilter == QuestionFilter.archived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              size: AppSizes.iconNormal,
                            ),
                    ),
                  ],
                ),
                AppSizes.gapH12,
                if (question.isRecommendation) ...[
                  Text(
                    'Recommendation',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  AppSizes.gapH8,
                  MediaCard(
                    media: recommendationMedia,
                    compact: true,
                    showOverview: true,
                  ),
                ] else
                  Text(
                    question.questionText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.45,
                    ),
                  ),
                AppSizes.gapH12,
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAnswer,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          minimumSize: Size(0, AppSizes.buttonHeightSmall),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.r14),
                          ),
                        ),
                        icon: Icon(
                          Icons.send_rounded,
                          size: AppSizes.iconSmall,
                        ),
                        label: Text(
                          'Reply',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    AppSizes.gapW8,
                    IconAction(
                      icon: Icons.delete_outline,
                      onTap: onDelete,
                      color: Colors.red,
                      background: Colors.red.withValues(alpha: 0.12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
