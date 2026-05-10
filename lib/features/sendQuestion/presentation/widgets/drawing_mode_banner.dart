import 'package:flutter/material.dart';

/**
 * Animated banner that indicates whether the canvas is in draw or zoom mode.
 *
 * Displays a brief helper message when [isZoomMode] is true, and fades
 * to a transparent empty bar when false.
 */
class DrawingModeBanner extends StatelessWidget {
  final bool isZoomMode;

  const DrawingModeBanner({super.key, required this.isZoomMode});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 28,
      color: isZoomMode ? Colors.amber.shade100 : Colors.transparent,
      alignment: Alignment.center,
      child: isZoomMode
          ? Text(
              'Zoom mode \u2014 pinch or pan. Tap \u270f\ufe0f to draw.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
              ),
            )
          : null,
    );
  }
}
