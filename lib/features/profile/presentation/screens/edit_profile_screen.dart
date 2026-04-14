import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/theme/theme_cubit.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const settingsSections = <_SettingsSection>[
      _SettingsSection(
        title: 'Account',
        items: [
          _SettingsItem(
            title: 'Account Information',
            subtitle: 'Email, phone, password',
            icon: Icons.person_outline_rounded,
          ),
          _SettingsItem(
            title: 'Privacy & Safety',
            subtitle: 'Control who can see your content',
            icon: Icons.shield_outlined,
          ),
          _SettingsItem(
            title: 'Blocked Users',
            subtitle: 'Manage blocked accounts',
            icon: Icons.block_outlined,
          ),
        ],
      ),
      _SettingsSection(
        title: 'Preferences',
        items: [
          _SettingsItem(
            title: 'Notifications',
            subtitle: 'Push, email, in-app',
            icon: Icons.notifications_none_rounded,
          ),
          _SettingsItem(
            title: 'Appearance',
            subtitle: 'Theme, colors, display',
            icon: Icons.palette_outlined,
            routeName: 'edit-profile-public-web',
          ),
          _SettingsItem(
            title: 'Language',
            subtitle: 'English',
            icon: Icons.language_rounded,
          ),
        ],
      ),
      _SettingsSection(
        title: 'Support',
        items: [
          _SettingsItem(
            title: 'Help Center',
            subtitle: 'FAQs and support',
            icon: Icons.help_outline_rounded,
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final section in settingsSections) ...[
                      _SettingsSectionCard(section: section),
                      const SizedBox(height: 20),
                    ],
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ImageIcon(
                                    AssetImage(AppAssets.iconSettings),
                                    color: colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'App Theme',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _ThemeModeOption(
                                title: 'System',
                                subtitle: 'Follow device appearance',
                                value: ThemeMode.system,
                                groupValue: themeMode,
                                onChanged: (mode) => context
                                    .read<ThemeCubit>()
                                    .setThemeMode(mode),
                              ),
                              _ThemeModeOption(
                                title: 'Light',
                                subtitle: 'Bright interface all the time',
                                value: ThemeMode.light,
                                groupValue: themeMode,
                                onChanged: (mode) => context
                                    .read<ThemeCubit>()
                                    .setThemeMode(mode),
                              ),
                              _ThemeModeOption(
                                title: 'Dark',
                                subtitle: 'Dimmed interface all the time',
                                value: ThemeMode.dark,
                                groupValue: themeMode,
                                onChanged: (mode) => context
                                    .read<ThemeCubit>()
                                    .setThemeMode(mode),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.35),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage(AppAssets.iconExit),
                              color: colorScheme.error,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.section});

  final _SettingsSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            section.title.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              for (var index = 0; index < section.items.length; index++)
                _SettingsRow(
                  item: section.items[index],
                  showDivider: index > 0,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.showDivider});

  final _SettingsItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.routeName == null
            ? () {}
            : () => context.pushNamed(item.routeName!),
        child: child,
      ),
    );
  }
}

class _SettingsSection {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;
}

class _SettingsItem {
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.routeName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? routeName;
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: (mode) {
        if (mode != null) onChanged(mode);
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: colorScheme.primary,
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
