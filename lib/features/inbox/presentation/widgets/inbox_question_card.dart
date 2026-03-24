import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';

class InboxQuestionCard extends StatelessWidget {
  final InboxQuestion question;
  final VoidCallback? onAnswer;
  final VoidCallback? onDelete;

  const InboxQuestionCard({
    super.key,
    required this.question,
    this.onAnswer,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAnonymous = question.isAnonymous;
    final timeAgo = _getTimeAgo(question.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.r12),
      padding: EdgeInsets.all(AppSizes.r16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sender info or Anonymous
          Row(
            children: [
              // Avatar or Anonymous Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAnonymous
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: isAnonymous
                    ? const Icon(
                        Icons.help_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      )
                    : question.senderAvatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          question.senderAvatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 20,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
              ),
              SizedBox(width: AppSizes.r12),
              // Name/Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAnonymous
                          ? 'Anonymous'
                          : '@${question.senderUsername ?? 'user'}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          SizedBox(height: AppSizes.r12),
          // Question Text
          Text(
            question.questionText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSizes.r12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAnswer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: AppSizes.r12),
                  ),
                  child: const Text(
                    'Answer',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    }
  }
}
