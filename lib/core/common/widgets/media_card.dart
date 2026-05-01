import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.media,
    this.onTap,
    this.showOverview = false,
    this.compact = false,
  });

  final TmdbMedia media;
  final VoidCallback? onTap;
  final bool showOverview;
  final bool compact;

  String get _mediaTypeLabel => media.mediaType == 'tv' ? 'TV' : 'Movie';

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.55),
            borderRadius: borderRadius,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 330;
              final posterWidth = compact
                  ? (isNarrow ? 50.0 : 58.0)
                  : (isNarrow ? 58.0 : 70.0);
              final posterHeight = posterWidth * 1.45;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Poster(
                    imageUrl: media.posterUrl,
                    width: posterWidth,
                    height: posterHeight,
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
                          style: TextStyle(
                            color: textColor,
                            fontSize: compact ? 14 : 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (media.year.isNotEmpty)
                              _MetaChip(label: media.year, compact: compact),
                            _MetaChip(label: _mediaTypeLabel, compact: compact),
                            if (media.voteAverage != null)
                              _MetaChip(
                                label:
                                    'Rating ${media.voteAverage!.toStringAsFixed(1)}',
                                compact: compact,
                              ),
                          ],
                        ),
                        if (showOverview &&
                            (media.overview?.trim().isNotEmpty ?? false)) ...[
                          const SizedBox(height: 8),
                          Text(
                            media.overview!.trim(),
                            maxLines: compact ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.78),
                              fontSize: compact ? 12 : 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl.isEmpty
            ? Container(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.07),
                child: Icon(
                  Icons.movie_creation_outlined,
                  size: width * 0.42,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.07),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.07),
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: width * 0.42,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.85),
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
