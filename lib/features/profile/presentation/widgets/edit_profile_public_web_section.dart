import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile_section_card.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_form_field.dart';

class EditProfilePublicWebSection extends StatelessWidget {
  const EditProfilePublicWebSection({
    super.key,
    required this.publicProfileEnabled,
    required this.allowAnonymousQuestions,
    required this.ctaController,
    required this.publicThemeKey,
    required this.publicThemeOptions,
    required this.publicThemeLabels,
    required this.publicThemeDescriptions,
    required this.onPublicProfileEnabledChanged,
    required this.onAnonymousChanged,
    required this.onThemeChanged,
  });

  final bool publicProfileEnabled;
  final bool allowAnonymousQuestions;
  final TextEditingController ctaController;
  final String publicThemeKey;
  final List<String> publicThemeOptions;
  final Map<String, String> publicThemeLabels;
  final Map<String, String> publicThemeDescriptions;
  final ValueChanged<bool> onPublicProfileEnabledChanged;
  final ValueChanged<bool> onAnonymousChanged;
  final ValueChanged<String> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return EditProfileSectionCard(
      title: 'Web Share Options',
      subtitle: 'Manage your public profile page and anonymous message flow.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WebHeroCard(
            publicProfileEnabled: publicProfileEnabled,
            allowAnonymousQuestions: allowAnonymousQuestions,
          ),
          const SizedBox(height: AppSizes.s16),
          const Text(
            'Audience',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          _OptionTile(
            title: const Text(
              'Enable public profile page',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'If off, your share link will show unavailable.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            child: Switch.adaptive(
              value: publicProfileEnabled,
              onChanged: onPublicProfileEnabledChanged,
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          _OptionTile(
            title: const Text(
              'Allow anonymous questions',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'Guests can send anonymous messages from your share page.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            child: Switch.adaptive(
              value: allowAnonymousQuestions,
              onChanged: publicProfileEnabled ? onAnonymousChanged : null,
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.s16),
          const Text(
            'Style',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          ProfileFormField(
            label: 'Public CTA text',
            controller: ctaController,
            maxLines: 2,
            validator: (val) {
              if (val != null && val.length > 120) {
                return 'Keep CTA text under 120 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.s12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s12,
              vertical: AppSizes.s8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppSizes.r12),
              border: Border.all(color: Colors.white10),
            ),
            child: DropdownButtonFormField<String>(
              value: publicThemeOptions.contains(publicThemeKey)
                  ? publicThemeKey
                  : publicThemeOptions.first,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Public page theme',
                border: InputBorder.none,
              ),
              items: publicThemeOptions
                  .map(
                    (theme) => DropdownMenuItem<String>(
                      value: theme,
                      child: Text(publicThemeLabels[theme] ?? theme),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                onThemeChanged(value);
              },
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppSizes.r12),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              publicThemeDescriptions[publicThemeKey] ??
                  'Choose a prebuilt template for your public page.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebHeroCard extends StatelessWidget {
  const _WebHeroCard({
    required this.publicProfileEnabled,
    required this.allowAnonymousQuestions,
  });

  final bool publicProfileEnabled;
  final bool allowAnonymousQuestions;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r14),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/photo_2026-03-21_10-25-01.jpg',
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSizes.s12,
            right: AppSizes.s12,
            bottom: AppSizes.s12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Public Profile Experience',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      label: publicProfileEnabled ? 'Public ON' : 'Public OFF',
                      active: publicProfileEnabled,
                    ),
                    _StatusPill(
                      label: allowAnonymousQuestions
                          ? 'Anonymous ON'
                          : 'Anonymous OFF',
                      active: allowAnonymousQuestions,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? AppColors.primary : Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final Widget title;
  final Widget subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 4), subtitle],
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }
}
