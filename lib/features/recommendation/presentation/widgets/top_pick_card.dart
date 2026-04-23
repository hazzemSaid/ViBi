import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

/// Displays a horizontal compact card for a top pick media item.
/// Highlights the card background and changes its trailing icon if selected.
class TopPickCard extends StatelessWidget {
  const TopPickCard({
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: media.posterUrl,
                width: 50,
                height: 75,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 50,
                  height: 75,
                  color: const Color(0xFF121217),
                  child: const Center(child: Icon(Icons.movie, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF5F6F8),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${media.year} • ${media.mediaType == 'tv' ? 'TV' : 'Movie'}',
                    style: const TextStyle(
                      color: Color(0xFF8F9198),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF5A7A), width: 1.5),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.add,
                color: const Color(0xFFFF5A7A),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
