import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';

import 'status_pill.dart';

class WebHeroCard extends StatelessWidget {
  const WebHeroCard({
    super.key,
    required this.publicProfileEnabled,
    required this.allowAnonymousQuestions,
  });

  final bool publicProfileEnabled;
  final bool allowAnonymousQuestions;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r14),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/photo_2026-03-21_10-25-01.jpg',
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSizes.s12,
            right: AppSizes.s12,
            bottom: AppSizes.s12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Public Profile Experience',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      label: publicProfileEnabled ? 'Public ON' : 'Public OFF',
                      active: publicProfileEnabled,
                    ),
                    StatusPill(
                      label: allowAnonymousQuestions
                          ? 'Anonymous ON'
                          : 'Anonymous OFF',
                      active: allowAnonymousQuestions,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
