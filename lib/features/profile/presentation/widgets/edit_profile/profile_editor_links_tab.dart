import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_links_cubit.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_media_cubit_state.dart';
import 'package:vibi/features/profile/presentation/widgets/common/social_link_platform.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

class ProfileEditorLinksTab extends StatefulWidget {
  const ProfileEditorLinksTab({
    super.key,
    required this.avatarUrls,
    required this.avatarFiles,
    required this.avatarLoadingSlot,
    required this.onPickAvatar,
    required this.onRemoveAvatar,
    required this.nameController,
    required this.usernameController,
    required this.bioController,
    required this.statusController,
    required this.ctaController,
    required this.questionPlaceholderController,
    required this.showSocialIcons,
    required this.allowAnonymousQuestions,
    required this.publicProfileEnabled,
    required this.onShowSocialIconsChanged,
    required this.onAllowAnonymousChanged,
    required this.onPublicProfileEnabledChanged,
    required this.socialLinksCubit,
    required this.onDeleteLink,
    required this.onToggleLink,
    required this.onSaveSocialLink,
    required this.onReorderLinks,
    required this.socialAccountLinksFor,
    required this.customLinksFor,
    this.usernameErrorText,
    this.onUsernameChanged,
  });

  final List<String?> avatarUrls;
  final List<File?> avatarFiles;
  final int? avatarLoadingSlot;
  final ValueChanged<int> onPickAvatar;
  final ValueChanged<int> onRemoveAvatar;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final TextEditingController statusController;
  final TextEditingController ctaController;
  final TextEditingController questionPlaceholderController;
  final bool showSocialIcons;
  final bool allowAnonymousQuestions;
  final bool publicProfileEnabled;
  final ValueChanged<bool> onShowSocialIconsChanged;
  final ValueChanged<bool> onAllowAnonymousChanged;
  final ValueChanged<bool> onPublicProfileEnabledChanged;
  final SocialLinksCubit? socialLinksCubit;
  final Future<void> Function(SocialLink) onDeleteLink;
  final Future<void> Function(SocialLink, bool) onToggleLink;
  final Future<void> Function({
    required String platform,
    required String username,
    SocialLink? existingLink,
  })
  onSaveSocialLink;
  final Future<void> Function(List<SocialLink>, int, int) onReorderLinks;
  final List<SocialLink> Function(List<SocialLink>) socialAccountLinksFor;
  final List<SocialLink> Function(List<SocialLink>) customLinksFor;
  final String? usernameErrorText;
  final ValueChanged<String>? onUsernameChanged;

  @override
  State<ProfileEditorLinksTab> createState() => _ProfileEditorLinksTabState();
}

class _ProfileEditorLinksTabState extends State<ProfileEditorLinksTab> {
  final Map<String, TextEditingController> _usernameControllers =
      <String, TextEditingController>{};
  final Map<String, String> _usernameSnapshots = <String, String>{};
  final TextEditingController _pendingUsernameController =
      TextEditingController();
  final Set<String> _savingLinkIds = <String>{};
  String? _pendingPlatform;
  bool _isPendingSaveInProgress = false;
  bool _isSocialAccordionOpen = true;

  @override
  void dispose() {
    for (final controller in _usernameControllers.values) {
      controller.dispose();
    }
    _pendingUsernameController.dispose();
    super.dispose();
  }

  TextEditingController _controllerForLink(SocialLink link) {
    final username = usernameFromSocialUrl(link.platform, link.url);
    final controller = _usernameControllers.putIfAbsent(
      link.id,
      () => TextEditingController(text: username),
    );

    if (_usernameSnapshots[link.id] != username &&
        controller.text != username) {
      controller.text = username;
    }
    _usernameSnapshots[link.id] = username;

    return controller;
  }

  void _pruneControllers(List<SocialLink> socialLinks) {
    final activeIds = socialLinks.map((link) => link.id).toSet();
    final staleIds = _usernameControllers.keys
        .where((id) => !activeIds.contains(id))
        .toList();

    for (final id in staleIds) {
      _usernameControllers.remove(id)?.dispose();
      _usernameSnapshots.remove(id);
      _savingLinkIds.remove(id);
    }
  }

