import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

/// Displays a vertical card for a trending media item.
/// Highlights the card border if it is currently selected.
class TrendingCard extends StatelessWidget {
  const TrendingCard({
    super.key,
    required this.media,
    required this.isSelected,
    this.onTap,
  });

  /// The media data model containing title, year, and poster URL.
  final TmdbMedia media;
  
  /// Whether this media is currently selected in the UI.
  final bool isSelected;
  
  /// The callback that gets fired when the card is pressed.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF121217),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: media.posterUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.movie, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              media.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF5F6F8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              media.year,
              style: const TextStyle(
                color: Color(0xFF8F9198),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
