import 'package:flutter/material.dart';

class FeedLoadingState extends StatelessWidget {
  const FeedLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
