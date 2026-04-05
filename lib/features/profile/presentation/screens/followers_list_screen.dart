import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/follower_user.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/social/domain/repositories/follow_repository.dart';

class FollowersListScreen extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const FollowersListScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  late final FollowersCubit _followersCubit;

  @override
  void initState() {
    super.initState();
    _followersCubit = getIt<FollowersCubit>()..load(widget.userId);
  }

  @override
  void dispose() {
    _followersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FollowersCubit>.value(
      value: _followersCubit,
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
            'Followers',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<FollowersCubit, ViewState<List<FollowerUser>>>(
          builder: (context, followersAsync) {
            if (followersAsync.status == ViewStatus.success) {
              final followers = followersAsync.data ?? [];
              if (followers.isEmpty) {
                return const Center(
                  child: Text(
                    'No followers yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: followers.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final follower = followers[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: follower.avatarUrl != null
                          ? NetworkImage(follower.avatarUrl!)
                          : null,
                      child: follower.avatarUrl == null
                          ? Text(
                              follower.username
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
                      follower.fullName ?? follower.username ?? 'Unknown',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: follower.bio != null
                        ? Text(
                            follower.bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          )
                        : null,
                    trailing: widget.isCurrentUser
                        ? _RemoveButton(
                            followerId: follower.id,
                            currentUserId: widget.userId,
                            onRemoved: () {
                              _followersCubit.load(widget.userId);
                            },
                          )
                        : null,
                    onTap: () {
                      context.pushNamed(
                        'public-profile',
                        pathParameters: {'userId': follower.id},
                      );
                    },
                  );
                },
              );
            }
            if (followersAsync.status == ViewStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Text(
                'Error: ${followersAsync.errorMessage}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final String followerId;
  final String currentUserId;
  final VoidCallback onRemoved;

  const _RemoveButton({
    required this.followerId,
    required this.currentUserId,
    required this.onRemoved,
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
              'Remove Follower',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'Are you sure you want to remove this follower?',
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
                child: const Text('Remove'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          try {
            final repository = getIt<FollowRepository>();
            await repository.removeFollower(currentUserId, followerId);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Follower removed'),
                  backgroundColor: AppColors.success,
                ),
              );
            }

            onRemoved();
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
      child: const Text('Remove'),
    );
  }
}
