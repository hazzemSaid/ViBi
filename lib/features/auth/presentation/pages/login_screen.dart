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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthActionCubit>().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthActionCubit>().state;

    return BlocListener<AuthActionCubit, AuthActionState>(
      listener: (context, state) {
        if (state is AuthActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AuthScaffold(
        title: 'Login',
        showBackButton: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.s40),
            AuthHeader(
              title: 'Welcome Back',
              titleFontSize: 32,
              subtitle: 'Login to your account to continue',
            ),
            const SizedBox(height: AppSizes.s48),

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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.s12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.s24),

            AuthPrimaryButton(
              label: 'Login',
              isLoading: authState is AuthActionLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: AppSizes.s12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                "Don't have an account? Sign Up",
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
