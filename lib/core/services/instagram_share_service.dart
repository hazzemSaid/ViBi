import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/inbox/presentation/widgets/answer_share_card.dart';

/// Captures a branded [AnswerShareCard] and opens the platform share sheet.
/// From there the user can pick Instagram Stories, WhatsApp, or any other app.
class InstagramShareService {
  static Future<void> showShareSheet(
    BuildContext context, {
    required String questionText,
    required String answerText,
    required String username,
    bool isAnonymous = false,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ShareSheet(
        questionText: questionText,
        answerText: answerText,
        username: username,
        isAnonymous: isAnonymous,
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  final String questionText;
  final String answerText;
  final String username;
  final bool isAnonymous;

  const _ShareSheet({
    required this.questionText,
    required this.answerText,
    required this.username,
    required this.isAnonymous,
  });

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  ShareCardTemplate _selectedTemplate = ShareCardTemplate.neonPulse;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      // Higher pixel ratio keeps text crisp when posted to Stories.
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image == null) {
        _showError('Could not capture the card. Please try again.');
        setState(() => _isSharing = false);
        return;
      }

      // Write to a temp file so share_plus can pass it to Instagram / other apps
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/vibi_answer_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(filePath).writeAsBytes(image);

      final result = await Share.shareXFiles([
        XFile(filePath, mimeType: 'image/png'),
      ], text: 'Check out my answer on ViBi — vibi.social');

      if (mounted) {
        if (result.status == ShareResultStatus.success ||
            result.status == ShareResultStatus.dismissed) {
          Navigator.of(context).pop();
        } else {
          setState(() => _isSharing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Something went wrong. Please try again.');
        setState(() => _isSharing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share your Answer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a style first, then share it to Instagram Stories or any app',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose your template',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedTemplate.subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 172,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ShareCardTemplate.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final template = ShareCardTemplate.values[index];
                        final isSelected = template == _selectedTemplate;

                        return GestureDetector(
                          onTap: _isSharing
                              ? null
                              : () => setState(() => _selectedTemplate = template),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 132,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.14)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.06),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ColoredBox(
                                      color: Colors.black,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        child: SizedBox(
                                          width: AnswerShareCard.storyWidth,
                                          height: AnswerShareCard.storyHeight,
                                          child: IgnorePointer(
                                            child: AnswerShareCard(
                                              questionText: widget.questionText,
                                              answerText: widget.answerText,
                                              username: widget.username,
                                              isAnonymous: widget.isAnonymous,
                                              template: template,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  template.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card preview (this is what gets captured)
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: AnswerShareCard(
                  questionText: widget.questionText,
                  answerText: widget.answerText,
                  username: widget.username,
                  isAnonymous: widget.isAnonymous,
                  template: _selectedTemplate,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Share button
            ElevatedButton.icon(
              onPressed: _isSharing ? null : _share,
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.ios_share_rounded, size: 20),
              label: Text(
                _isSharing ? 'Preparing…' : 'Share',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                // Instagram gradient start color
                backgroundColor: const Color(0xFFE1306C),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Skip button
            TextButton(
              onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
