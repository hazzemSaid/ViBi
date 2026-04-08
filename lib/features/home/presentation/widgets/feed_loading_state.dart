import 'package:flutter/material.dart';

class FeedLoadingState extends StatelessWidget {
  const FeedLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator(color: Color(0xFF5A4FCF))),
    );
  }
}
