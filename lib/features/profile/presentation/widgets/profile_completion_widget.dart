import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final UserProfile? profile;

  const ProfileCompletionWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const SizedBox.shrink();

    final tasks = <_CompletionTask>[
      _CompletionTask(
        title: 'Add Bio',
        description: 'Tell the world about yourself',
        icon: Icons.edit_note_outlined,
        isCompleted: profile!.bio != null && profile!.bio!.isNotEmpty,
      ),
      _CompletionTask(
        title: 'Add Username',
        description: 'Pick a unique handler',
        icon: Icons.alternate_email_outlined,
        isCompleted: profile!.username != null && profile!.username!.isNotEmpty,
      ),
      _CompletionTask(
        title: 'Profile Photo',
        description: 'A picture is worth 1000 words',
        icon: Icons.camera_alt_outlined,
        isCompleted:
            profile!.profileImageUrl != null &&
            !profile!.profileImageUrl!.contains('placeholder') &&
            !profile!.profileImageUrl!.contains('unsplash.com'),
      ),
      _CompletionTask(
        title: 'Add Full Name',
        description: 'What should we call you?',
        icon: Icons.person_outline,
        isCompleted: profile!.name != null && profile!.name!.isNotEmpty,
      ),
    ];

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final progress = completedCount / tasks.length;

    if (progress >= 1.0) return const SizedBox.shrink();

    final remainingTasks = tasks.where((t) => !t.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.s32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Complete your profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$completedCount/${tasks.length}',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: remainingTasks.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s12),
            itemBuilder: (context, index) {
              final task = remainingTasks[index];
              return InkWell(
                onTap: () => context.pushNamed('edit-profile'),
                borderRadius: BorderRadius.circular(AppSizes.r20),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(AppSizes.s16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.r20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.s8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          task.icon,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CompletionTask {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;

  const _CompletionTask({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
  });
}
