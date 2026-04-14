import 'package:flutter/material.dart';

import 'answer_share_card_models.dart';

class SunsetGlowCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const SunsetGlowCard({
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
          image: const AssetImage(ShareCardBackgrounds.sunsetGlow),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.scrim.withValues(alpha: 0.24),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isAnonymous ? 'ANON DROP' : 'ASK ME',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
Spacer(),
Text(
                'ViBi',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
SizedBox(height: 20),
          Text(
            questionText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18)),
            ),
            child: Text(
              answerText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
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
                backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                child: Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '@$username',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
Flexible(
                child: Text(
                  'vibi.social',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
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


