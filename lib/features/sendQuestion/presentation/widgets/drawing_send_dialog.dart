import 'package:flutter/material.dart';

/**
 * Confirmation dialog shown before sending a drawing.
 *
 * Offers three choices: cancel, send as self (named), or send anonymously.
 * Returns `null` on cancel, `false` for named send, `true` for anonymous.
 */
class DrawingSendDialog extends StatelessWidget {
  const DrawingSendDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DrawingSendDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Drawing'),
      content: const Text('How would you like to send this drawing?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Send as Myself'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Send Anonymously'),
        ),
      ],
    );
  }
}
