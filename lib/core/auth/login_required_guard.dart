import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_cubit.dart';

class LoginRequiredGuard {
  const LoginRequiredGuard._();

  static bool isGuest(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    return user == null || user.isAnonymous;
  }

  static Future<bool> ensureLoggedIn(
    BuildContext context, {
    String message = 'You need to login first to do this.',
  }) async {
    if (!isGuest(context)) return true;
    await showLoginRequiredAlert(context, message: message);
    return false;
  }

  static Future<void> showLoginRequiredAlert(
    BuildContext context, {
    String message = 'You need to login first to do this.',
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Login required',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            message,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/login');
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }
}
