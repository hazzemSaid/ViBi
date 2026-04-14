import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const customCacheKey = 'myCustomCacheKey';

final customCacheManager = CacheManager(
  Config(
    customCacheKey,
    stalePeriod: const Duration(hours: 12),
    maxNrOfCacheObjects: 60,
    repo: JsonCacheInfoRepository(databaseName: customCacheKey),
    fileService: HttpFileService(),
  ),
);

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    this.isAdd = false,
    this.hasBorder = false,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final bool isAdd;
  final bool hasBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final devicePixelRatio = MediaQuery.of(
      context,
    ).devicePixelRatio.clamp(1.0, 3.0);
    // Responsive card width: 35% on phone, max 160px
    final cardWidth = (screenWidth * 0.35).clamp(120.0, 160.0);
    final targetMemWidth = (cardWidth * devicePixelRatio).round();
    final targetMemHeight = (cardWidth * 1.55 * devicePixelRatio).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: hasBorder || isAdd
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2.5)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                cacheManager: customCacheManager,
                useOldImageOnUrlChange: true,
                memCacheWidth: targetMemWidth,
                memCacheHeight: targetMemHeight,
                maxWidthDiskCache: targetMemWidth,
                maxHeightDiskCache: targetMemHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Theme.of(context).colorScheme.surface),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Icon(Icons.error, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.35)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.scrim.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


