import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

class ProfileQuestionPlaceholderCard extends StatelessWidget {
  const ProfileQuestionPlaceholderCard({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Placeholder',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
SizedBox(height: AppSizes.s8),
          Text(
            'Custom hint text shown in the anonymous question box',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: AppSizes.s12),
          TextFormField(
            controller: controller,
            maxLines: 2,
            maxLength: 100,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Type your anonymous message...',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




