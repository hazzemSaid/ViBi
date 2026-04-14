import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/social/presentation/providers/follow_providers.dart';

class FollowButton extends StatelessWidget {
  final PublicProfile profile;

  const FollowButton({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final followNotifier = context.watch<FollowCubit>().state;

    Widget buildButton({
      required String text,
      required VoidCallback onPressed,
      required Color backgroundColor,
      required Color foregroundColor,
      bool isLoading = false,
    }) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    }

    final isLoading = followNotifier.isLoading;

    if (profile.hasRequestedFollow) {
      return buildButton(
        text: 'Requested',
        onPressed: () {
          // Could implement cancel request here
        },
        backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        isLoading: false,
      );
    } else if (profile.isFollowing) {
      return buildButton(
        text: 'Following',
        onPressed: () async {
          final shouldUnfollow = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Unfollow?',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: Text(
                'Are you sure you want to unfollow @${profile.username ?? "this user"}?',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Unfollow',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          );

          if (!context.mounted) return;

          if (shouldUnfollow == true) {
            await context.read<FollowCubit>().unfollowUser(profile.id);

            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Unfollowed')));
            }
          }
        },
        backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        isLoading: isLoading,
      );
    } else if (profile.isPrivate) {
      return buildButton(
        text: 'Request to Follow',
        onPressed: () async {
          await context.read<FollowCubit>().requestFollow(profile.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Follow request sent')),
            );
          }
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        isLoading: isLoading,
      );
    } else {
      return buildButton(
        text: 'Follow',
        onPressed: () async {
          await context.read<FollowCubit>().followUser(profile.id);

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Following')));
          }
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        isLoading: isLoading,
      );
    }
  }
}




