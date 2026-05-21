import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/nav_main_layout/main_layout.dart';
import 'package:vibi/features/answer/presentation/screen/share_answer_screen.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibi/features/auth/presentation/cubit/anonymous_auth_cubit.dart';
import 'package:vibi/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:vibi/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:vibi/features/auth/presentation/pages/login_screen.dart';
import 'package:vibi/features/auth/presentation/pages/set_new_password_screen.dart';
import 'package:vibi/features/auth/presentation/pages/signup_screen.dart';
import 'package:vibi/features/auth/presentation/pages/verify_email_screen.dart';
import 'package:vibi/features/auth/presentation/pages/welcome_screen.dart';
import 'package:vibi/features/home/presentation/pages/home_screen.dart';
import 'package:vibi/features/inbox/presentation/pages/inbox_screen.dart';
import 'package:vibi/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:vibi/features/onboarding/presentation/pages/setup_profile_screen.dart';
import 'package:vibi/features/profile/presentation/pages/edit_profile_public_web_screen.dart';
import 'package:vibi/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:vibi/features/profile/presentation/pages/followers_list_screen.dart';
import 'package:vibi/features/profile/presentation/pages/following_list_screen.dart';
import 'package:vibi/features/profile/presentation/pages/profile_screen.dart';
import 'package:vibi/features/profile/presentation/pages/public_profile_screen.dart';
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
        path: '/setup-profile',
        builder: (context, state) => const SetupProfileScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AnonymousAuthCubit>.value(
              value: getIt<AnonymousAuthCubit>(),
            ),
          ],
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyEmailScreen(
            initialEmail: extra?['email'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<PasswordResetCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/set-new-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => getIt<PasswordResetCubit>(),
            child: SetNewPasswordScreen(
              email: extra?['email'] as String? ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => EditProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile/public-web',
        name: 'edit-profile-public-web',
        builder: (context, state) => const EditProfilePublicWebScreen(),
      ),
      GoRoute(
        path: '/share-answer',
        name: 'share-answer',
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          return ShareAnswerScreen(
            questionText: extra?['questionText'] ?? '',
            answerText: extra?['answerText'] ?? '',
            username: extra?['username'] ?? '',
            isAnonymous: extra?['isAnonymous'] ?? false,
            drawingUrl: extra?['drawingUrl'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        name: 'public-profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final currentId = authCubit.currentUser?.id;
          if (currentId == null || userId == currentId) {
            return ProfileScreen();
          }
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
                builder: (context, state) => Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                      ),
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
      final user = authCubit.currentUser;
      final uri = state.uri;
      final location = state.matchedLocation;

      // Don't redirect while loading
      if (authCubit.state.isLoading) return null;

      // Handle Splash screen transition
      if (location == '/splash') {
        if (user != null) return '/home';

        final prefs = getIt<SharedPreferences>();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        if (!hasSeenOnboarding) return '/onboarding';

        return '/welcome';
      }

      // Define route categories
      final isAuthRoute =
          location == '/login' ||
          location == '/signup' ||
          location == '/welcome' ||
          location == '/forgot-password';

      final isResetRoute = location == '/set-new-password';

      // Unauthenticated users
      if (user == null) {
        if (!isAuthRoute &&
            !isResetRoute &&
            location != '/verify-email' &&
            location != '/onboarding') {
          return '/welcome';
        }
        return null;
      }

      // Authenticated users
      if (user.isAnonymous) {
        if (location == '/verify-email') return '/home';
        return null;
      }

      if (!user.emailVerified) {
        if (location != '/verify-email') return '/verify-email';
        return null;
      }

      // Authenticated and verified users shouldn't see auth screens
      if (isAuthRoute || location == '/verify-email') {
        return '/home';
      }

      // Allow reset password screen for authenticated users
      if (isResetRoute) return null;

      return null;
    },
  );
}
