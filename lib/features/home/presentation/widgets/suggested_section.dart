import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'suggested_card.dart';

class SuggestedSection extends StatelessWidget {
  const SuggestedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.35).clamp(120.0, 160.0);
    // Height: card content + padding
    final listHeight = (cardWidth * 1.4).clamp(160.0, 210.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSizes.p16,
          child: Text(
            'Suggested for you',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.s16,
            ),
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSizes.h12,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final s = _suggestions[index];
              return SuggestedCard(
                avatarUrl: s.avatarUrl,
                username: s.username,
                subtitle: s.subtitle,
                onFollow: () {},
              );
            },
          ),
        ),
        AppSizes.gapH16,
      ],
    );
  }
}

// Data model for suggestions — replace with a real provider when ready
typedef _Suggestion = ({String avatarUrl, String username, String subtitle});

const List<_Suggestion> _suggestions = [
  (
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    username: 'clara.z',
    subtitle: 'Popular',
  ),
  (
    avatarUrl: 'https://i.pravatar.cc/150?img=8',
    username: 'mike_d',
    subtitle: 'New',
  ),
  (
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    username: 'alex_k',
    subtitle: 'New',
  ),
];
