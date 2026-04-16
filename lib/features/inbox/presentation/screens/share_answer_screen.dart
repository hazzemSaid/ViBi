import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibi/features/inbox/presentation/widgets/share_answer/share_answer_models.dart';
import 'package:vibi/features/inbox/presentation/widgets/share_answer/share_story_controls.dart';
import 'package:vibi/features/inbox/presentation/widgets/share_answer/share_story_preview.dart';
import 'package:vibi/features/inbox/presentation/widgets/share_answer/share_story_top_bar.dart';

/**
 * Story builder screen for answer-sharing output.
 *
 * Takes:
 * - answered question content and username metadata.
 *
 * Returns:
 * - Interactive composer that exports and shares a generated story image.
 *
 * Used for:
 * - Post-answer social sharing flow from inbox reply journey.
 */
class ShareAnswerScreen extends StatefulWidget {
  const ShareAnswerScreen({
    super.key,
    required this.questionText,
    required this.answerText,
    required this.username,
    this.isAnonymous = false,
  });

  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  @override
  State<ShareAnswerScreen> createState() => _ShareAnswerScreenState();
}

class _ShareAnswerScreenState extends State<ShareAnswerScreen> {
  final _screenshotController = ScreenshotController();
  final _backgroundController = ScreenshotController();
  final _stickerController = ScreenshotController();

  static const MethodChannel _instagramStoryChannel = MethodChannel(
    'vibi/instagram_story',
  );

  File? _galleryImage;
  int _bgPresetIndex = 0;
  int _cardColorIndex = 0;

  bool _isCapturing = false;
  bool _isSharing = false;

  Color get _cardColor => shareCardColors[_cardColorIndex];

  bool get _cardIsBright {
    final c = _cardColor;
    return (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) > 186;
  }

