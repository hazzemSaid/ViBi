import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: _SettingsPalette.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
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
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x4DEF4444)),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            section.title.toUpperCase(),
            style: const TextStyle(
              color: _SettingsPalette.label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _SettingsPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _SettingsPalette.border),
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
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: _SettingsPalette.icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: _SettingsPalette.subtle,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: _SettingsPalette.chevron,
            size: 20,
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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

class _SettingsPalette {
  static const background = Color(0xFF0B0F14);
  static const surface = Color(0xFF0F1724);
  static const border = Color(0xFF333333);
  static const label = Color(0xFF9AA6B2);
  static const subtle = Color(0xFF7A8692);
  static const icon = Color(0xFF9AA6B2);
  static const chevron = Color(0xFF4A5568);
}
