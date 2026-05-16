import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';
import 'package:vibi/features/auth/presentation/helpers/auth_validators.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_video_background.dart';
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
          context.go('/verify-email');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: AuthVideoBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s32),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Join ViBi and start your journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.s24),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppSizes.r24),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                          ),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: AuthValidators.email,
                              ),
                              const SizedBox(height: 16),
                              PasswordTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                validator: AuthValidators.password,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
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
                    ),

                    const SizedBox(height: 48),

                    if (authState is AuthActionLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.r16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _submit,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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

                    if (authState is AuthActionFailure)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.s16),
                        child: Text(
                          authState.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
