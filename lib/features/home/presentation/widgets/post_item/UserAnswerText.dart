import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class UserAnswerText extends StatelessWidget {
  const UserAnswerText({super.key, required this.answerText});

  final String answerText;

  @override
  Widget build(BuildContext context) {
    return Text(
      answerText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: AppSizes.s16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
