import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_assets.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:vibi/features/auth/presentation/helpers/auth_validators.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_button.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitted = true);
      context.read<PasswordResetCubit>().sendResetEmail(
        _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<PasswordResetCubit>().state;

    return BlocListener<PasswordResetCubit, AuthActionState>(
      listener: (context, state) {
        if (!_submitted) return;
        if (state is AuthActionLoading) return;
        if (state is AuthActionFailure) {
          setState(() => _submitted = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        if (state is AuthActionSuccess) {
          setState(() => _submitted = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code sent to ${_emailController.text}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(
            '/set-new-password',
            extra: {'email': _emailController.text},
          );
        }
      },
      child: AuthScaffold(
        title: 'Reset Password',
        showBackButton: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.s56),
            AuthHeader(
              leading: Image.asset(AppAssets.Newlogo, width: 80, height: 80),
              title: 'Forgot Your Password?',
              subtitle: 'Enter your email and we will send an 8-digit code.',
            ),
            const SizedBox(height: AppSizes.s48),

            AuthFormCard(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.email,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.s48),

            AuthPrimaryButton(
              label: 'Send Code',
              isLoading: authState is AuthActionLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: AppSizes.s16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            AuthErrorText(
              message: authState is AuthActionFailure && !_submitted
                  ? authState.message
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
