import 'package:flutter/material.dart';
import 'package:vibi/features/home/presentation/widgets/story_card.dart';

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
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stories',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap a card to view. They auto-cycle as you scroll.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
        const SizedBox(height: 16),
      ],
    );
  }
}