  /**
   * Opens gallery picker and stores selected image as background.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Future that completes after optional image selection.
   *
   * Used for:
   * - Replacing preset background with user-selected media.
   */
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _galleryImage = File(picked.path));
    }
  }

  /**
   * Selects one predefined background and clears gallery override.
   *
   * Takes:
   * - selected preset index.
   *
   * Returns:
   * - void.
   *
   * Used for:
   * - Background preset switching from controls panel.
   */
  void _selectBackground(int index) {
    setState(() {
      _galleryImage = null;
      _bgPresetIndex = index;
    });
  }

  /**
   * Selects sticker/card accent color.
   *
   * Takes:
   * - selected color index.
   *
   * Returns:
   * - void.
   *
   * Used for:
   * - Updating preview accent styling.
   */
  void _selectCardColor(int index) {
    setState(() => _cardColorIndex = index);
  }

  /**
   * Captures full story preview and writes image file to temp storage.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - path to generated PNG file, or null if capture fails.
   *
   * Used for:
   * - Save/share operations requiring one flattened image.
   */
  Future<String?> _captureToFile() async {
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 60));
    final bytes = await _screenshotController.capture(pixelRatio: 3.0);
    if (mounted) setState(() => _isCapturing = false);
    return _writePngToTemp(bytes, 'vibi_story');
  }

  /**
   * Persists PNG bytes in temporary directory.
   *
   * Takes:
   * - image bytes and file prefix.
   *
   * Returns:
   * - absolute temporary file path, or null when bytes are empty.
   *
   * Used for:
   * - Standardized image-output utility for all share flows.
   */
  Future<String?> _writePngToTemp(Uint8List? bytes, String filePrefix) async {
    if (bytes == null) return null;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /**
   * Captures background and sticker as separate assets for Instagram story API.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - map containing backgroundPath and stickerPath, or null on failure.
   *
   * Used for:
   * - Native Instagram sticker story integration.
   */
  Future<Map<String, String>?> _captureInstagramAssets() async {
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 60));

    final backgroundBytes = await _backgroundController.capture(
      pixelRatio: 3.0,
    );
    final stickerBytes = await _stickerController.capture(pixelRatio: 3.0);

    if (mounted) setState(() => _isCapturing = false);

    final backgroundPath = await _writePngToTemp(
      backgroundBytes,
      'vibi_story_bg',
    );
    final stickerPath = await _writePngToTemp(
      stickerBytes,
      'vibi_story_sticker',
    );

    if (backgroundPath == null || stickerPath == null) return null;

    return {'backgroundPath': backgroundPath, 'stickerPath': stickerPath};
  }

  /**
   * Shares a local image file through platform share sheet.
   *
   * Takes:
   * - file path and optional caption text.
   *
   * Returns:
   * - Future that completes when share intent is dispatched.
   *
   * Used for:
   * - Generic fallback and save flow sharing.
   */
  Future<void> _shareFile(String path, {String? text}) {
    return Share.shareXFiles([
      XFile(path, mimeType: 'image/png'),
    ], text: text ?? 'Check out my answer on ViBi ✨ vibi.app');
  }

  /**
   * Captures and shares current story preview as a single image.
   *
   * Takes:
   * - optional share text.
   *
   * Returns:
   * - Future that completes after share flow ends.
   *
   * Used for:
   * - Save action and non-Instagram sharing fallback.
   */
  Future<void> _share({String? text}) async {
    setState(() => _isSharing = true);
    try {
      final path = await _captureToFile();
      if (path == null) throw Exception('Capture failed');
      await _shareFile(path, text: text);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /**
   * Shares a flattened story image when Instagram sticker mode is unavailable.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Future that completes after fallback share is invoked.
   *
   * Used for:
   * - Device/platform compatibility fallback handling.
   */
  Future<void> _shareInstagramFallbackImage() async {
    final fallbackPath = await _captureToFile();
    if (fallbackPath == null) {
      throw Exception('Capture failed');
    }
    await _shareFile(fallbackPath, text: 'My ViBi answer ✨ vibi.app');
  }

  /**
   * Attempts native Instagram story sticker share and falls back to image share.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Future that completes after native or fallback flow.
   *
   * Used for:
   * - Primary Instagram action from composer controls.
   */
  Future<void> _shareToInstagramStory() async {
    setState(() => _isSharing = true);

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        await _shareInstagramFallbackImage();
        return;
      }

      final assets = await _captureInstagramAssets();
      if (assets == null) {
        await _shareInstagramFallbackImage();
        return;
      }

      final launched =
          await _instagramStoryChannel
              .invokeMethod<bool>('shareStickerToStory', {
                'backgroundImagePath': assets['backgroundPath'],
                'stickerImagePath': assets['stickerPath'],
                'attributionUrl': 'https://vibi.social/u/${widget.username}',
                'topBackgroundColor': '#121212',
                'bottomBackgroundColor': '#1E1E1E',
              }) ??
          false;

      if (!launched) {
        _showSnack('Instagram not found. Sharing as image instead.');
        await _shareInstagramFallbackImage();
      }
    } on MissingPluginException {
      await _shareInstagramFallbackImage();
    } catch (_) {
      _showSnack('Could not open Instagram sticker mode. Shared as image.');
      await _shareInstagramFallbackImage();
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /**
   * Shows lightweight user feedback using snackbars.
   *
   * Takes:
   * - message text.
   *
   * Returns:
   * - void.
   *
   * Used for:
   * - Informing user about share fallbacks/errors.
   */
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /**
   * Builds full share-answer composer screen.
   *
   * Takes:
   * - build context.
   *
   * Returns:
   * - Scaffold with top bar, preview, and controls sections.
   *
   * Used for:
   * - End-to-end answer sharing UX.
   */
  @override
  Widget build(BuildContext context) {
    final selectedPreset = shareBackgroundPresets[_bgPresetIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            ShareStoryTopBar(
              onBack: () => Navigator.of(context).pop(true),
              onPickImage: _pickImage,
            ),
            Expanded(
              child: ShareStoryPreview(
                screenshotController: _screenshotController,
                backgroundController: _backgroundController,
                stickerController: _stickerController,
                isCapturing: _isCapturing,
                galleryImage: _galleryImage,
                backgroundPreset: selectedPreset,
                cardColor: _cardColor,
                cardIsBright: _cardIsBright,
                questionText: widget.questionText,
                answerText: widget.answerText,
                username: widget.username,
                isAnonymous: widget.isAnonymous,
              ),
            ),
            ShareStoryControls(
              backgroundPresets: shareBackgroundPresets,
              cardColors: shareCardColors,
              galleryImage: _galleryImage,
              selectedBackgroundIndex: _bgPresetIndex,
              selectedCardColorIndex: _cardColorIndex,
              isSharing: _isSharing,
              onBackgroundSelected: _selectBackground,
              onCardColorSelected: _selectCardColor,
              onSave: () => _share(text: 'Save my ViBi answer'),
              onInstagram: _shareToInstagramStory,
            ),
          ],
        ),
      ),
    );
  }
}
