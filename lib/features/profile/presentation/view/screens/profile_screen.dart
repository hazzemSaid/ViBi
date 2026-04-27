import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/profile/presentation/view/widgets/answers/profile_latest_answers_section.dart';
import 'package:vibi/features/profile/presentation/view/widgets/common/profile_completion_widget.dart';
import 'package:vibi/features/profile/presentation/view/widgets/profile/profile_header_widget.dart';
import 'package:vibi/features/profile/presentation/view/widgets/profile/profile_stats_card.dart';
import 'package:vibi/features/profile/presentation/view/widgets/social/profile_social_links_section.dart';
import 'package:vibi/features/profile/presentation/viewmodel/profile_cubit/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/viewmodel/profile_cubit/profile_cubit_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _profileCubit;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  void _loadProfileIfNeeded(String userId) {
    if (_loadedUserId == userId) return;
    _loadedUserId = userId;
    _profileCubit.load(userId);
  }

  Future<void> _reloadProfile(String userId) async {
    await _profileCubit.load(userId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = size.width * 0.05;

    final user = context.watch<AuthCubit>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    _loadProfileIfNeeded(user.id);

    return BlocProvider<ProfileCubit>.value(
      value: _profileCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final profile = switch (profileState) {
              ProfileLoaded loaded => loaded.profile,
              ProfileSaving saving => saving.profile,
              ProfileFailure failure when failure.profile != null =>
                failure.profile!,
              _ => null,
            };

            if (profile != null) {
              Future<void> copyShareLink() async {
                final username = profile.username.trim();
                if (username.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Set a username first to create a share link.',
                      ),
                    ),
                  );
                  return;
                }

                final shareBaseUrl =
                    dotenv.env['SHARE_BASE_URL'] ?? 'https://vibi.social';
                final shareUrl = '$shareBaseUrl/u/$username';

                await Clipboard.setData(ClipboardData(text: shareUrl));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share link copied: $shareUrl')),
                  );
                }
              }

              return RefreshIndicator(
                onRefresh: () => _reloadProfile(user.id),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      leading: IconButton(
                        icon: ImageIcon(
                          AssetImage(AppAssets.iconSettings),
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.06),
                          shape: const CircleBorder(),
                        ),
                        onPressed: () => context.pushNamed('edit-profile'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileHeaderWidget(profile: profile),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            child: Column(
                              children: [
                                ProfileCompletionWidget(profile: profile),
                                const SizedBox(height: AppSizes.s24),
                                ProfileStatsCard(
                                  followersCount: profile.followers_count
                                      .toString(),
                                  followingCount: (profile.following_count)
                                      .toString(),
                                  answersCount: (profile.answers_count)
                                      .toString(),
                                  userId: user.id,
                                  isCurrentUser: true,
                                ),
                                const SizedBox(height: AppSizes.s24),
                                ProfileSocialLinksSection(userId: user.id),
                                const SizedBox(height: AppSizes.s24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: copyShareLink,
                                    icon: ImageIcon(
                                      AssetImage(AppAssets.iconShare),
                                      size: 20,
                                    ),
                                    label: Text(
                                      'Share Profile Link',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.s32),
                                ProfileLatestAnswersSection(
                                  userId: user.id,
                                  compactActions: true,
                                ),
                                const SizedBox(height: AppSizes.s40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            final errorMessage = profileState is ProfileFailure
                ? profileState.message
                : 'Unknown profile error';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $errorMessage'),
                  const SizedBox(height: AppSizes.s16),
                  ElevatedButton(
                    onPressed: () => _reloadProfile(user.id),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
