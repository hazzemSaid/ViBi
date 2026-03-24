import 'package:flutter/material.dart';

import 'answer_share_card_models.dart';

class PolaroidCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const PolaroidCard({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(ShareCardBackgrounds.polaroid),
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
