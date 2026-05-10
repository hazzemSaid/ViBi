import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/sendQuestion/presentation/cubit/send_question_cubit.dart';
import 'package:vibi/features/sendQuestion/presentation/cubit/send_question_state.dart';

class SendQuestionDialog extends StatefulWidget {
  final String recipientId;
  final String recipientUsername;
  final bool initialAnonymous;
  final bool showAnonymousSwitch;

  const SendQuestionDialog({
    super.key,
    required this.recipientId,
    required this.recipientUsername,
    this.initialAnonymous = false,
    this.showAnonymousSwitch = true,
  });

  @override
  State<SendQuestionDialog> createState() => _SendQuestionDialogState();
}

class _SendQuestionDialogState extends State<SendQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  late final SendQuestionCubit _sendQuestionCubit;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _sendQuestionCubit = getIt<SendQuestionCubit>();
    _isAnonymous = widget.initialAnonymous;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _sendQuestionCubit.close();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final questionText = _questionController.text.trim();
    await _sendQuestionCubit.sendQuestion(
      recipientId: widget.recipientId,
      questionText: questionText,
      isAnonymous: _isAnonymous,
    );

    if (mounted) {
      final state = _sendQuestionCubit.state;
      if (state is! SendQuestionFailure) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question sent successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendQuestionCubit>.value(
      value: _sendQuestionCubit,
      child: BlocBuilder<SendQuestionCubit, SendQuestionState>(
        builder: (context, sendState) {
          final isLoading = sendState is SendQuestionLoading;

          return Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onSurface,
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          borderSide: BorderSide.none,
                        ),
                        counterStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a question';
                        }
                        if (value.trim().length > 1000) {
                          return 'Question must be less than 1000 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.r16),

                    if (widget.showAnonymousSwitch) ...[
                      // Anonymous Switch
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.r12,
                          vertical: AppSizes.r12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_off,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            SizedBox(width: AppSizes.r12),
                            Expanded(
                              child: Text(
                                'Ask anonymously',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
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
                              activeThumbColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.r20),
                    ] else ...[
                      _buildIdentityStatus(context),
                      SizedBox(height: AppSizes.r20),
                    ],

                    // Error Message
                    if (sendState is SendQuestionFailure)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.r12),
                        child: Text(
                          'Failed to send question. Please try again.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Send Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _sendQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        padding: EdgeInsets.symmetric(vertical: AppSizes.r16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onSurface,
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

  Widget _buildIdentityStatus(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.r12,
        vertical: AppSizes.r12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Row(
        children: [
          Icon(
            _isAnonymous
                ? Icons.visibility_off_rounded
                : Icons.person_outline_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: AppSizes.r12),
          Expanded(
            child: Text(
              _isAnonymous ? 'Sending anonymously' : 'Sending as you',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
