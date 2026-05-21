import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';
import 'package:vibi/features/auth/presentation/helpers/auth_validators.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_button.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:vibi/features/auth/presentation/widgets/password_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  String _submittedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitted = true);
      final email = _emailController.text.trim();
      final nameFromEmail = email.split('@').first;
      _submittedEmail = email;

      context.read<AuthActionCubit>().signUpWithEmail(
        email,
        _passwordController.text.trim(),
        data: {'full_name': nameFromEmail},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthActionCubit>().state;

    return BlocListener<AuthActionCubit, AuthActionState>(
      listener: (context, state) {
        if (!_submitted) return;
        if (state is AuthActionLoading) return;
        if (state is AuthActionFailure) {
          setState(() => _submitted = false);
          return;
        }
        if (state is AuthActionSuccess) {
          setState(() => _submitted = false);
          final email = _submittedEmail.isNotEmpty
              ? _submittedEmail
              : _emailController.text.trim();
          context.go('/verify-email', extra: {'email': email});
        }
      },
      child: AuthScaffold(
        title: 'Sign Up',
        showBackButton: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.s20),
            AuthHeader(
              title: 'Create Account',
              titleFontSize: 32,
              subtitle: 'Join ViBi and start your journey',
            ),
            const SizedBox(height: AppSizes.s40),

            AuthFormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: AppSizes.s16),
                    PasswordTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      validator: AuthValidators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.s16),
                    PasswordTextField(
                      controller: _confirmController,
                      labelText: 'Confirm Password',
                      validator: (val) => AuthValidators.confirmPassword(
                        val,
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.s48),

            AuthPrimaryButton(
              label: 'Create Account',
              isLoading: authState is AuthActionLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: AppSizes.s12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Already have an account? Log In',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            AuthErrorText(
              message: authState is AuthActionFailure
                  ? authState.message
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
