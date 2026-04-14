import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SuggestedCard extends StatelessWidget {
  const SuggestedCard({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.subtitle,
    this.onFollow,
  });

  final String avatarUrl;
  final String username;
  final String subtitle;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.35).clamp(120.0, 160.0);

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: ResizeImage(
              CachedNetworkImageProvider(avatarUrl),
              width: 192,
              height: 192,
            ),
          ),
SizedBox(height: 12),
          Text(
            username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.72), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              onPressed: onFollow,
              child: const Text(
                'Follow',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

