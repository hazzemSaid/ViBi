import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final Widget title;
  final Widget subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, subtitle],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
