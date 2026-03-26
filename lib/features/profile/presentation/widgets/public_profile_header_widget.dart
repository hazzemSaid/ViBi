import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';

class PublicProfileHeaderWidget extends StatelessWidget {
  final PublicProfile profile;

  const PublicProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.profileImageUrl ?? AppAssets.mockProfile1;
    final name = profile.name ?? 'No name';
    final username = profile.username != null
        ? '@${profile.username}'
        : '@username';
    final bio = profile.bio ?? 'No bio';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSizes.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r20),
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: AppSizes.s24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (profile.isPrivate) ...[
              const SizedBox(width: AppSizes.s8),
              const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.s8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.s16,
            vertical: AppSizes.s4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            username,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
