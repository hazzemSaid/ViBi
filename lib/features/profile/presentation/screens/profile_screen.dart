import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/presentation/providers/profile_providers.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_completion_widget.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_latest_answers_section.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_social_links_section.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;

    final user = context.watch<AuthCubit>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return BlocProvider(
      create: (_) => UserProfileCubit(profileRepository)..load(user.id),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<UserProfileCubit, ViewState<UserProfile?>>(
          builder: (context, profileAsync) {
            if (profileAsync.status == ViewStatus.success) {
              final profile = profileAsync.data;
              if (profile == null) {
                return const Center(child: Text('Profile not found'));
              }

              Future<void> copyShareLink() async {
                final username = profile.username?.trim();
                if (username == null || username.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Set a username first to create a share link.',
                      ),
                    ),
                  );
                  return;
                }

                final baseUrl =
                    dotenv.env['PUBLIC_WEB_BASE_URL']?.trim().isNotEmpty == true
                    ? dotenv.env['PUBLIC_WEB_BASE_URL']!.trim()
                    : 'https://vibi.social';
                final normalizedBase = baseUrl.endsWith('/')
                    ? baseUrl.substring(0, baseUrl.length - 1)
                    : baseUrl;
                final shareUrl = '$normalizedBase/u/$username';

                await Clipboard.setData(ClipboardData(text: shareUrl));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share link copied: $shareUrl')),
                  );
                }
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => context.pushNamed('edit-profile'),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => context.pushNamed('edit-profile'),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.ios_share,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: copyShareLink,
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileHeaderWidget(profile: profile),
                          ProfileCompletionWidget(profile: profile),
                          const SizedBox(height: AppSizes.s24),
                          ProfileStatsCard(
                            followersCount: profile.followers_count.toString(),
                            followingCount: (profile.following_count)
                                .toString(),
                            answersCount: (profile.answers_count).toString(),
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
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r24,
                                  ),
                                ),
                              ),
                              onPressed: copyShareLink,
                              icon: const Icon(Icons.send_outlined, size: 20),
                              label: const Text(
                                'Share Profile Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.s32),
                          ProfileLatestAnswersSection(userId: user.id),
                          const SizedBox(height: AppSizes.s40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            if (profileAsync.status == ViewStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(child: Text('Error: ${profileAsync.errorMessage}'));
          },
        ),
      ),
    );
  }
}
