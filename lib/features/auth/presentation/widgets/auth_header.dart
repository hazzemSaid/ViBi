import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class AuthHeader extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final double titleFontSize;
  final TextStyle? subtitleStyle;
  final double spacingBeforeSubtitle;

  const AuthHeader({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.titleFontSize = 28,
    this.subtitleStyle,
    this.spacingBeforeSubtitle = AppSizes.s12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(height: AppSizes.s24),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: spacingBeforeSubtitle),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style:
                subtitleStyle ??
                TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ],
    );
  }
}
