import 'package:flutter/material.dart';

class EditorColorSwatch extends StatelessWidget {
  const EditorColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: selected
            ? Icon(
                Icons.check_rounded,
                color: color.computeLuminance() > 0.55
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}
