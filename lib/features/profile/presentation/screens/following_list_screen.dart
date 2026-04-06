import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/following_user.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/social/presentation/providers/follow_providers.dart';

class FollowingListScreen extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const FollowingListScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  late final FollowingCubit _followingCubit;
  late final FollowCubit _followCubit;

  @override
  void initState() {
    super.initState();
    _followingCubit = getIt<FollowingCubit>()..load(widget.userId);
    _followCubit = getIt<FollowCubit>();
  }

  @override
  void dispose() {
    _followingCubit.close();
    _followCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FollowingCubit>.value(value: _followingCubit),
        BlocProvider<FollowCubit>.value(value: _followCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Following',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<FollowingCubit, ViewState<List<FollowingUser>>>(
          builder: (context, followingAsync) {
            if (followingAsync.status == ViewStatus.success) {
              final following = followingAsync.data ?? [];
              if (following.isEmpty) {
                return const Center(
                  child: Text(
                    'Not following anyone yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: following.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final followingUser = following[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: followingUser.avatarUrl != null
                          ? NetworkImage(followingUser.avatarUrl!)
                          : null,
                      child: followingUser.avatarUrl == null
                          ? Text(
                              followingUser.username
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      followingUser.fullName ??
                          followingUser.username ??
                          'Unknown',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: followingUser.bio != null
                        ? Text(
                            followingUser.bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          )
                        : null,
                    trailing: widget.isCurrentUser
                        ? _UnfollowButton(
                            followingUserId: followingUser.id,
                            currentUserId: widget.userId,
                            onUnfollowed: () {
                              _followingCubit.load(widget.userId);
                            },
                          )
                        : null,
                    onTap: () {
                      context.pushNamed(
                        'public-profile',
                        pathParameters: {'userId': followingUser.id},
                      );
                    },
                  );
                },
              );
            }
            if (followingAsync.status == ViewStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Text(
                'Error: ${followingAsync.errorMessage}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UnfollowButton extends StatelessWidget {
  final String followingUserId;
  final String currentUserId;
  final VoidCallback onUnfollowed;

  const _UnfollowButton({
    required this.followingUserId,
    required this.currentUserId,
    required this.onUnfollowed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Unfollow',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'Are you sure you want to unfollow this user?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Unfollow'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          try {
            final followCubit = context.read<FollowCubit>();
            await followCubit.unfollowUser(followingUserId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unfollowed successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }

            onUnfollowed();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text('Unfollow'),
    );
  }
}
