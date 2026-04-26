import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/notifiers/answerScreenVisibilityNotifier.dart';
import 'package:vibi/features/inbox/presentation/view/pending_questions_cubit/pending_questions_cubit.dart';
import 'package:vibi/features/inbox/presentation/view/pending_questions_cubit/pending_questions_state.dart';

/**
 * Root layout widget that wraps the go_router Shell with bottom navigation.
 *
 * Takes:
 * - navigationShell: StatefulNavigationShell from go_router.
 *
 * Returns:
 * - Scaffold with bottom navigation bar and optional answer screen handling.
 *
 * Used for:
 * - Providing the main app layout with tab-based navigation.
 */
class MainLayout extends StatelessWidget {
  const MainLayout({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  bool _isModalOpen(BuildContext context) {
    return Navigator.of(context, rootNavigator: false).canPop();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: answerScreenVisibilityNotifier,
      builder: (context, isAnswerScreenOpen, _) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: (isAnswerScreenOpen || _isModalOpen(context))
              ? null
              : _BottomNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: _onTap,
                ),
        );
      },
    );
  }
}

class _BottomNavBar extends StatefulWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final Function(int) onTap;

  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isVisible) {
        setState(() => _isVisible = false);
        _animationController.reverse();
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
        _animationController.forward();
      }
    }
  }

  Widget _buildInboxIconWithBadge(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<PendingQuestionsCubit>().state;
    final count = state is PendingQuestionsSuccess ? state.questions.length : 0;
    final inboxIcon = Image(
      image: const AssetImage('assets/images/inbox.png'),
      width: AppSizes.iconNormal,
      height: AppSizes.iconNormal,
      color: widget.currentIndex == 2
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurface.withValues(alpha: 0.54),
    );

    if (count > 0) {
      return Badge(
        label: Padding(
          padding: EdgeInsets.only(top: AppSizes.s2),
          child: Text(count > 99 ? '99+' : count.toString()),
        ),
        backgroundColor: theme.colorScheme.error,
        textColor: theme.colorScheme.onError,
        child: inboxIcon,
      );
    }
    return inboxIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        _handleScroll(notification);
        return false;
      },
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1),
        ).animate(_animationController),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: AppSizes.s8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              backgroundColor: theme.colorScheme.surface,
              selectedItemColor: theme.colorScheme.onSurface,
              unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.54),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: isSmallScreen ? AppSizes.s10 : AppSizes.s12,
              unselectedFontSize: isSmallScreen ? AppSizes.s10 : AppSizes.s12,
              currentIndex: widget.currentIndex,
              onTap: widget.onTap,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    size: AppSizes.iconNormal,
                  ),
                  activeIcon: Icon(
                    Icons.home,
                    size: AppSizes.iconNormal,
                  ),
                  label: 'For you',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.search,
                    size: AppSizes.iconNormal,
                  ),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _buildInboxIconWithBadge(context),
                  label: 'Inbox',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.favorite_border,
                    size: AppSizes.iconNormal,
                  ),
                  activeIcon: Icon(
                    Icons.favorite,
                    size: AppSizes.iconNormal,
                  ),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outline,
                    size: AppSizes.iconNormal,
                  ),
                  activeIcon: Icon(
                    Icons.person,
                    size: AppSizes.iconNormal,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
