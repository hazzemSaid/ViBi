import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class PublicProfilePrivateContent extends StatelessWidget {
  final bool isFollowing;

  const PublicProfilePrivateContent({super.key, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.s24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.r20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
SizedBox(height: AppSizes.s16),
          Text(
            'This profile is private',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            isFollowing
                ? 'You are following this user'
                : 'Follow this user to see their content',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}




