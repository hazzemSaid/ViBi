import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/presentation/providers/profile_providers.dart';
import 'package:vibi/features/profile/presentation/widgets/profile_stats_card.dart';
import 'package:vibi/features/profile/presentation/widgets/public_profile_actions_row.dart';
import 'package:vibi/features/profile/presentation/widgets/public_profile_answers_section.dart';
import 'package:vibi/features/profile/presentation/widgets/public_profile_header_widget.dart';
import 'package:vibi/features/profile/presentation/widgets/public_profile_private_content.dart';
import 'package:vibi/features/profile/presentation/widgets/public_profile_social_links_section.dart';

class PublicProfileScreen extends StatelessWidget {
  final String lookupValue;
  final bool isUsernameLookup;

  const PublicProfileScreen({super.key, required String userId})
    : lookupValue = userId,
      isUsernameLookup = false;

  const PublicProfileScreen.byUsername({super.key, required String username})
    : lookupValue = username,
      isUsernameLookup = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = PublicProfileCubit(publicProfileRepository);
        _loadProfile(cubit);
        return cubit;
      },
      child: _PublicProfileBody(
        lookupValue: lookupValue,
        isUsernameLookup: isUsernameLookup,
      ),
    );
  }

  void _loadProfile(PublicProfileCubit cubit) {
    if (isUsernameLookup) {
      cubit.loadByUsername(lookupValue);
    } else {
      cubit.loadById(lookupValue);
    }
  }
}

class _PublicProfileBody extends StatelessWidget {
  const _PublicProfileBody({
    required this.lookupValue,
    required this.isUsernameLookup,
  });

  final String lookupValue;
  final bool isUsernameLookup;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PublicProfileCubit, ViewState<PublicProfile?>>(
        builder: (context, profileAsync) {
          if (profileAsync.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileAsync.status == ViewStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${profileAsync.errorMessage}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: AppSizes.s16),
                  ElevatedButton(
                    onPressed: () => _reloadProfile(context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = profileAsync.data;
          if (profile == null) {
            return const Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadProfile(context),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => _reloadProfile(context),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PublicProfileHeaderWidget(profile: profile),
                        const SizedBox(height: AppSizes.s24),
                        ProfileStatsCard(
                          followersCount: '${profile.followersCount}',
                          followingCount: '${profile.followingCount}',
                          answersCount: '${profile.answersCount}',
                          userId: profile.id,
                          isCurrentUser: false,
                        ),
                        const SizedBox(height: AppSizes.s24),
                        PublicProfileActionsRow(profile: profile),
                        const SizedBox(height: AppSizes.s32),
                        PublicProfileSocialLinksSection(userId: profile.id),
                        const SizedBox(height: AppSizes.s32),
                        if (!profile.canViewContent)
                          PublicProfilePrivateContent(
                            isFollowing: profile.isFollowing,
                          )
                        else
                          BlocProvider(
                            create: (_) =>
                                UserAnswersCubit(publicProfileRepository)
                                  ..load(profile.id),
                            child:
                                BlocBuilder<
                                  UserAnswersCubit,
                                  ViewState<List<AnsweredQuestion>>
                                >(
                                  builder: (context, answersAsync) {
                                    return PublicProfileAnswersSection(
                                      answersAsync: answersAsync,
                                    );
                                  },
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _reloadProfile(BuildContext context) {
    final cubit = context.read<PublicProfileCubit>();
    if (isUsernameLookup) {
      cubit.loadByUsername(lookupValue);
    } else {
      cubit.loadById(lookupValue);
    }
  }
}
