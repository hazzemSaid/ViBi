import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';
import 'package:vibi/features/profile/presentation/providers/profile_providers.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile_basic_info_section.dart';
import 'package:vibi/features/profile/presentation/widgets/edit_profile_public_web_section.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_avatar_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _ctaController;
  late final ProfileUpdateCubit _profileUpdateCubit;
  File? _imageFile;
  String? _currentImageUrl;
  bool _isPrivate = false;
  bool _allowAnonymousQuestions = true;
  bool _publicProfileEnabled = true;
  String _publicThemeKey = _publicThemeOptions.first;

  static const List<String> _publicThemeOptions = [
    'tellonym_dark',
    'minimal_dark',
    'clean_light',
  ];

  static const Map<String, String> _publicThemeLabels = {
    'tellonym_dark': 'Tellonym Dark',
    'minimal_dark': 'Minimal Dark',
    'clean_light': 'Clean Light',
  };

  static const Map<String, String> _publicThemeDescriptions = {
    'tellonym_dark': 'Bold gradient card style with colorful social buttons.',
    'minimal_dark':
        'Low-noise dark layout with clean contrast and subtle accents.',
    'clean_light':
        'Bright, airy card style with soft borders and light backgrounds.',
  };

  @override
  void initState() {
    super.initState();
    _profileUpdateCubit = getIt<ProfileUpdateCubit>();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _ctaController = TextEditingController();

    Future.microtask(() {
      if (!mounted) return;
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        getIt<ProfileRepository>().fetchProfile(user.id).then((profile) {
          if (!mounted || profile == null) return;

          setState(() {
            _nameController.text = profile.name ?? '';
            _usernameController.text = profile.username ?? '';
            _bioController.text = profile.bio ?? '';
            _currentImageUrl = profile.profileImageUrl;
            _isPrivate = profile.isPrivate;
            _allowAnonymousQuestions = profile.allowAnonymousQuestions;
            _publicProfileEnabled = profile.publicProfileEnabled;
            _publicThemeKey = profile.publicThemeKey;
            _ctaController.text =
                profile.publicCtaText ?? 'SEND ME AN ANONYMOUS MESSAGE!';
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _ctaController.dispose();
    _profileUpdateCubit.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.background,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
        ],
      );
      if (croppedFile != null) {
        setState(() => _imageFile = File(croppedFile.path));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;

    final repository = getIt<ProfileRepository>();

    String? imageUrl = _currentImageUrl;

    try {
      if (_imageFile != null) {
        imageUrl = await repository.uploadProfileImage(user.id, _imageFile!);
      }

      final profile = UserProfile(
        uid: user.id,
        name: _nameController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        profileImageUrl: imageUrl,
        isPrivate: _isPrivate,
        allowAnonymousQuestions: _allowAnonymousQuestions,
        publicProfileEnabled: _publicProfileEnabled,
        publicThemeKey: _publicThemeKey,
        publicCtaText: _ctaController.text.trim().isEmpty
            ? null
            : _ctaController.text.trim(),
      );

      await _profileUpdateCubit.updateProfile(profile);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileUpdateCubit>.value(
      value: _profileUpdateCubit,
      child: Builder(
        builder: (context) {
          final isLoading = context.watch<ProfileUpdateCubit>().state.isLoading;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                  onPressed: () {
                    final user = context.read<AuthCubit>().currentUser;
                    if (user != null) {
                      getIt<ProfileRepository>().fetchProfile(user.id).then((
                        profile,
                      ) {
                        if (profile != null && mounted) {
                          setState(() {
                            _nameController.text = profile.name ?? '';
                            _usernameController.text = profile.username ?? '';
                            _bioController.text = profile.bio ?? '';
                            _currentImageUrl = profile.profileImageUrl;
                            _imageFile = null;
                            _isPrivate = profile.isPrivate;
                            _allowAnonymousQuestions =
                                profile.allowAnonymousQuestions;
                            _publicProfileEnabled =
                                profile.publicProfileEnabled;
                            _publicThemeKey = profile.publicThemeKey;
                            _ctaController.text =
                                profile.publicCtaText ??
                                'SEND ME AN ANONYMOUS MESSAGE!';
                          });
                        }
                      });
                    }
                  },
                  tooltip: 'Reload profile',
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: _saveProfile,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.s20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ProfileAvatarPicker(
                      imageFile: _imageFile,
                      currentImageUrl: _currentImageUrl,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: AppSizes.s32),
                    EditProfileBasicInfoSection(
                      nameController: _nameController,
                      usernameController: _usernameController,
                      bioController: _bioController,
                      isPrivate: _isPrivate,
                      onPrivateChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.s20),
                    EditProfilePublicWebSection(
                      publicProfileEnabled: _publicProfileEnabled,
                      allowAnonymousQuestions: _allowAnonymousQuestions,
                      ctaController: _ctaController,
                      publicThemeKey: _publicThemeKey,
                      publicThemeOptions: _publicThemeOptions,
                      publicThemeLabels: _publicThemeLabels,
                      publicThemeDescriptions: _publicThemeDescriptions,
                      onPublicProfileEnabledChanged: (value) {
                        setState(() {
                          _publicProfileEnabled = value;
                        });
                      },
                      onAnonymousChanged: (value) {
                        setState(() {
                          _allowAnonymousQuestions = value;
                        });
                      },
                      onThemeChanged: (value) {
                        setState(() {
                          _publicThemeKey = value;
                        });
                      },
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
