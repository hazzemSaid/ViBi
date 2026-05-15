import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      floating: true,
      title: Row(
        children: [
          Image.asset(AppAssets.Newlogo, height: AppSizes.s24),
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
          onPressed: () => context.read<AuthActionCubit>().signOut(),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.s40),
        child: SizedBox(
          height: AppSizes.s40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FeedTab(
                label: 'For You',
                isSelected: selectedTab == 0,
                onTap: () => onTabSelected(0),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                indent: AppSizes.s10,
                endIndent: AppSizes.s10,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _FeedTab(
                label: 'Following',
                isSelected: selectedTab == 1,
                onTap: () => onTabSelected(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.r8),
      onTap: onTap,
      child: Container(
        height: AppSizes.buttonHeightSmall,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surface.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
