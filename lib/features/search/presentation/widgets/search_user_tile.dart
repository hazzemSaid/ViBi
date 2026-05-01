import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';

class SearchUserTile extends StatelessWidget {
  final UserSearchResult user;

  const SearchUserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthCubit>().currentUser;
    final isCurrentUser = currentUser?.id == user.id;

    return ListTile(
      onTap: () {
        if (isCurrentUser) {
          // Navigate to own profile
          context.go('/profile');
        } else {
          // Navigate to username slug route when possible for share-friendly URLs.
          final username = user.username?.trim();
          if (username != null && username.isNotEmpty) {
            context.pushNamed(
              'public-profile-username',
              pathParameters: {'username': username},
            );
          } else {
            context.pushNamed(
              'public-profile',
              pathParameters: {'userId': user.id},
            );
          }
        }
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.s16,
        vertical: AppSizes.s8,
      ),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
        backgroundImage: user.avatarUrls.isNotEmpty
            ? ResizeImage(
                CachedNetworkImageProvider(user.avatarUrls.first),
                width: 168,
                height: 168,
              )
            : null,
        child: user.avatarUrls.isEmpty
            ? Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.name ?? 'No name',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isPrivate) ...[
            SizedBox(width: AppSizes.s4),
            Icon(
              Icons.lock_outline,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.username != null) ...[
            Text(
              '@${user.username}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
          ],
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${user.followersCount}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'followers',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
