import 'package:flutter/material.dart';

class FeedLoadMoreIndicator extends StatelessWidget {
  const FeedLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF5A4FCF))),
    );
  }
}
