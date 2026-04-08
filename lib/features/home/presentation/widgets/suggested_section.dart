import 'package:flutter/material.dart';
import 'package:vibi/features/home/presentation/widgets/suggested_card.dart';

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
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Suggested for you',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
        const SizedBox(height: 16),
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
