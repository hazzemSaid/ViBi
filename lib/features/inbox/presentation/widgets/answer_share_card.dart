import 'package:flutter/material.dart';
import 'package:vibi/core/theme/app_colors.dart';

class _ShareCardBackgrounds {
  static const String neonPulse = 'assets/images/background1.jpg';
  static const String editorial = 'assets/images/background3.jpg';
  static const String sunsetGlow = 'assets/images/background2.jpg';
  static const String polaroid = 'assets/images/background4.jpg';
}

enum ShareCardTemplate { neonPulse, editorial, sunsetGlow, polaroid }

extension ShareCardTemplateX on ShareCardTemplate {
  String get title {
    switch (this) {
      case ShareCardTemplate.neonPulse:
        return 'Neon Pulse';
      case ShareCardTemplate.editorial:
        return 'Editorial';
      case ShareCardTemplate.sunsetGlow:
        return 'Sunset Glow';
      case ShareCardTemplate.polaroid:
        return 'Polaroid';
    }
  }

  String get subtitle {
    switch (this) {
      case ShareCardTemplate.neonPulse:
        return 'Bold and vibrant';
      case ShareCardTemplate.editorial:
        return 'Minimal and sharp';
      case ShareCardTemplate.sunsetGlow:
        return 'Warm and dreamy';
      case ShareCardTemplate.polaroid:
        return 'Playful scrapbook';
    }
  }
}

/// Branded card widget captured as a screenshot for Instagram Stories sharing.
/// Fixed width so the screenshot is consistent regardless of device screen size.
class AnswerShareCard extends StatelessWidget {
  static const double storyWidth = 324;
  static const double storyHeight = 576; // 9:16 Instagram Story ratio

  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;
  final ShareCardTemplate template;

  const AnswerShareCard({
    super.key,
    required this.questionText,
    required this.answerText,
    required this.username,
    this.isAnonymous = false,
    this.template = ShareCardTemplate.neonPulse,
  });

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case ShareCardTemplate.neonPulse:
        return _NeonPulseCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
      case ShareCardTemplate.editorial:
        return _EditorialCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
      case ShareCardTemplate.sunsetGlow:
        return _SunsetGlowCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
      case ShareCardTemplate.polaroid:
        return _PolaroidCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
    }
  }
}

class _NeonPulseCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const _NeonPulseCard({
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AnswerShareCard.storyWidth,
      height: AnswerShareCard.storyHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(_ShareCardBackgrounds.neonPulse),
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

class _EditorialCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const _EditorialCard({
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AnswerShareCard.storyWidth,
      height: AnswerShareCard.storyHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(_ShareCardBackgrounds.editorial),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFFF6EFE6).withValues(alpha: 0.82),
            BlendMode.lighten,
          ),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 38, height: 2, color: Colors.black),
              const SizedBox(width: 10),
              const Text(
                'ViBi EDIT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'QUESTION',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            questionText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          Container(
            width: 56,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            answerText,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.86),
              fontSize: 15,
              height: 1.45,
            ),
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  isAnonymous ? 'ANON PROMPT' : 'REAL QUESTION',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunsetGlowCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const _SunsetGlowCard({
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AnswerShareCard.storyWidth,
      height: AnswerShareCard.storyHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(_ShareCardBackgrounds.sunsetGlow),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.24),
            BlendMode.darken,
          ),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isAnonymous ? 'ANON DROP' : 'ASK ME',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'ViBi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            questionText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              answerText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
              maxLines: 7,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Flexible(
                child: Text(
                  'vibi.social',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolaroidCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const _PolaroidCard({
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AnswerShareCard.storyWidth,
      height: AnswerShareCard.storyHeight,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(_ShareCardBackgrounds.polaroid),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.18),
            BlendMode.darken,
          ),
        ),
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBCE7FD),
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFBCE7FD), Color(0xFFFFD6E7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'ViBi',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isAnonymous
                      ? Icons.visibility_off_rounded
                      : Icons.flash_on_rounded,
                  color: Colors.black87,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'TODAY\'S DROP',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              questionText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                answerText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.45,
                ),
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '@$username',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Flexible(
                  child: Text(
                    'stick this on your story',
                    style: TextStyle(color: Colors.black54, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
