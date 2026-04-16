import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/features/inbox/presentation/cubits/pending_questions_cubit.dart';
import 'package:vibi/features/inbox/presentation/state/answer_screen_visibility.dart';
import 'package:vibi/features/inbox/presentation/state/pending_questions_state.dart';

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
    // Check if there's a modal/dialog open above the main navigation
    // Navigator.canPop() returns true if there's a route that can be popped
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

  Widget _buildInboxIconWithBadge() {
    final state = context.watch<PendingQuestionsCubit>().state;
    final count = state is PendingQuestionsSuccess ? state.questions.length : 0;
    final Image inboxIcon = Image(
      image: const AssetImage('assets/images/inbox.png'),
      width: 24,
      height: 24,
      color: widget.currentIndex == 2 ? Colors.white : Colors.white54,
    );
    if (count > 0) {
      return Badge(
        label: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(count > 99 ? '99+' : count.toString()),
        ),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        child: inboxIcon,
      );
    }
    return inboxIcon;
  }

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFF0F1419),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF0F1419),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: widget.currentIndex,
              onTap: widget.onTap,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'For you',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _buildInboxIconWithBadge(),
                  label: 'Inbox',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
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
