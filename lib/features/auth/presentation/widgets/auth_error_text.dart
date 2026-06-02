import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class AuthErrorText extends StatelessWidget {
  final String? message;

  const AuthErrorText({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s16),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 14,
        ),
      ),
    );
  }
}
