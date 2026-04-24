import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width >= 600;
    final isSmallScreen = screenSize.width < 360;

    // Adaptive sizes
    final animationSize = isTablet
        ? 350.0
        : isSmallScreen
        ? 220.0
        : 280.0;
    final titleFontSize = isTablet ? AppSizes.s32 : AppSizes.s24;
    final messageFontSize = isTablet ? AppSizes.s18 : AppSizes.s15;
    final horizontalPadding = isTablet ? screenSize.width * 0.15 : AppSizes.s40;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, AppSizes.s20 * (1 - value)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            AppAssets.feedEmptyState,
                            width: animationSize,
                            height: animationSize,
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                          ),
                          AppSizes.gapH12,
                          Text(
                            'Your feed is quiet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          AppSizes.gapH12,
                          Text(
                            'Follow more people or start asking questions to fill your feed with interesting stories!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: messageFontSize,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
