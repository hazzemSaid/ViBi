import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/di/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    final sharedPrefs = getIt<SharedPreferences>();
    if (!mounted) return;
    final hasSeenOnboarding =
        sharedPrefs.getBool('has_seen_onboarding') ?? false;

    if (hasSeenOnboarding) {
      context.go('/welcome');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Image.asset(
          AppAssets.appIcon,
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.primary,
            size: 50,
          ),
        ),
      ),
    );
  }
}
