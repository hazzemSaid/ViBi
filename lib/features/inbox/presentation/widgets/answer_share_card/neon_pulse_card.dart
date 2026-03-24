import 'package:flutter/material.dart';
import 'package:vibi/core/theme/app_colors.dart';

import 'answer_share_card_models.dart';

class NeonPulseCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const NeonPulseCard({
    super.key,
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ShareCardLayout.storyWidth,
      height: ShareCardLayout.storyHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(ShareCardBackgrounds.neonPulse),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.46),
            BlendMode.darken,
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ViBi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Icon(Icons.favorite_rounded, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnonymous ? 'ANONYMOUS ASKED' : 'SOMEONE ASKED',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            answerText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                '@$username',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const Text(
                'vibi.social',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
