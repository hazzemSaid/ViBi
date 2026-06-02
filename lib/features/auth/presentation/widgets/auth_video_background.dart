import 'package:flutter/material.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_background.dart';

class AuthVideoBackground extends StatelessWidget {
  final Widget child;
  const AuthVideoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(child: child);
  }
}
