import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/presentation/screens/edit_profile_public_web_screen.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit_state.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_links_cubit.dart';
import 'package:vibi/features/profile/presentation/widgets/common/social_link_platform.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

mixin EditProfileControllerMixin on State<EditProfilePublicWebScreen> {
  final formKey = GlobalKey<FormState>();
  late final ProfileCubit profileCubit;
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final statusController = TextEditingController();
  final ctaController = TextEditingController();
  final questionPlaceholderController = TextEditingController();

  SocialLinksCubit? socialLinksCubit;
  UserProfile? loadedProfile;
  String? userId;
  final List<String?> avatarUrls = List<String?>.filled(3, null);
  final List<File?> avatarFiles = List<File?>.filled(3, null);
  bool isBootstrapping = true;
  bool publicProfileEnabled = true;
  bool allowAnonymousQuestions = true;
  bool showSocialIcons = true;
  // String backgroundColor = ProfileConstants.backgroundColorOptions.first;
  String favColor = ProfileConstants.favColorOptions.first;
  String publicFontFamily = 'inter';
  int? avatarLoadingSlot;
  bool allowRoutePop = false;
  EditorTab activeTab = EditorTab.links;
  String? usernameErrorText;

  void initController() {
    profileCubit = getIt<ProfileCubit>();
    userId = context.read<AuthCubit>().currentUser?.id;
    if (userId != null) {
      socialLinksCubit = getIt<SocialLinksCubit>(param1: userId!);
    }
    loadProfile();
  }

  void disposeController() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    statusController.dispose();
    ctaController.dispose();
    questionPlaceholderController.dispose();
    socialLinksCubit?.close();
    profileCubit.close();
  }

  Future<void> loadProfile() async {
    if (userId == null) {
      if (mounted) setState(() => isBootstrapping = false);
      return;
    }

    try {
      final profile = await profileCubit.load(userId!);
      if (!mounted) return;
      setState(() {
        loadedProfile = profile;
        nameController.text = profile?.name ?? '';
        usernameController.text = profile?.username ?? '';
        bioController.text = profile?.bio ?? '';
        statusController.text = profile?.statusText ?? '';
        ctaController.text = profile?.publicCtaText ?? '';
        questionPlaceholderController.text = profile?.questionPlaceholder ?? '';
        for (var index = 0; index < 3; index++) {
          avatarUrls[index] =
              profile != null && index < profile.avatarUrls.length
              ? profile.avatarUrls[index]
              : null;
          avatarFiles[index] = null;
        }
        avatarLoadingSlot = null;
        showSocialIcons = profile?.showSocialIcons ?? true;
        allowAnonymousQuestions = profile?.allowAnonymousQuestions ?? true;
        publicProfileEnabled = profile?.publicProfileEnabled ?? true;
        // backgroundColor = profile?.backgroundcolor?.isNotEmpty == true
        //     ? profile!.backgroundcolor!
        //     : ProfileConstants.backgroundColorOptions.first;

        publicFontFamily = ProfileConstants.normalizeFontFamily(
          profile?.publicFontFamily,
        );
        favColor = (profile?.favColor?.isNotEmpty ?? false)
            ? profile!.favColor!
            : ProfileConstants.favColorOptions.first;
        isBootstrapping = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isBootstrapping = false);
      showSnackBar('Failed to load profile: $error');
    }
  }

  Future<void> pickAvatar(int slotIndex) async {
    if (slotIndex < 0 || slotIndex > 2) return;
    if (avatarLoadingSlot != null) return;
    setState(() => avatarLoadingSlot = slotIndex);

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: ProfileEditorPalette.canvas,
            toolbarWidgetColor: Theme.of(context).colorScheme.onSurface,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Photo', aspectRatioLockEnabled: true),
        ],
      );
      if (cropped == null || !mounted) return;
      setState(() => avatarFiles[slotIndex] = File(cropped.path));
    } finally {
      if (mounted) setState(() => avatarLoadingSlot = null);
    }
  }

  void removeAvatar(int slotIndex) {
    if (slotIndex < 0 || slotIndex > 2) return;
    if (avatarLoadingSlot != null) return;

    setState(() {
      avatarFiles[slotIndex] = null;
      avatarUrls[slotIndex] = null;
      _normalizeAvatarSlots();
    });
  }

  void _normalizeAvatarSlots() {
    final entries = <({String? url, File? file})>[];

    for (var index = 0; index < 3; index++) {
      final file = avatarFiles[index];
      final url = avatarUrls[index];
      if (file != null || (url != null && url.trim().isNotEmpty)) {
        entries.add((url: file != null ? null : url, file: file));
      }
    }

    for (var index = 0; index < 3; index++) {
      if (index < entries.length) {
        avatarUrls[index] = entries[index].url;
        avatarFiles[index] = entries[index].file;
      } else {
        avatarUrls[index] = null;
        avatarFiles[index] = null;
      }
    }
  }

  Future<bool> saveProfile() async {
    if (!formKey.currentState!.validate()) return false;
    if (loadedProfile == null || userId == null) return false;

    if (usernameErrorText != null && mounted) {
      setState(() => usernameErrorText = null);
    }

    try {
      final mergedAvatarUrls = List<String?>.from(avatarUrls);

      for (var slot = 0; slot < 3; slot++) {
        final pendingFile = avatarFiles[slot];
        if (pendingFile != null) {
          final uploadedUrl = await profileCubit.uploadPublicProfileImage(
            userId!,
            pendingFile,
            slot + 1,
          );
          mergedAvatarUrls[slot] = uploadedUrl;
        }
      }

      final compactAvatarUrls = mergedAvatarUrls
          .where((url) => url != null && url.trim().isNotEmpty)
          .cast<String>()
          .take(3)
          .toList();

      final updated = loadedProfile!.copyWith(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        bio: _trimToNull(bioController.text),
        avatarUrls: compactAvatarUrls,
        allowAnonymousQuestions: allowAnonymousQuestions,
        publicProfileEnabled: publicProfileEnabled,
        publicCtaText: _trimToNull(ctaController.text),
        favColor: favColor,
        questionPlaceholder: _trimToNull(questionPlaceholderController.text),
        showSocialIcons: showSocialIcons,
        statusText: _trimToNull(statusController.text),
        publicFontFamily: publicFontFamily,
      );

      final success = await profileCubit.updateProfile(updated);

      if (!mounted) return false;
      if (!success) {
        final state = profileCubit.state;
        final errorMessage = state is ProfileFailure
            ? state.message
            : 'Could not save profile.';

        final usernameConflictMessage = _mapUsernameConflictMessage(
          errorMessage,
        );
        if (usernameConflictMessage != null) {
          setState(() => usernameErrorText = usernameConflictMessage);
          return false;
        }

        showSnackBar(errorMessage);
        return false;
      }
      setState(() {
        usernameErrorText = null;
        loadedProfile = updated;
        for (var index = 0; index < 3; index++) {
          avatarUrls[index] = index < compactAvatarUrls.length
              ? compactAvatarUrls[index]
              : null;
          avatarFiles[index] = null;
        }
      });
      showSnackBar('Profile changes saved.');
      return true;
    } catch (e) {
      if (!mounted) return false;

      final usernameConflictMessage = _mapUsernameConflictMessage(e.toString());
      if (usernameConflictMessage != null) {
        setState(() => usernameErrorText = usernameConflictMessage);
        return false;
      }

      showSnackBar('Failed to save profile: $e');
      return false;
    }
  }

  void onUsernameChanged(String _) {
    if (usernameErrorText == null || !mounted) return;
    setState(() => usernameErrorText = null);
  }

  String _normalizedValue(String? value) => value?.trim() ?? '';

  bool hasUnsavedChanges() {
    final profile = loadedProfile;
    if (profile == null) return false;

    final savedFavColor = (profile.favColor?.isNotEmpty ?? false)
        ? profile.favColor!
        : ProfileConstants.favColorOptions.first;

    if (avatarFiles.any((file) => file != null)) return true;

    final savedAvatarUrls = List<String?>.filled(3, null);
    for (var index = 0; index < 3; index++) {
      savedAvatarUrls[index] = index < profile.avatarUrls.length
          ? profile.avatarUrls[index]
          : null;
      if (_normalizedValue(avatarUrls[index]) !=
          _normalizedValue(savedAvatarUrls[index])) {
        return true;
      }
    }

    if (nameController.text.trim() != _normalizedValue(profile.name)) {
      return true;
    }
    if (usernameController.text.trim() != _normalizedValue(profile.username)) {
      return true;
    }
    if (bioController.text.trim() != _normalizedValue(profile.bio)) {
      return true;
    }
    if (statusController.text.trim() != _normalizedValue(profile.statusText)) {
      return true;
    }
    if (ctaController.text.trim() != _normalizedValue(profile.publicCtaText)) {
      return true;
    }
    if (questionPlaceholderController.text.trim() !=
        _normalizedValue(profile.questionPlaceholder)) {
      return true;
    }
    if (showSocialIcons != profile.showSocialIcons) return true;
    if (allowAnonymousQuestions != profile.allowAnonymousQuestions) {
      return true;
    }
    if (publicProfileEnabled != profile.publicProfileEnabled) {
      return true;
    }
    if (publicFontFamily !=
        ProfileConstants.normalizeFontFamily(profile.publicFontFamily)) {
      return true;
    }
    if (favColor != savedFavColor) return true;

    return false;
  }

  Future<void> toggleLink(SocialLink link, bool value) async {
    try {
      if (socialLinksCubit == null) {
        showSnackBar('Social links are not ready yet.');
        return;
      }
      await socialLinksCubit!.toggleLink(link, value);
    } catch (error) {
      if (!mounted) return;
      showSnackBar('Failed to update link: $error');
    }
  }

  Future<void> deleteLink(SocialLink link) async {
    try {
      await socialLinksCubit?.deleteLink(link.id);
      if (!mounted) return;
      showSnackBar('Link removed.');
    } catch (error) {
      if (!mounted) return;
      showSnackBar('Failed to delete link: $error');
    }
  }

  Future<void> reorderLinks(
    List<SocialLink> links,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      if (socialLinksCubit == null) {
        showSnackBar('Social links are not ready yet.');
        return;
      }
      await socialLinksCubit!.reorderLinks(links, oldIndex, newIndex);
    } catch (error) {
      if (!mounted) return;
      showSnackBar('Failed to reorder links: $error');
    }
  }

  Future<void> saveSocialLinkInline({
    required String platform,
    required String username,
    SocialLink? existingLink,
  }) async {
    if (userId == null) return;

    final normalizedUsername = normalizeSocialUsername(username);
    if (normalizedUsername.isEmpty) {
      showSnackBar('Username is required.');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(normalizedUsername)) {
      showSnackBar('Use letters, numbers, ., _, or - only.');
      return;
    }

    final links = socialLinksCubit?.currentLinks ?? const <SocialLink>[];
    final matchedLink = links.cast<SocialLink?>().firstWhere(
      (link) => link?.platform == platform,
      orElse: () => null,
    );
    final targetLink = existingLink ?? matchedLink;
    final normalizedUrl = buildSocialUrl(platform, normalizedUsername);

    try {
      if (socialLinksCubit == null) {
        showSnackBar('Social links are not ready yet.');
        return;
      }

      if (targetLink == null) {
        await socialLinksCubit!.addLink(
          platform: platform,
          url: normalizedUrl,
          title: null,
          displayLabel: socialPlatformDefaultDisplayLabel(platform),
          displayOrder: _getNextOrder(links),
        );
      } else {
        await socialLinksCubit!.updateLink(
          linkId: targetLink.id,
          platform: platform,
          url: normalizedUrl,
          title: targetLink.title,
          displayLabel:
              targetLink.displayLabel ??
              socialPlatformDefaultDisplayLabel(platform),
          displayOrder: targetLink.displayOrder,
          isActive: targetLink.isActive,
        );
      }

      if (!mounted) return;
      showSnackBar(
        targetLink == null ? 'Social link added.' : 'Social link updated.',
      );
    } catch (error) {
      if (!mounted) return;
      showSnackBar('Failed to save social link: $error');
    }
  }

  int _getNextOrder(List<SocialLink> links) {
    if (links.isEmpty) return 0;
    return links.fold<int>(
          0,
          (max, link) => link.displayOrder > max ? link.displayOrder : max,
        ) +
        1;
  }

  List<SocialLink> socialAccountLinks(List<SocialLink> links) =>
      links
          .where(
            (link) =>
                link.platform != 'custom' &&
                link.platform != 'website' &&
                link.platform != 'email',
          )
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  List<SocialLink> customLinks(List<SocialLink> links) =>
      links
          .where(
            (link) =>
                link.platform == 'custom' ||
                link.platform == 'website' ||
                link.platform == 'email',
          )
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _mapUsernameConflictMessage(String rawMessage) {
    final message = rawMessage.toLowerCase();

    final hasDuplicateSignal =
        message.contains('duplicate key value') ||
        message.contains('unique constraint') ||
        message.contains('already exists') ||
        message.contains('already taken') ||
        message.contains('23505');

    final hasUsernameSignal =
        message.contains('username') ||
        message.contains('profiles_username_key');

    final genericDuplicate = message.contains('this record already exists');
    final usernameChanged =
        loadedProfile != null &&
        usernameController.text.trim() !=
            _normalizedValue(loadedProfile?.username);

    if ((hasDuplicateSignal && hasUsernameSignal) ||
        (genericDuplicate && usernameChanged)) {
      return 'This username is already taken. Please choose another one.';
    }

    return null;
  }

  String? fontFamilyFor(String key) {
    switch (key) {
      case 'google_sans':
        return 'GoogleSans';
      case 'inter':
        return 'Inter';
      case 'serif':
        return 'serif';
      case 'mono':
        return 'monospace';
      default:
        return 'Inter';
    }
  }

  Color parseHexColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    final buffer = StringBuffer();
    if (clean.length == 6) buffer.write('ff');
    buffer.write(clean);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
