import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vibi/features/auth/presentation/controllers/auth_state.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_video_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitted = true);
      context.read<AuthController>().signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthController>().state;

    // After a successful signup, navigate to the email verification screen.
    // With Supabase email confirmation enabled, no session is created immediately
    // so the router's redirect won't fire — we navigate explicitly here.
    return BlocListener<AuthController, AuthActionState>(
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
          title: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join ViBi and start your journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Glassmorphism Form Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.all(AppSizes.s24),
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
                                controller: _nameController,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                validator: (val) =>
                                    val != null && val.isNotEmpty
                                    ? null
                                    : 'Enter your name',
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
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
                                validator: (val) =>
                                    val != null && val.contains('@')
                                    ? null
                                    : 'Enter a valid email',
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                obscureText: true,
                                validator: (val) =>
                                    val != null && val.length >= 6
                                    ? null
                                    : 'Password must be 6+ chars',
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmController,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(
                                    Icons.lock_reset,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                obscureText: true,
                                validator: (val) {
                                  if (val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
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
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('Sign Up'),
                      ),

                    if (authState is AuthActionFailure)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          authState.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
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
