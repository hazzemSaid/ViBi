import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/widgets/main_layout.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';
import 'package:vibi/features/auth/presentation/screens/login_screen.dart';
import 'package:vibi/features/auth/presentation/screens/signup_screen.dart';
import 'package:vibi/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:vibi/features/auth/presentation/screens/welcome_screen.dart';
import 'package:vibi/features/home/presentation/screens/home_screen.dart';
import 'package:vibi/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:vibi/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:vibi/features/profile/presentation/screens/edit_profile_public_web_screen.dart';
import 'package:vibi/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:vibi/features/profile/presentation/screens/followers_list_screen.dart';
import 'package:vibi/features/profile/presentation/screens/following_list_screen.dart';
import 'package:vibi/features/profile/presentation/screens/profile_screen.dart';
import 'package:vibi/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:vibi/features/search/presentation/screens/search_screen.dart';
import 'package:vibi/features/splash/presentation/screens/splash_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthCubit authCubit) {
  final authRepository = getIt<AuthRepository>();
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      // Move edit-profile to top level so pushNamed works reliably
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      // GoRoute(
      //   path: '/edit-profile/basic',
      //   name: 'edit-profile-basic',
      //   // builder: (context, state) => const EditProfileBasicInfoSection(),
      // ),
      GoRoute(
        path: '/edit-profile/public-web',
        name: 'edit-profile-public-web',
        builder: (context, state) => const EditProfilePublicWebScreen(),
      ),
      // Public profile route with user ID parameter
      GoRoute(
        path: '/profile/:userId',
        name: 'public-profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return PublicProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/u/:username',
        name: 'public-profile-username',
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return PublicProfileScreen.byUsername(username: username);
        },
      ),
      // Followers list route
      GoRoute(
        path: '/:userId/followers',
        name: 'followers-list',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final isCurrentUser = state.extra as bool? ?? false;
          return FollowersListScreen(
            userId: userId,
            isCurrentUser: isCurrentUser,
          );
        },
      ),
      // Following list route
      GoRoute(
        path: '/:userId/following',
        name: 'following-list',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final isCurrentUser = state.extra as bool? ?? false;
          return FollowingListScreen(
            userId: userId,
            isCurrentUser: isCurrentUser,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const Scaffold(
                  backgroundColor: Color(0xFF0F1419),
                  body: Center(
                    child: Text(
                      'Favorites',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authControllerState = context.read<AuthController>().state;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/welcome';

      final user = authCubit.currentUser;
      if (user != null) {
        // User is authenticated
        if (!user.emailVerified) {
          // Need verification
          if (state.matchedLocation != '/verify-email') {
            return '/verify-email';
          }
          return null;
        } else {
          // User is verified
          if (loggingIn ||
              state.matchedLocation == '/splash' ||
              state.matchedLocation == '/verify-email') {
            return '/home';
          }
        }
      } else {
        // If logged out and not on auth screens, go welcome (after splash)
        if (!loggingIn &&
            state.matchedLocation != '/splash' &&
            state.matchedLocation != '/onboarding' &&
            state.matchedLocation != '/verify-email') {
          return '/welcome';
        }
      }
      if (authCubit.state.isLoading || authControllerState.isLoading)
        return null;
      return null;
    },
  );
}
