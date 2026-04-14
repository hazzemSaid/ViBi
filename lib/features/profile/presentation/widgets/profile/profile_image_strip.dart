import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibi/core/constants/app_sizes.dart';

/// Tellonym-style top strip for up to 3 profile images.
///
/// Layout features:
/// - 1 image: Large centered highlight.
/// - 2 or 3 images: Horizontal card row sized from screen media.
class ProfileImageStrip extends StatelessWidget {
  const ProfileImageStrip({
    super.key,
    required this.imageUrls,
    this.fallbackImageUrl,
    this.placeholderInitial = '?',
    this.height = 300,
    this.favColor,
  });

  final List<String> imageUrls;
  final String? fallbackImageUrl;
  final String placeholderInitial;
  final double height;
  final Color? favColor;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final cleaned = imageUrls
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .toList();

    if (cleaned.isEmpty &&
        fallbackImageUrl != null &&
        fallbackImageUrl!.trim().isNotEmpty) {
      cleaned.add(fallbackImageUrl!.trim());
    }

    final itemCount = cleaned.isEmpty ? 1 : cleaned.length;
    final borderColor = favColor ?? Theme.of(context).colorScheme.secondary;
    final stripHeight = height
        .clamp(mediaSize.height * 0.28, mediaSize.height * 0.4)
        .toDouble();
    if (cleaned.length == 3) {
      //change the image in index 0 to 1 and the image in index 1 to 0
      final temp = cleaned[0];
      cleaned[0] = cleaned[1];
      cleaned[1] = temp;
    }
    return Container(
      height: stripHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 0.9],
          colors: [
            borderColor.withValues(alpha: 0.18), // Increased opacity
            borderColor.withValues(alpha: 0.05),
            borderColor.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return Center(
            child: _buildLayout(
              cleaned,
              itemCount,
              maxWidth,
              mediaSize,
              borderColor,
              stripHeight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLayout(
    List<String> cleaned,
    int itemCount,
    double maxWidth,
    Size mediaSize,
    Color borderColor,
    double stripHeight,
  ) {
    if (itemCount == 1) {
      final singleMaxHeight = stripHeight;
      final singleMinHeight = singleMaxHeight < 140.0 ? singleMaxHeight : 140.0;

      return _ProfileImageCard(
        imageUrl: cleaned.isEmpty ? null : cleaned[0],
        placeholderInitial: placeholderInitial,
        borderColor: borderColor,
        width: (mediaSize.width * 0.72).clamp(220.0, 320.0).toDouble(),
        height: (stripHeight * 0.96)
            .clamp(singleMinHeight, singleMaxHeight)
            .toDouble(),
      );
    }

    final sideCardWidth = itemCount == 2
        ? (mediaSize.width * 0.52).clamp(180.0, 260.0).toDouble()
        : (mediaSize.width * 0.32).clamp(140.0, 200.0).toDouble();
    final centerCardWidth = itemCount == 3
        ? (sideCardWidth * 1.45).clamp(180.0, 280.0).toDouble()
        : sideCardWidth;

    final maxCardHeight = (stripHeight - AppSizes.s8).toDouble();
    final safeMaxCardHeight = maxCardHeight > 1.0 ? maxCardHeight : 1.0;
    final minCardHeight = safeMaxCardHeight < 120.0 ? safeMaxCardHeight : 120.0;
    final sideCardHeight = (sideCardWidth * 1.54)
        .clamp(minCardHeight, safeMaxCardHeight)
        .toDouble();
    final centerCardHeight = (centerCardWidth * 1.54)
        .clamp(minCardHeight, safeMaxCardHeight)
        .toDouble();

    return SizedBox(
      height: stripHeight,
      width: maxWidth,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final isCenter = itemCount == 3 && index == 1;
          final itemWidth = centerCardWidth;
          final itemHeight = centerCardHeight;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? AppSizes.s8 : AppSizes.s8,
              right: index == itemCount - 1 ? AppSizes.s8 : AppSizes.s4,
              top: AppSizes.s4,
              bottom: AppSizes.s4,
            ),
            child: SizedBox(
              width: itemWidth,
              child: _ProfileImageCard(
                imageUrl: cleaned[index],
                placeholderInitial: placeholderInitial,
                borderColor: borderColor,
                width: itemWidth,
                height: itemHeight,
                opacity: 1.0,
                isProminent: isCenter,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileImageCard extends StatelessWidget {
  const _ProfileImageCard({
    required this.imageUrl,
    required this.placeholderInitial,
    required this.borderColor,
    required this.width,
    required this.height,
    this.opacity = 1.0,
    this.isProminent = false,
  });

  final String? imageUrl;
  final String placeholderInitial;
  final Color borderColor;
  final double width;
  final double height;
  final double opacity;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.r24),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.95),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.scrim.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: borderColor.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 12),
              spreadRadius: -8,
            ),
            if (isProminent)
              BoxShadow(
                color: borderColor.withValues(alpha: 0.12),
                blurRadius: 26,
                offset: const Offset(0, 14),
                spreadRadius: -6,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r24),
          child: _buildImageOrPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildImageOrPlaceholder(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    final bool isNetwork = imageUrl!.startsWith('http');

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isNetwork)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                _buildPlaceholder(context, isLoading: true),
            errorWidget: (context, url, error) => _buildPlaceholder(context),
          )
        else
          Image.asset(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, __, ___) => _buildPlaceholder(context),
          ),
        // Subtle overlay for depth
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.7, 1.0],
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  Colors.transparent,
                  Theme.of(context).colorScheme.scrim.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context, {bool isLoading = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            )
          : Text(
              placeholderInitial,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: (width * 0.25).clamp(24, 48),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.scrim.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
    );
  }
}
