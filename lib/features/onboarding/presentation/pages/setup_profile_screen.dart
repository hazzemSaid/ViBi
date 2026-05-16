import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_constants.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/cubit/profile_state.dart';
import 'package:vibi/features/profile/presentation/cubit/social_links_cubit.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late final ProfileCubit _profileCubit;
  SocialLinksCubit? _socialLinksCubit;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _ctaController = TextEditingController();
  final _placeholderController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedColor;
  bool _allowAnonymousQuestions = true;
  bool _showSocialIcons = true;
  String? _usernameError;

  static const List<String> _colors = [
    '#EF476F',
    '#FFD166',
    '#06D6A0',
    '#118AB2',
    '#073B4C',
    '#E63946',
    '#A8DADC',
    '#457B9D',
    '#1D3557',
    '#9B5DE5',
    '#F15BB5',
    '#FEE440',
    '#00BBF9',
    '#00F5D4',
    '#7209B7',
  ];

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null && !user.isAnonymous) {
      _nameController.text = user.displayName ?? '';
      _profileCubit.load(user.id);
      _socialLinksCubit = getIt<SocialLinksCubit>(param1: user.id);
    }
    _usernameController.addListener(() {
      if (_usernameError != null) {
        setState(() => _usernameError = null);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _ctaController.dispose();
    _placeholderController.dispose();
    _profileCubit.close();
    _socialLinksCubit?.close();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  Future<void> _saveIdentityAndNext(UserProfile profile) async {
    if (!_formKey.currentState!.validate()) return;
    final updated = profile.copyWith(
      username: _usernameController.text.trim(),
      name: _nameController.text.trim(),
    );
    final ok = await _profileCubit.updateProfile(updated);
    if (ok && mounted) _animateToPage(1);
  }

  Future<void> _saveAppearanceAndNext(UserProfile profile) async {
    final updated = profile.copyWith(
      favColor: _selectedColor,
    );
    final ok = await _profileCubit.updateProfile(updated);
    if (ok && mounted) _animateToPage(2);
  }

  Future<void> _finishSetup(UserProfile profile) async {
    // 1. Save Public Settings first
    final updated = profile.copyWith(
      allowAnonymousQuestions: _allowAnonymousQuestions,
      showSocialIcons: _showSocialIcons,
      publicCtaText: _ctaController.text.trim(),
      questionPlaceholder: _placeholderController.text.trim(),
    );
    await _profileCubit.updateProfile(updated);

    // 2. Save Social Links
    final links = <(String, String)>[
      ('instagram', _instagramController.text.trim()),
      ('twitter', _twitterController.text.trim()),
    ].where((e) => e.$2.isNotEmpty).toList();

    for (final link in links) {
      try {
        await _socialLinksCubit?.addLink(
          platform: link.$1,
          url: link.$2,
          title: null,
          displayLabel: null,
          displayOrder: 0,
        );
      } catch (_) {}
    }

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileCubit),
        if (_socialLinksCubit != null)
          BlocProvider.value(value: _socialLinksCubit!),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileFailure) {
                // Handle duplicate username specifically
                if (state.message.contains('profiles_username_key')) {
                  setState(
                    () => _usernameError = 'This username is already taken',
                  );
                  return;
                }

                // Ignore "not found" errors here, as we use a fallback profile
                if (state.message.toLowerCase().contains('not found')) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = _extractProfile(state);
              if (profile == null) {
                return const Center(
                  child: Text('Could not load profile. Please restart.'),
                );
              }

              final isSaving = state is ProfileSaving;

              return Column(
                children: [
                  _StepIndicator(currentPage: _currentPage, total: 3),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _IdentityStep(
                          usernameController: _usernameController,
                          nameController: _nameController,
                          formKey: _formKey,
                          isSaving: isSaving,
                          errorText: _usernameError,
                          onContinue: () => _saveIdentityAndNext(profile),
                        ),
                        _AppearanceStep(
                          selectedColor: _selectedColor,
                          colors: _colors,
                          isSaving: isSaving,
                          onColorSelected: (c) =>
                              setState(() => _selectedColor = c),
                          onContinue: () => _saveAppearanceAndNext(profile),
                        ),
                        _SettingsStep(
                          instagramController: _instagramController,
                          twitterController: _twitterController,
                          ctaController: _ctaController,
                          placeholderController: _placeholderController,
                          allowAnonymous: _allowAnonymousQuestions,
                          showSocialIcons: _showSocialIcons,
                          onAllowAnonymousChanged: (v) =>
                              setState(() => _allowAnonymousQuestions = v),
                          onShowSocialIconsChanged: (v) =>
                              setState(() => _showSocialIcons = v),
                          onFinish: () => _finishSetup(profile),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        if (_currentPage > 0)
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  UserProfile? _extractProfile(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileSaving) return state.profile;
    if (state is ProfileFailure) {
      if (state.profile != null) return state.profile;

      // Fallback for missing profiles (new Google user before trigger finishes)
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        return UserProfile(
          uid: user.id,
          name: user.displayName ?? '',
          username: '',
          avatarUrls: user.avatarUrl != null ? [user.avatarUrl!] : [],
          followers_count: 0,
          following_count: 0,
          answers_count: 0,
        );
      }
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentPage, required this.total});
  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        children: List.generate(total, (i) {
          final active = i == currentPage;
          final done = i < currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: done || active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1: Username
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Step 1: Identity
// ─────────────────────────────────────────────────────────────────────────────
class _IdentityStep extends StatelessWidget {
  const _IdentityStep({
    required this.usernameController,
    required this.nameController,
    required this.formKey,
    required this.isSaving,
    required this.onContinue,
    this.errorText,
  });

  final TextEditingController usernameController;
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  final bool isSaving;
  final VoidCallback onContinue;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Tell us about yourself',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'e.g. John Doe',
                    helperText: 'How your name will appear on your profile.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixText: '@',
                    helperText: 'Your unique @handle.',
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty)
                      return 'Username is required';
                    if (val.trim().length < 3) return 'Too short';
                    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(val.trim()))
                      return 'Invalid characters';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: isSaving ? null : onContinue,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: Appearance
// ─────────────────────────────────────────────────────────────────────────────
class _AppearanceStep extends StatelessWidget {
  const _AppearanceStep({
    required this.selectedColor,
    required this.colors,
    required this.isSaving,
    required this.onColorSelected,
    required this.onContinue,
  });

  final String? selectedColor;
  final List<String> colors;
  final bool isSaving;
  final ValueChanged<String> onColorSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Personalize your style',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Accent Color',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The main color theme for your public profile page.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: colors.map((hex) {
              final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
              final isSelected = selectedColor == hex;
              return GestureDetector(
                onTap: () => onColorSelected(hex),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: isSaving ? null : onContinue,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3: Socials & Settings
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsStep extends StatelessWidget {
  const _SettingsStep({
    required this.instagramController,
    required this.twitterController,
    required this.ctaController,
    required this.placeholderController,
    required this.allowAnonymous,
    required this.showSocialIcons,
    required this.onAllowAnonymousChanged,
    required this.onShowSocialIconsChanged,
    required this.onFinish,
  });

  final TextEditingController instagramController;
  final TextEditingController twitterController;
  final TextEditingController ctaController;
  final TextEditingController placeholderController;
  final bool allowAnonymous;
  final bool showSocialIcons;
  final ValueChanged<bool> onAllowAnonymousChanged;
  final ValueChanged<bool> onShowSocialIconsChanged;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.settings_suggest_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Final touches',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Connect Socials',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Icons that will appear on your profile for people to find you.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _SocialField(
            controller: instagramController,
            label: 'Instagram',
            hint: 'username',
            icon: Icons.camera_alt_outlined,
          ),
          const SizedBox(height: 16),
          _SocialField(
            controller: twitterController,
            label: 'X / Twitter',
            hint: 'username',
            icon: Icons.chat_bubble_outline_rounded,
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Anonymous Questions'),
            subtitle: const Text(
              'Allow visitors to send you messages without revealing their identity.',
            ),
            contentPadding: EdgeInsets.zero,
            value: allowAnonymous,
            onChanged: onAllowAnonymousChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: ctaController,
            decoration: const InputDecoration(
              labelText: 'Question Button Text',
              hintText: 'e.g. Ask me anything!',
              helperText: 'The text shown on your question submission button.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: onFinish,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text(
              'Finish Setup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialField extends StatelessWidget {
  const _SocialField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
