import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/presentation/widgets/profile/profile_stats_card/stat_item.dart';

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
        vertical: AppSizes.s8,
        horizontal: AppSizes.s4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.22),
        ),
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
          Container(
            width: 1,
            height: 28,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
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
          Container(
            width: 1,
            height: 28,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          StatItem(value: answersCount, label: 'Answers'),
        ],
      ),
    );
  }
}
