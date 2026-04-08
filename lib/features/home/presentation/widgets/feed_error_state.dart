import 'package:flutter/material.dart';

class FeedErrorState extends StatelessWidget {
  const FeedErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          'Error: $message',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
