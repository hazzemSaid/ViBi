import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/questions/presentation/providers/question_providers.dart';

class SendQuestionDialog extends StatefulWidget {
  final String recipientId;
  final String recipientUsername;

  const SendQuestionDialog({
    super.key,
    required this.recipientId,
    required this.recipientUsername,
  });

  @override
  State<SendQuestionDialog> createState() => _SendQuestionDialogState();
}

class _SendQuestionDialogState extends State<SendQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final questionText = _questionController.text.trim();
    final cubit = context.read<SendQuestionCubit>();

    await cubit.sendQuestion(
      recipientId: widget.recipientId,
      questionText: questionText,
      isAnonymous: _isAnonymous,
    );

    if (mounted) {
      final state = cubit.state;
      if (!state.hasError) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SendQuestionCubit>(),
      child: BlocBuilder<SendQuestionCubit, ViewState<void>>(
        builder: (context, sendState) {
          final isLoading = sendState.isLoading;

          return Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r20),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.r20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ask @${widget.recipientUsername}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.r16),

                    // Question TextField
                    TextFormField(
                      controller: _questionController,
                      maxLines: 5,
                      maxLength: 1000,
                      enabled: !isLoading,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          borderSide: BorderSide.none,
                        ),
                        counterStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a question';
                        }
                        if (value.trim().length < 1) {
                          return 'Question must be at least 1 character';
                        }
                        if (value.trim().length > 1000) {
                          return 'Question must be less than 1000 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.r16),

                    // Anonymous Switch
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.r12,
                        vertical: AppSizes.r12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility_off,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: AppSizes.r12),
                          const Expanded(
                            child: Text(
                              'Ask anonymously',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isAnonymous,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _isAnonymous = value;
                                    });
                                  },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.r20),

                    // Error Message
                    if (sendState.hasError)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.r12),
                        child: Text(
                          'Failed to send question. Please try again.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Send Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _sendQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSizes.r16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Send Question',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
