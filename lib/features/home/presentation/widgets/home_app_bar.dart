import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      floating: true,
      title: Row(
        children: [
          Text(
            'ViBi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.s24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          AppSizes.gapW16,
          Text(
            'FEED',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.s12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
            size: AppSizes.s20,
          ),
          onPressed: () => context.read<AuthController>().signOut(),
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: Theme.of(context).colorScheme.onSurface,
            size: AppSizes.s20,
          ),
          onPressed: () {
            // TODO : implement notifications
          },
        ),
      ],
    );
  }
}
