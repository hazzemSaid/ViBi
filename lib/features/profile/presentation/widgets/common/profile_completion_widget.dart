import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final UserProfile? profile;

  const ProfileCompletionWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const SizedBox.shrink();
    final p = profile!;

    final tasks = <_CompletionTask>[
      _CompletionTask(
        title: 'Add Bio',
        description: 'Tell the world about yourself',
        icon: Icons.edit_note_outlined,
        isCompleted: p.bio != null && p.bio!.isNotEmpty,
      ),
      _CompletionTask(
        title: 'Add Username',
        description: 'Pick a unique handler',
        icon: Icons.alternate_email_outlined,
        isCompleted: p.username.isNotEmpty,
      ),
      _CompletionTask(
        title: 'Profile Photo',
        description: 'A picture is worth 1000 words',
        icon: Icons.camera_alt_outlined,
        isCompleted:
            p.avatarUrls.isNotEmpty &&
            !p.avatarUrls.first.contains('placeholder') &&
            !p.avatarUrls.first.contains('unsplash.com'),
      ),
      _CompletionTask(
        title: 'Add Full Name',
        description: 'What should we call you?',
        icon: Icons.person_outline,
        isCompleted: p.name.isNotEmpty,
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
            Text(
              'Complete your profile',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$completedCount/${tasks.length}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            minHeight: 8,
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
                onTap: () => context.pushNamed('edit-profile-public-web'),
                borderRadius: BorderRadius.circular(AppSizes.r20),
                child: Container(
                  width: 160,
                  padding: EdgeInsets.all(AppSizes.s16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.r20),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSizes.s8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          task.icon,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                      ),
Spacer(),
                      Text(
                        task.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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




