import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_cubit.dart';
import 'package:vibi/features/auth/presentation/widgets/auth_video_background.dart';

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
          // TODO: Add navigation or success handling
        }
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Login to your account to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

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
                              validator: (val) =>
                                  val != null && val.contains('@')
                                  ? null
                                  : 'Enter a valid email',
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                              validator: (val) => val != null && val.length >= 6
                                  ? null
                                  : 'Password must be 6+ chars',
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
                    ElevatedButton(onPressed: _submit, child: Text('Login')),

                  if (authState is AuthActionFailure)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        (authState as AuthActionFailure).message,
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
    ));
  }
}
