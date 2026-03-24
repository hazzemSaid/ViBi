import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/presentation/providers/inbox_providers.dart';
import 'package:vibi/features/inbox/presentation/widgets/full_answer_modal.dart';
import 'package:vibi/features/inbox/presentation/widgets/inbox_question_card.dart';

enum QuestionFilter { all, fromUsers, anonymous }

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  QuestionFilter _selectedFilter = QuestionFilter.all;

  List<InboxQuestion> _filterQuestions(List<InboxQuestion> questions) {
    switch (_selectedFilter) {
      case QuestionFilter.all:
        return questions;
      case QuestionFilter.fromUsers:
        return questions.where((q) => q.isFromUser).toList();
      case QuestionFilter.anonymous:
        return questions.where((q) => q.isAnonymous).toList();
    }
  }

  void _showAnswerModal(InboxQuestion question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PendingQuestionsCubit>()),
          BlocProvider(create: (_) => getIt<AnswerQuestionCubit>()),
        ],
        child: FullAnswerModal(
          questionId: question.id,
          questionText: question.questionText,
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(String questionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Question',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this question? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<DeleteQuestionCubit>().deleteQuestion(questionId);
    if (!mounted) return;

    await context.read<PendingQuestionsCubit>().refresh();
    if (!mounted) return;

    final state = context.read<DeleteQuestionCubit>().state;
    if (!state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete question'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PendingQuestionsCubit>()),
        BlocProvider(create: (_) => getIt<DeleteQuestionCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Inbox',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter Chips
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.r16,
                vertical: AppSizes.r12,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == QuestionFilter.all,
                      onTap: () {
                        setState(() {
                          _selectedFilter = QuestionFilter.all;
                        });
                      },
                    ),
                    SizedBox(width: AppSizes.r12),
                    _buildFilterChip(
                      label: 'From Users',
                      isSelected: _selectedFilter == QuestionFilter.fromUsers,
                      onTap: () {
                        setState(() {
                          _selectedFilter = QuestionFilter.fromUsers;
                        });
                      },
                    ),
                    SizedBox(width: AppSizes.r12),
                    _buildFilterChip(
                      label: 'Anonymous',
                      isSelected: _selectedFilter == QuestionFilter.anonymous,
                      onTap: () {
                        setState(() {
                          _selectedFilter = QuestionFilter.anonymous;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Questions List
            Expanded(
              child:
                  BlocBuilder<
                    PendingQuestionsCubit,
                    ViewState<List<InboxQuestion>>
                  >(
                    builder: (context, questionsAsync) {
                      if (questionsAsync.status == ViewStatus.success) {
                        final questions = questionsAsync.data ?? [];
                        final filteredQuestions = _filterQuestions(questions);

                        if (filteredQuestions.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<PendingQuestionsCubit>()
                                .refresh();
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.all(AppSizes.r12),
                            itemCount: filteredQuestions.length,
                            itemBuilder: (context, index) {
                              final question = filteredQuestions[index];
                              return InboxQuestionCard(
                                question: question,
                                onAnswer: () => _showAnswerModal(question),
                                onDelete: () => _deleteQuestion(question.id),
                              );
                            },
                          ),
                        );
                      }
                      if (questionsAsync.status == ViewStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(height: AppSizes.r16),
                            Text(
                              'Failed to load questions',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: AppSizes.r12),
                            Text(
                              questionsAsync.errorMessage ?? 'Unknown error',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSizes.r16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PendingQuestionsCubit>().refresh();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.r16,
          vertical: AppSizes.r12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.r20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_selectedFilter) {
      case QuestionFilter.all:
        message = 'No questions yet';
        break;
      case QuestionFilter.fromUsers:
        message = 'No questions from users';
        break;
      case QuestionFilter.anonymous:
        message = 'No anonymous questions';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.r24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSizes.r24),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.r12),
          Text(
            _selectedFilter == QuestionFilter.all
                ? 'Questions sent to you will appear here'
                : 'Try selecting a different filter',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
