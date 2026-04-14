import 'package:flutter/material.dart';

import 'answer_share_card_models.dart';

class EditorialCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const EditorialCard({
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
          image: const AssetImage(ShareCardBackgrounds.editorial),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
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
              Container(width: 38, height: 2, color: Theme.of(context).colorScheme.scrim),
              const SizedBox(width: 10),
              Text(
                'ViBi EDIT',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.scrim,
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
              color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            questionText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.scrim,
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            answerText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.86),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.scrim,
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
                    color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
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




