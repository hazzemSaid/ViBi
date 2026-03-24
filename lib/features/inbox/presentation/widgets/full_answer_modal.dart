import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/services/instagram_share_service.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/inbox/presentation/providers/inbox_providers.dart';

class FullAnswerModal extends StatefulWidget {
  final String questionId;
  final String questionText;

  const FullAnswerModal({
    super.key,
    required this.questionId,
    required this.questionText,
  });

  @override
  State<FullAnswerModal> createState() => _FullAnswerModalState();
}

class _FullAnswerModalState extends State<FullAnswerModal> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    if (!_formKey.currentState!.validate()) return;

    final answerText = _answerController.text.trim();

    await context.read<AnswerQuestionCubit>().answerQuestion(
      questionId: widget.questionId,
      answerText: answerText,
    );
    if (!mounted) return;

    await context.read<PendingQuestionsCubit>().refresh();
    if (!mounted) return;

    final state = context.read<AnswerQuestionCubit>().state;
    if (!state.hasError) {
      // Show share sheet before closing; user can skip if they prefer.
      await showShareDialog(answerText);
      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer posted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> showShareDialog(String answeredText) async {
    final user = Supabase.instance.client.auth.currentUser;
    final username =
        (user?.userMetadata?['username'] as String?)?.trim() ??
        user?.email?.split('@').first ??
        'me';

    if (!mounted) return;
    await InstagramShareService.showShareSheet(
      context,
      questionText: widget.questionText,
      answerText: answeredText,
      username: username,
    );
  }

  @override
  Widget build(BuildContext context) {
    final answerState = context.watch<AnswerQuestionCubit>().state;
    final isLoading = answerState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.r24),
          topRight: Radius.circular(AppSizes.r24),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.r20,
        right: AppSizes.r20,
        top: AppSizes.r20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.r20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.r20),

                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Answer Question',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
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

                // Question Text
                Container(
                  padding: EdgeInsets.all(AppSizes.r12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    widget.questionText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.r16),

                // Answer TextField
                TextFormField(
                  controller: _answerController,
                  maxLines: 8,
                  maxLength: 5000,
                  enabled: !isLoading,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Write your answer...',
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
                      return 'Please enter an answer';
                    }
                    if (value.trim().length < 1) {
                      return 'Answer must be at least 1 character';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.r16),

                // Error Message
                if (answerState.hasError)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSizes.r12),
                    child: Text(
                      'Failed to post answer. Please try again.',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Submit Button
                ElevatedButton(
                  onPressed: isLoading ? null : _submitAnswer,
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
                          'Post Answer',
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
      ),
    );
  }
}
