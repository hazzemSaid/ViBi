import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_stats_card/stat_item.dart';

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
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.r20,
        horizontal: AppSizes.s8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatItem(
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
          Container(width: 1, height: 28, color: Colors.white24),
          StatItem(
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
          Container(width: 1, height: 28, color: Colors.white24),
          StatItem(value: answersCount, label: 'Answers'),
        ],
      ),
    );
  }
}
