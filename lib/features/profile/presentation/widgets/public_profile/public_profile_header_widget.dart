import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/presentation/widgets/profile/profile_image_strip.dart';

class PublicProfileHeaderWidget extends StatelessWidget {
  final PublicProfile profile;

  const PublicProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    print(
      'Building PublicProfileHeaderWidget with profile: ${profile.avatarUrls.length} images',
    );
    final imageUrls = profile.avatarUrls;
    final fallbackImageUrl = profile.avatarUrls.isNotEmpty
        ? profile.avatarUrls.first
        : AppAssets.mockProfile1;
    final name = profile.name ?? 'No name';
    final username = profile.username!;
    final bio = profile.bio ?? 'No bio';
    final statusText = profile.statusText;
    final fontFamily = _fontFamilyFor(profile.publicFontFamily);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfileImageStrip(
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
                fontFamily: fontFamily,
              ),
            ),
            if (profile.isPrivate) ...[
              SizedBox(width: AppSizes.s8),
              Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontFamily: fontFamily,
            ),
          ),
        ),
        if (statusText != null && statusText.trim().isNotEmpty) ...[
          const SizedBox(height: AppSizes.s12),
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: fontFamily,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.s16),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            height: 1.4,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  String? _fontFamilyFor(String key) {
    switch (key) {
      case 'google_sans':
        return 'GoogleSans';
      case 'serif':
        return 'serif';
      case 'mono':
        return 'monospace';
      default:
        return 'Inter'; // Default to a specific font for consistency
    }
  }
}
