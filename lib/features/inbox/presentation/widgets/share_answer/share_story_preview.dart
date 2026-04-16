import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:vibi/features/inbox/presentation/widgets/share_answer/share_answer_models.dart';

/**
 * Live story preview that can be captured as layered screenshots.
 *
 * Takes:
 * - screenshot controllers for full, background, and sticker layers.
 * - content and style inputs such as question, answer, username, and colors.
 *
 * Returns:
 * - A 9:16 preview composition ready for export/share.
 *
 * Used for:
 * - Rendering the final social story visual before sharing.
 */
class ShareStoryPreview extends StatelessWidget {
  const ShareStoryPreview({
    super.key,
    required this.screenshotController,
    required this.backgroundController,
    required this.stickerController,
    required this.isCapturing,
    required this.galleryImage,
    required this.backgroundPreset,
    required this.cardColor,
    required this.cardIsBright,
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  final ScreenshotController screenshotController;
  final ScreenshotController backgroundController;
  final ScreenshotController stickerController;
  final bool isCapturing;
  final File? galleryImage;
  final ShareBackgroundPreset backgroundPreset;
  final Color cardColor;
  final bool cardIsBright;
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  /**
   * Builds the full preview with optional branding overlay.
   *
   * Takes:
   * - build context.
   *
   * Returns:
   * - Screenshot-wrapped story preview widget.
   *
   * Used for:
   * - On-screen preview and image capture source.
   */
  @override
  Widget build(BuildContext context) {
    final previewRadius = BorderRadius.circular(isCapturing ? 0 : 22);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Screenshot(
        controller: screenshotController,
        child: ClipRRect(
          borderRadius: previewRadius,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Screenshot(
                  controller: backgroundController,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBackground(),
                      Container(color: Colors.black.withValues(alpha: 0.10)),
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.06),
                  child: Screenshot(
                    controller: stickerController,
                    child: _buildCard(),
                  ),
                ),
                if (!isCapturing)
                  Align(
                    alignment: const Alignment(0, 0.88),
                    child: _buildStoryBrand(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /**
   * Builds preview background from gallery image, asset, or gradient.
   *
   * Takes:
   * - no runtime arguments; uses widget state inputs.
   *
   * Returns:
   * - Background widget filling preview bounds.
   *
   * Used for:
   * - Applying selected story backdrop.
   */
  Widget _buildBackground() {
    if (galleryImage != null) {
      return Image.file(galleryImage!, fit: BoxFit.cover);
    }
    if (backgroundPreset.isAsset) {
      return Image.asset(backgroundPreset.assetPath!, fit: BoxFit.cover);
    }
    return Container(
      decoration: BoxDecoration(gradient: backgroundPreset.gradient),
    );
  }

  /**
   * Builds the sticker-style question and answer card block.
   *
   * Takes:
   * - no runtime arguments; derives visuals from card inputs.
   *
   * Returns:
   * - Decorated card stack with question, answer, and username chip.
   *
   * Used for:
   * - Main content unit shown in the exported story image.
   */
  Widget _buildCard() {
    final accent = cardColor;
    final accentLabel = cardIsBright ? Colors.black : Colors.white;

    return FractionallySizedBox(
      widthFactor: 0.84,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -0.017,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 10,
                  left: 8,
                  right: -6,
                  bottom: -8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.26),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.90),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.36),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      isAnonymous ? '👻' : '👤',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        isAnonymous
                                            ? 'Anonymous Question'
                                            : 'From ViBi User',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: accent.withValues(alpha: 0.85),
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          questionText,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.90),
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                answerText,
                                textAlign: TextAlign.start,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withValues(alpha: 0.84),
                                  height: 1.38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.alternate_email_rounded,
                                  size: 13,
                                  color: accent,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '@$username',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Transform.rotate(
            angle: 0.015,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.link_rounded,
                      color: accentLabel,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'link in bio',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Builds bottom brand signature shown outside capture mode.
   *
   * Takes:
   * - no runtime arguments.
   *
   * Returns:
   * - Brand lockup widget containing app mark and username.
   *
   * Used for:
   * - On-screen attribution while composing the story.
   */
  Widget _buildStoryBrand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Text(
                'V',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black.withValues(alpha: 0.86),
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'vibi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.90),
                letterSpacing: -1.2,
                height: 0.9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            '@$username',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}
