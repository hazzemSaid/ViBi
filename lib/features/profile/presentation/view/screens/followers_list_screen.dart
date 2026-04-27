import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/profile/presentation/viewmodel/profile_cubit/profile_cubit.dart';
import 'package:vibi/features/profile/presentation/viewmodel/profile_cubit/public_profile_state.dart';
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
            'Followers',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<FollowersCubit, FollowersState>(
          builder: (context, state) {
            if (state is FollowersLoaded) {
              final followers = state.followers;
              if (followers.isEmpty) {
                return Center(
                  child: Text(
                    'No followers yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      follower.fullName ?? follower.username ?? 'Unknown',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: follower.bio != null
                        ? Text(
                            follower.bio!,
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
            if (state is FollowersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FollowersFailure) {
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Remove Follower',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Are you sure you want to remove this follower?',
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
                child: Text('Remove'),
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
                SnackBar(
                  content: Text('Follower removed'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            }

            onRemoved();
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
      child: Text('Remove'),
    );
  }
}
