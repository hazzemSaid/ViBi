import 'package:flutter/material.dart';

import 'answer_share_card/answer_share_card_models.dart';
import 'answer_share_card/editorial_card.dart';
import 'answer_share_card/neon_pulse_card.dart';
import 'answer_share_card/polaroid_card.dart';
import 'answer_share_card/sunset_glow_card.dart';

export 'answer_share_card/answer_share_card_models.dart';

/// Branded card widget captured as a screenshot for Instagram Stories sharing.
/// Fixed width so the screenshot is consistent regardless of device screen size.
class AnswerShareCard extends StatelessWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;
  final ShareCardTemplate template;
  static double width =
      1080; // Fixed width for consistent Instagram Story screenshots
  static double height =
      1080; // Fixed height for consistent Instagram Story screenshots

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
        return NeonPulseCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
      case ShareCardTemplate.editorial:
        return EditorialCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
      case ShareCardTemplate.sunsetGlow:
        return SunsetGlowCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
      case ShareCardTemplate.polaroid:
        return PolaroidCard(
          questionText: questionText,
          answerText: answerText,
          username: username,
          isAnonymous: isAnonymous,
        );
    }
  }
}
