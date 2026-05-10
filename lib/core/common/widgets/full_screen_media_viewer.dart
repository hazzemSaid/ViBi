import 'package:flutter/material.dart';

class FullScreenMediaViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenMediaViewer({super.key, required this.imageUrl});

  static Future<void> show(BuildContext context, String imageUrl) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black,
      builder: (_) => FullScreenMediaViewer(imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 48,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
        ),
      ],
    );
  }
}
