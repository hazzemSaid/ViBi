import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';

class ProfileQuestionPlaceholderCard extends StatelessWidget {
  const ProfileQuestionPlaceholderCard({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Question Placeholder',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          const Text(
            'Custom hint text shown in the anonymous question box',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSizes.s12),
          TextFormField(
            controller: controller,
            maxLines: 2,
            maxLength: 100,
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Type your anonymous message...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.background,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.r12,
                ),
                borderSide: const BorderSide(
                  color: Colors.white10,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.r12,
                ),
                borderSide: const BorderSide(
                  color: Colors.white10,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.r12,
                ),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
