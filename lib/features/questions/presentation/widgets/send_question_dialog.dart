import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/questions/presentation/providers/question_providers.dart';
import 'package:vibi/features/questions/presentation/providers/question_state.dart';
import 'package:vibi/features/recommendation/presentation/screens/recommend_search_screen.dart';

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
  late final SendQuestionCubit _sendQuestionCubit;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _sendQuestionCubit = getIt<SendQuestionCubit>();
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
            content: Text('Question sent successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    }
  }

  Future<void> _openRecommendationSheet() async {
    final didSend = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RecommendSearchScreen(
          recipientId: widget.recipientId,
          initialAnonymous: _isAnonymous,
        ),
      ),
    );

    if (!mounted || didSend != true) return;
    Navigator.of(context).pop();
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
                                color: Theme.of(context).colorScheme.onSurface,
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

                    OutlinedButton.icon(
                      onPressed: isLoading ? null : _openRecommendationSheet,
                      icon: const Icon(Icons.movie_creation_outlined),
                      label: const Text('Recommend Movie/TV'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.16),
                        ),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.r12),

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
                          : Text(
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
