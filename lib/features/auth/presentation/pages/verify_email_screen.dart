import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_scaffold.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail.isNotEmpty) {
      _emailController.text = widget.initialEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthActionCubit>().state;
    final user = context.watch<AuthCubit>().currentUser;

    final hasSession = user != null;
    final email = user?.email ?? '';
    final initialEmail = widget.initialEmail.trim();
    final resolvedEmail = email.isNotEmpty
        ? email
        : (initialEmail.isNotEmpty
              ? initialEmail
              : _emailController.text.trim());
    final showEmailField = !hasSession && initialEmail.isEmpty;

    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSizes.s48),
          AuthHeader(
            leading: Image.asset(AppAssets.Newlogo, width: 100, height: 100),
            title: 'Verify Your Email',
            subtitle: resolvedEmail.isNotEmpty
                ? 'We sent an 8-digit verification code to\n$resolvedEmail'
                : 'Enter the email you signed up with and the 8-digit code we sent.',
          ),

          if (showEmailField) ...[
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: AppSizes.s24),

          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: const InputDecoration(
              hintText: '00000000',
              counterText: '',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: AppSizes.s32),

          if (authState is AuthActionLoading)
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            )
          else ...[
            ElevatedButton(
              onPressed: () {
                if (resolvedEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email address.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                if (_otpController.text.length != 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 8-digit code.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                context.read<AuthActionCubit>().verifyOtp(
                  resolvedEmail,
                  _otpController.text,
                  AuthOtpType.signup,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Verify Email'),
            ),
            const SizedBox(height: AppSizes.s12),
            if (hasSession) ...[
              OutlinedButton(
                onPressed: () =>
                    context.read<AuthActionCubit>().sendEmailVerification(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Resend Code'),
              ),
              const SizedBox(height: AppSizes.s12),
              TextButton(
                onPressed: () => context.read<AuthActionCubit>().signOut(),
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ] else ...[
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Go to Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],

          AuthErrorText(
            message: authState is AuthActionFailure ? authState.message : null,
          ),
        ],
      ),
    );
  }
}
