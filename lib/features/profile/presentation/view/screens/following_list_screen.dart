import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/profile/presentation/viewmodel/profile_cubit/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/viewmodel/profile_cubit/public_profile_state.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Following',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<FollowingCubit, FollowingState>(
          builder: (context, state) {
            if (state is FollowingLoaded) {
              final following = state.following;
              if (following.isEmpty) {
                return Center(
                  child: Text(
                    'Not following anyone yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              style: TextStyle(
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: followingUser.bio != null
                        ? Text(
                            followingUser.bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
                      print('Tapped on ${followingUser.username}');
                      context.pushNamed(
                        'public-profile',
                        pathParameters: {'userId': followingUser.id},
                      );
                    },
                  );
                },
              );
            }
            if (state is FollowingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FollowingFailure) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Unfollow',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Are you sure you want to unfollow this user?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text('Unfollow'),
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
                SnackBar(
                  content: Text('Unfollowed successfully'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            }

            onUnfollowed();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text('Unfollow'),
    );
  }
}
