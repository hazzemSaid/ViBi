import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class FeedErrorState extends StatelessWidget {
  const FeedErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width < 360;
    final isTablet = screenSize.width >= 600;

    // Adaptive sizes
    final animationSize = isTablet
        ? 350.0
        : isSmallScreen
        ? 200.0
        : 250.0;
    final titleFontSize = isTablet ? AppSizes.s28 : AppSizes.s20;
    final messageFontSize = isTablet ? AppSizes.s16 : AppSizes.s14;
    final horizontalPadding = isTablet ? screenSize.width * 0.15 : AppSizes.s40;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  AppAssets.feedErrorState,
                  width: animationSize,
                  height: animationSize,
                ),
                const SizedBox(height: AppSizes.s16),
                Text(
                  'Oops! Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSizes.gapH8,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: messageFontSize,
                  ),
                ),
                AppSizes.gapH24,
                ElevatedButton.icon(
                  onPressed: () {
                    // todo : refresh
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.s24,
                      vertical: AppSizes.s12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
