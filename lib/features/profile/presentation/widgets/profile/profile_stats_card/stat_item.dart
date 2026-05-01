import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const StatItem({super.key, required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
SizedBox(height: AppSizes.s4),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: child,
        ),
      );
    }

    return child;
  }
}


