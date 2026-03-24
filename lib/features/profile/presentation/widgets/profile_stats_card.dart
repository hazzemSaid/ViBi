import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';

class ProfileStatsCard extends StatelessWidget {
  final String followersCount;
  final String followingCount;
  final String answersCount;
  final String userId;
  final bool isCurrentUser;

  const ProfileStatsCard({
    super.key,
    this.followersCount = '0',
    this.followingCount = '0',
    this.answersCount = '0',
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.r24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: followersCount,
            label: 'Followers',
            onTap: () {
              context.pushNamed(
                'followers-list',
                pathParameters: {'userId': userId},
                extra: isCurrentUser,
              );
            },
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _StatItem(
            value: followingCount,
            label: 'Following',
            onTap: () {
              context.pushNamed(
                'following-list',
                pathParameters: {'userId': userId},
                extra: isCurrentUser,
              );
            },
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _StatItem(value: answersCount, label: 'Answers'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.s4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: child,
        ),
      );
    }

    return child;
  }
}
