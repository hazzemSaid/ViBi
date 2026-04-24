import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/providers/auth_providers.dart';

/// Handles two states:
/// 1. **Session exists, email unconfirmed** — user signed up & Supabase
///    auto-created a session (auto-confirm OFF but OTP flow or similar).
///    Shows resend + "I've verified" (refreshes session).
/// 2. **No session** — Supabase email-confirmation is ON and the user must
///    click the link in their inbox before a session is created.
///    Shows instructions + "Go to Login after verifying".
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthController>().state;
    final user = context.watch<AuthCubit>().currentUser;

    // If the user becomes verified (session updated), router redirects to /home.
    final hasSession = user != null;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: hasSession
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => context.go('/welcome'),
              ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Check Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  hasSession
                      ? 'We sent a confirmation link to\n$email'
                      : 'A confirmation link was sent to your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Click the link in your email to verify your account, then tap the button below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

SizedBox(height: 48),

                if (authState is AuthActionLoading)
                  CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)
                else if (hasSession) ...[
                  // Case 1: session exists — can refresh to pick up confirmation
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AuthController>().reloadUser(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text("I've Verified My Email"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        context.read<AuthController>().sendEmailVerification(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(52),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Resend Confirmation Email'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<AuthController>().signOut(),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ] else ...[
                  // Case 2: no session yet — user must click link then sign in
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text('Sign In After Verifying'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/welcome'),
                    child: Text(
                      'Back to Welcome',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],

                if (authState is AuthActionFailure)
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      (authState as AuthActionFailure).message,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