  bool _isValidUsername(String raw) {
    final normalized = normalizeSocialUsername(raw);
    if (normalized.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(normalized);
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveExistingLink(SocialLink link) async {
    final controller = _controllerForLink(link);
    final username = normalizeSocialUsername(controller.text);
    if (!_isValidUsername(username)) {
      _showValidationMessage('Enter a valid username to save this account.');
      return;
    }

    setState(() => _savingLinkIds.add(link.id));
    try {
      await widget.onSaveSocialLink(
        platform: link.platform,
        username: username,
        existingLink: link,
      );
      controller.text = username;
    } finally {
      if (mounted) {
        setState(() => _savingLinkIds.remove(link.id));
      }
    }
  }

  Future<void> _savePendingLink() async {
    final platform = _pendingPlatform;
    if (platform == null) return;

    final username = normalizeSocialUsername(_pendingUsernameController.text);
    if (!_isValidUsername(username)) {
      _showValidationMessage('Enter a valid username before adding this link.');
      return;
    }

    setState(() => _isPendingSaveInProgress = true);
    try {
      await widget.onSaveSocialLink(platform: platform, username: username);
      if (!mounted) return;
      setState(() {
        _pendingPlatform = null;
        _pendingUsernameController.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _isPendingSaveInProgress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionCard(
          title: 'Profile',
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditorAvatarPickerGroup(
                          imageUrls: widget.avatarUrls,
                          imageFiles: widget.avatarFiles,
                          loadingSlot: widget.avatarLoadingSlot,
                          onTapSlot: widget.onPickAvatar,
                          onRemoveSlot: widget.onRemoveAvatar,
                        ),
                        const SizedBox(height: 14),
                        EditorInputBlock(
                          label: 'Display Name',
                          controller: widget.nameController,
                          hintText: 'Your display name',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Display name is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        EditorInputBlock(
                          label: 'Bio',
                          controller: widget.bioController,
                          hintText: 'Ask people about yourself',
                          maxLines: 3,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: EditorAvatarPickerGroup(
                          imageUrls: widget.avatarUrls,
                          imageFiles: widget.avatarFiles,
                          loadingSlot: widget.avatarLoadingSlot,
                          onTapSlot: widget.onPickAvatar,
                          onRemoveSlot: widget.onRemoveAvatar,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            EditorInputBlock(
                              label: 'Display Name',
                              controller: widget.nameController,
                              hintText: 'Your display name',
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Display name is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            EditorInputBlock(
                              label: 'Bio',
                              controller: widget.bioController,
                              hintText: 'Ask people about yourself',
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              EditorSwitchRow(
                title: 'Show social icons',
                subtitle: 'Display active social accounts on your public page',
                value: widget.showSocialIcons,
                onChanged: widget.onShowSocialIconsChanged,
              ),
              const SizedBox(height: 12),
              EditorInputBlock(
                label: 'Username',
                controller: widget.usernameController,
                hintText: 'username',
                prefixText: '@',
                errorText: widget.usernameErrorText,
                onChanged: widget.onUsernameChanged,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Username is required';
                  if (trimmed.length < 3) return 'Username is too short';
                  if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(trimmed)) {
                    return 'Use letters, numbers, ., _, or -';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              EditorInputBlock(
                label: 'Status Text',
                controller: widget.statusController,
                hintText: 'Available for work',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EditorSectionCard(
          title: 'Social Media',
          child: BlocBuilder<SocialLinksCubit, SocialLinksState>(
            bloc: widget.socialLinksCubit,
            builder: (context, state) {
              final allLinks = switch (state) {
                SocialLinksLoaded loaded => loaded.links,
                SocialLinksLoading loading => loading.previousLinks,
                SocialLinksFailure failure => failure.previousLinks,
                _ => const <SocialLink>[],
              };
              final socialLinks = widget.socialAccountLinksFor(allLinks);
              _pruneControllers(socialLinks);

              final linkedPlatforms = socialLinks
                  .map((link) => link.platform)
                  .toSet();
              final availablePlatforms = kDatabaseSocialPlatforms
                  .where(
                    (platform) =>
                        platform != 'custom' &&
                        platform != 'website' &&
                        !linkedPlatforms.contains(platform),
                  )
                  .toList();

              return ExpansionTile(
                initiallyExpanded: _isSocialAccordionOpen,
                onExpansionChanged: (isOpen) {
                  setState(() => _isSocialAccordionOpen = isOpen);
                },
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                title: Text(
                  'Manage Social Media',
                  style: TextStyle(
                    color: ProfileEditorPalette.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Add your social accounts using username only.',
                  style: TextStyle(
                    color: ProfileEditorPalette.mutedText,
                    fontSize: 12,
                  ),
                ),
                children: [
                  Text(
                    'Add your social accounts. They will appear as icons on your public page.',
                    style: TextStyle(
                      color: ProfileEditorPalette.mutedText,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (socialLinks.isEmpty)
                    if (_pendingPlatform == null)
                      const EditorEmptyPanel(
                        title: 'No social accounts yet',
                        subtitle:
                            'Tap a platform below and add only your username.',
                      ),
                  if (socialLinks.isNotEmpty)
                    Column(
                      children: [
                        for (final link in socialLinks) ...[
                          _InlineSocialLinkRow(
                            platform: link.platform,
                            platformLabel: socialPlatformLabel(link.platform),
                            controller: _controllerForLink(link),
                            isSaving: _savingLinkIds.contains(link.id),
                            onSave: () => _saveExistingLink(link),
                            onDelete: () => widget.onDeleteLink(link),
                            onToggle: (value) =>
                                widget.onToggleLink(link, value),
                            isActive: link.isActive,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  if (_pendingPlatform != null) ...[
                    _InlinePendingSocialLinkRow(
                      platform: _pendingPlatform!,
                      platformLabel: socialPlatformLabel(_pendingPlatform!),
                      controller: _pendingUsernameController,
                      isSaving: _isPendingSaveInProgress,
                      onCancel: _isPendingSaveInProgress
                          ? null
                          : () {
                              setState(() {
                                _pendingPlatform = null;
                                _pendingUsernameController.clear();
                              });
                            },
                      onSave: _savePendingLink,
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Add platform',
                    style: TextStyle(
                      color: ProfileEditorPalette.mutedText,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final platform in availablePlatforms)
                        EditorPlatformChip(
                          platform: platform,
                          label: socialPlatformLabel(platform),
                          onTap: () {
                            setState(() {
                              _pendingPlatform = platform;
                              _pendingUsernameController.clear();
                            });
                          },
                        ),
                    ],
                  ),
                  if (availablePlatforms.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'All supported social platforms are already connected.',
                      style: TextStyle(
                        color: ProfileEditorPalette.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        EditorSectionCard(
          title: 'Public Settings',
          child: Column(
            children: [
              EditorSwitchRow(
                title: 'Public Profile',
                subtitle: 'Allow your share page to stay visible',
                value: widget.publicProfileEnabled,
                onChanged: widget.onPublicProfileEnabledChanged,
              ),
              const SizedBox(height: 12),
              EditorSwitchRow(
                title: 'Anonymous Questions',
                subtitle: 'Let visitors send anonymous messages',
                value: widget.allowAnonymousQuestions,
                onChanged: widget.onAllowAnonymousChanged,
              ),
              const SizedBox(height: 12),
              EditorInputBlock(
                label: 'CTA Text',
                controller: widget.ctaController,
                hintText: 'Send me an anonymous message',
              ),
              const SizedBox(height: 12),
              EditorInputBlock(
                label: 'Question Placeholder',
                controller: widget.questionPlaceholderController,
                hintText: 'Ask me anything',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _InlineSocialLinkRow extends StatelessWidget {
  const _InlineSocialLinkRow({
    required this.platform,
    required this.platformLabel,
    required this.controller,
    required this.isSaving,
    required this.onSave,
    required this.onDelete,
    required this.onToggle,
    required this.isActive,
  });

  final String platform;
  final String platformLabel;
  final TextEditingController controller;
  final bool isSaving;
  final Future<void> Function() onSave;
  final Future<void> Function() onDelete;
  final ValueChanged<bool> onToggle;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        final field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                socialPlatformVisual(
                  platform,
                  color: ProfileEditorPalette.mutedText,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  platformLabel,
                  style: TextStyle(
                    color: ProfileEditorPalette.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSave(),
              style: TextStyle(
                fontSize: 14,
                color: ProfileEditorPalette.primaryText,
              ),
              decoration: InputDecoration(
                hintText: 'username',
                isDense: true,
                filled: true,
                fillColor: ProfileEditorPalette.fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ProfileEditorPalette.outlineStrong,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ProfileEditorPalette.outlineStrong,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ProfileEditorPalette.primaryText,
                  ),
                ),
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.check_rounded,
                      color: ProfileEditorPalette.accent,
                      size: 18,
                    ),
            ),
            Switch.adaptive(
              value: isActive,
              activeColor: ProfileEditorPalette.accent,
              onChanged: onToggle,
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ProfileEditorPalette.outlineStrong),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [field, const SizedBox(height: 8), actions],
                )
              : Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: 8),
                    actions,
                  ],
                ),
        );
      },
    );
  }
}

class _InlinePendingSocialLinkRow extends StatelessWidget {
  const _InlinePendingSocialLinkRow({
    required this.platform,
    required this.platformLabel,
    required this.controller,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final String platform;
  final String platformLabel;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback? onCancel;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        final field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                socialPlatformVisual(
                  platform,
                  color: ProfileEditorPalette.mutedText,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  '$platformLabel username',
                  style: TextStyle(
                    color: ProfileEditorPalette.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              style: TextStyle(color: ProfileEditorPalette.primaryText),
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSave(),
              decoration: InputDecoration(
                hintText: 'username',
                isDense: true,
                filled: true,
                fillColor: ProfileEditorPalette.fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ProfileEditorPalette.outlineStrong,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ProfileEditorPalette.outlineStrong,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ProfileEditorPalette.primaryText,
                  ),
                ),
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: [
            IconButton(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : utilityIconVisual(
                      UtilityIconType.send,
                      color: ProfileEditorPalette.accent,
                      size: 18,
                    ),
            ),
            IconButton(
              onPressed: onCancel,
              icon: utilityIconVisual(
                UtilityIconType.exit,
                color: ProfileEditorPalette.placeholder,
                size: 18,
              ),
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ProfileEditorPalette.outlineStrong),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [field, const SizedBox(height: 8), actions],
                )
              : Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: 8),
                    actions,
                  ],
                ),
        );
      },
    );
  }
}
