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
import 'package:vibi/features/auth/presentation/widgets/password_text_field.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;

  const SetNewPasswordScreen({super.key, required this.email});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

enum _ResetAction { verify, update, resend }

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  bool _isOtpVerified = false;
  String _verifiedOtp = '';
  _ResetAction? _pendingAction;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_handleOtpChange);
  }

  @override
  void dispose() {
    _otpController.removeListener(_handleOtpChange);
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleOtpChange() {
    final currentOtp = _otpController.text.trim();
    if (_isOtpVerified && currentOtp != _verifiedOtp) {
      setState(() {
        _isOtpVerified = false;
        _verifiedOtp = '';
      });
    }
  }

  void _verifyCode() {
    if (_otpController.text.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 8-digit verification code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _submitted = true;
      _pendingAction = _ResetAction.verify;
    });
    context.read<PasswordResetCubit>().verifyResetOtp(
      widget.email,
      _otpController.text.trim(),
    );
  }

  void _updatePassword() {
    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verify the code before updating your password.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitted = true;
      _pendingAction = _ResetAction.update;
    });
    context.read<PasswordResetCubit>().updatePassword(
      _passwordController.text.trim(),
    );
  }

  void _resendCode() {
    final email = widget.email.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing email address. Please go back and try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _submitted = true;
      _pendingAction = _ResetAction.resend;
      _isOtpVerified = false;
      _verifiedOtp = '';
    });
    context.read<PasswordResetCubit>().sendResetEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<PasswordResetCubit>().state;
    final canEditPassword = _isOtpVerified;

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
          final action = _pendingAction;
          setState(() {
            _submitted = false;
            _pendingAction = null;
            if (action == _ResetAction.verify) {
              _isOtpVerified = true;
              _verifiedOtp = _otpController.text.trim();
            }
          });
          if (action == null) {
            return;
          }
          if (action == _ResetAction.verify) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code verified. You can update your password.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          if (action == _ResetAction.resend) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Code resent to ${widget.email}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/home');
        }
      },
      child: AuthScaffold(
        title: 'Set New Password',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.s56),
            AuthHeader(
              leading: Image.asset(AppAssets.Newlogo, width: 100, height: 100),
              title: 'Create New Password',
              subtitle:
                  'Your new password must be different from previously used passwords.',
            ),
            const SizedBox(height: AppSizes.s48),

            AuthFormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8),
                      decoration: InputDecoration(
                        hintText: '00000000',
                        counterText: '',
                        labelText: 'Verification Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _verifyCode,
                        child: const Text('Verify Code'),
                      ),
                    ),
                    if (_isOtpVerified) ...[
                      const SizedBox(height: AppSizes.s12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSizes.s8),
                          Text(
                            'Code verified',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text('Resend Code'),
                    ),
                    const SizedBox(height: AppSizes.s24),
                    if (!canEditPassword)
                      Text(
                        'Verify the code to unlock password fields.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: AppSizes.s12),
                    Opacity(
                      opacity: canEditPassword ? 1 : 0.5,
                      child: AbsorbPointer(
                        absorbing: !canEditPassword,
                        child: Column(
                          children: [
                            PasswordTextField(
                              controller: _passwordController,
                              labelText: 'New Password',
                              validator: AuthValidators.password,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSizes.s16),
                            PasswordTextField(
                              controller: _confirmController,
                              labelText: 'Confirm New Password',
                              validator: (val) =>
                                  AuthValidators.confirmPassword(
                                    val,
                                    _passwordController.text,
                                  ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _updatePassword(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.s48),

            AuthPrimaryButton(
              label: 'Update Password',
              isLoading: authState is AuthActionLoading,
              onPressed: _isOtpVerified ? _updatePassword : null,
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
