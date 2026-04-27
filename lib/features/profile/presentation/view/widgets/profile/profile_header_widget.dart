import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/presentation/view/widgets/profile/profile_image_strip.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile? profile;

  const ProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final avatarUrls = profile?.avatarUrls ?? <String>[];
    final imageUrls = avatarUrls.length > 1 ? avatarUrls : <String>[];
    final fallbackImageUrl = avatarUrls.isNotEmpty
        ? avatarUrls.first
        : AppAssets.mockProfile1;
    final name = profile!.name;
    final username = profile!.username;
    final bio = profile?.bio ?? 'No bio yet...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSizes.s8),
        ProfileImageStrip(
          favColor: AppColors.fromHex(profile?.favColor),
          imageUrls: imageUrls,
          fallbackImageUrl: fallbackImageUrl,
          placeholderInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
        ),
        const SizedBox(height: AppSizes.s24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (profile?.isVerified == true) ...[
              SizedBox(width: AppSizes.s8),
              Icon(
                Icons.verified,
                color: Theme.of(context).colorScheme.secondary,
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            "@$username",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
