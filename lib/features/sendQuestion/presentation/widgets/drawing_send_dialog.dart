import 'package:flutter/material.dart';

/**
 * Confirmation dialog shown before sending a drawing.
 *
 * Offers three choices: cancel, send as self (named), or send anonymously.
 * Returns `null` on cancel, `false` for named send, `true` for anonymous.
 */
class DrawingSendDialog extends StatelessWidget {
  const DrawingSendDialog({super.key, this.initialAnonymous = false});

  final bool initialAnonymous;

  static Future<bool?> show(
    BuildContext context, {
    bool initialAnonymous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DrawingSendDialog(initialAnonymous: initialAnonymous),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryAnonymous = initialAnonymous;

    return AlertDialog(
      title: const Text('Send Drawing'),
      content: const Text('How would you like to send this drawing?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        if (primaryAnonymous) ...[
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('Send as me'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.visibility_off_rounded),
            label: const Text('Send anonymously'),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.visibility_off_rounded),
            label: const Text('Send anonymously'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('Send as me'),
          ),
        ],
      ],
    );
  }
}
