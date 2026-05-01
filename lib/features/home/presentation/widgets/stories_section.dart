import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'story_card.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  static const _stories = [
    (
      imageUrl: 'https://picsum.photos/seed/picsum1/200/300',
      title: 'Add your story',
      subtitle: 'Share your latest reply',
      badgeText: 'You',
      isAdd: true,
      hasBorder: false,
    ),
    (
      imageUrl: 'https://picsum.photos/seed/picsum2/200/300',
      title: 'raza.rz...',
      subtitle: 'Living life one coffee at a time ☕',
      badgeText: '7h',
      isAdd: false,
      hasBorder: true,
    ),
    (
      imageUrl: 'https://picsum.photos/seed/picsum3/200/300',
      title: 'eltrust...',
      subtitle: 'New ans...',
      badgeText: 'Today',
      isAdd: false,
      hasBorder: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Responsive height: derive from card width aspect ratio
    final cardWidth = (screenWidth * 0.35).clamp(120.0, 160.0);
    final listHeight = (cardWidth * 1.45).clamp(160.0, 240.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSizes.h16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stories',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.s16,
                ),
              ),
              AppSizes.gapH4,
              Text(
                'Tap a card to view. They auto-cycle as you scroll.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: AppSizes.s12,
                ),
              ),
            ],
          ),
        ),
        AppSizes.gapH16,
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSizes.h12,
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final s = _stories[index];
              final badgeColor = s.isAdd
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54);
              return StoryCard(
                imageUrl: s.imageUrl,
                title: s.title,
                subtitle: s.subtitle,
                badgeText: s.badgeText,
                badgeColor: badgeColor,
                isAdd: s.isAdd,
                hasBorder: s.hasBorder,
                onTap: () {},
              );
            },
          ),
        ),
        AppSizes.gapH16,
      ],
    );
  }
}
