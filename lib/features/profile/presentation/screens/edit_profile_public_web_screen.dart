import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/profile/presentation/mixins/edit_profile_controller_mixin.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit_state.dart';
import 'package:vibi/features/profile/presentation/view/social_media_view/social_links_cubit.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile/edit_profile_widgets.dart';

class EditProfilePublicWebScreen extends StatefulWidget {
  const EditProfilePublicWebScreen({super.key});

  @override
  State<EditProfilePublicWebScreen> createState() =>
      _EditProfilePublicWebScreenState();
}

class _EditProfilePublicWebScreenState extends State<EditProfilePublicWebScreen>
    with EditProfileControllerMixin {
  @override
  void initState() {
    super.initState();
    initController();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  Future<UnsavedExitAction?> _showUnsavedChangesDialog() {
    return showDialog<UnsavedExitAction>(
      context: context,
      builder: (dialogContext) => const UnsavedChangesDialog(),
    );
  }

  Future<bool> _handlePopAttempt() async {
    if (profileCubit.state is ProfileSaving) return false;
    if (!hasUnsavedChanges()) return true;

    final action = await _showUnsavedChangesDialog();
    if (action == null || action == UnsavedExitAction.stay) {
      return false;
    }
    if (action == UnsavedExitAction.discard) {
      return true;
    }

    return saveProfile();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        if (socialLinksCubit != null)
          BlocProvider<SocialLinksCubit>.value(value: socialLinksCubit!),
      ],
      child: Builder(
        builder: (context) {
          final isSaving = context.watch<ProfileCubit>().state is ProfileSaving;
          return PopScope(
            canPop: allowRoutePop || !hasUnsavedChanges(),
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final shouldExit = await _handlePopAttempt();
              if (!mounted || !shouldExit) return;
              setState(() => allowRoutePop = true);
              Navigator.of(this.context).pop();
            },
            child: Scaffold(
              backgroundColor: ProfileEditorPalette.canvas,
              body: SafeArea(
                child: Column(
                  children: [
                    EditProfileTopBar(
                      isSaving: isSaving,
                      onSave: saveProfile,
                      onPublish: () {},
                    ),
                    EditProfileTabBar(
                      activeTab: activeTab,
                      onTabChanged: (tab) => setState(() => activeTab = tab),
                    ),
                    Expanded(
                      child: isBootstrapping
                          ? const Center(child: CircularProgressIndicator())
                          : loadedProfile == null
                          ? const Center(
                              child: Text('Unable to load the profile editor.'),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                32,
                              ),
                              child: Form(
                                key: formKey,
                                child: activeTab == EditorTab.links
                                    ? ProfileEditorLinksTab(
                                        avatarUrls: avatarUrls,
                                        avatarFiles: avatarFiles,
                                        avatarLoadingSlot: avatarLoadingSlot,
                                        onPickAvatar: pickAvatar,
                                        onRemoveAvatar: removeAvatar,
                                        nameController: nameController,
                                        usernameController: usernameController,
                                        usernameErrorText: usernameErrorText,
                                        onUsernameChanged: onUsernameChanged,
                                        bioController: bioController,
                                        statusController: statusController,
                                        ctaController: ctaController,
                                        questionPlaceholderController:
                                            questionPlaceholderController,
                                        showSocialIcons: showSocialIcons,
                                        allowAnonymousQuestions:
                                            allowAnonymousQuestions,
                                        publicProfileEnabled:
                                            publicProfileEnabled,
                                        onShowSocialIconsChanged: (v) =>
                                            setState(() => showSocialIcons = v),
                                        onAllowAnonymousChanged: (v) =>
                                            setState(
                                              () => allowAnonymousQuestions = v,
                                            ),
                                        onPublicProfileEnabledChanged: (v) =>
                                            setState(
                                              () => publicProfileEnabled = v,
                                            ),
                                        socialLinksCubit: socialLinksCubit,
                                        onDeleteLink: deleteLink,
                                        onToggleLink: toggleLink,
                                        onSaveSocialLink: saveSocialLinkInline,
                                        onReorderLinks: reorderLinks,
                                        socialAccountLinksFor:
                                            socialAccountLinks,
                                        customLinksFor: customLinks,
                                      )
                                    : ProfileEditorAppearanceTab(
                                        favColor: favColor,
                                        publicFontFamily: publicFontFamily,
                                        parseHexColor: parseHexColor,
                                        fontFamilyFor: fontFamilyFor,
                                        onFavColorChanged: (v) =>
                                            setState(() => favColor = v),
                                        onFontFamilyChanged: (v) => setState(
                                          () => publicFontFamily = v,
                                        ),
                                        backgroundColor: '',
                                        onBackgroundColorChanged:
                                            (String value) {},
                                      ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
