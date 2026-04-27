import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/constants/question_filter_enum.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/presentation/helpers/inbox_helpers.dart';
import 'package:vibi/features/inbox/presentation/view/screens/answer_screen.dart';
import 'package:vibi/features/inbox/presentation/view/widgets/inbox_widgets.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/answer_question_cubit/answer_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/archive_question_cubit/archive_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/archive_question_cubit/archive_question_state.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/delete_question_cubit/delete_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/pending_questions_cubit/pending_questions_cubit.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/pending_questions_cubit/pending_questions_state.dart';

/**
 * Main inbox screen that lists pending questions and reply actions.
 *
 * Takes:
 * - no constructor arguments.
 *
 * Returns:
 * - Filterable list UI with answer and delete flows.
 *
 * Used for:
 * - Primary inbox entry point in social messaging journey.
 */
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

/**
 * State class for managing inbox screen UI and interactions.
 *
 * Takes:
 * - no constructor arguments (uses dependency injection for cubits).
 *
 * Returns:
 * - Maintains filter state, hidden/deleting/archiving question sets, and cubit references.
 *
 * Used for:
 * - Orchestrating inbox screen behavior and state management.
 */
class _InboxScreenState extends State<InboxScreen> {
  QuestionFilter _selectedFilter = QuestionFilter.all;
  final Set<String> _hiddenQuestionIds = <String>{};
  final Set<String> _deletingQuestionIds = <String>{};
  final Set<String> _archivingQuestionIds = <String>{};
  late final PendingQuestionsCubit _pendingQuestionsCubit;
  late final DeleteQuestionCubit _deleteQuestionCubit;
  late final ArchiveQuestionCubit _archiveQuestionCubit;

  @override
  void initState() {
    super.initState();
    _pendingQuestionsCubit = getIt<PendingQuestionsCubit>();
    _deleteQuestionCubit = getIt<DeleteQuestionCubit>();
    _archiveQuestionCubit = getIt<ArchiveQuestionCubit>();
    _pendingQuestionsCubit.loadAllQuestions();
  }

  @override
  void dispose() {
    _pendingQuestionsCubit.close();
    _deleteQuestionCubit.close();
    _archiveQuestionCubit.close();
    super.dispose();
  }

  /**
   * Handles filter tab selection with in-memory filtering only.
   *
   * Takes:
   * - build context and selected QuestionFilter.
   *
   * Returns:
   * - void; updates filter state and filters existing questions in memory.
   *
   * Used for:
   * - Updating displayed questions based on user-selected filter without refetching.
   */
  void _onFilterSelected(BuildContext context, QuestionFilter filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _hiddenQuestionIds.clear();
    });
  }

  /**
   * Opens reply composer for the selected question.
   *
   * Takes:
   * - outer build context and selected InboxQuestion.
   *
   * Returns:
   * - void; pushes modal route with slide transition.
   *
   * Used for:
   * - Launching AnswerScreen from inbox cards.
   */
  void _showAnswerModal(BuildContext outerContext, InboxQuestion question) {
    final pendingCubit = outerContext.read<PendingQuestionsCubit>();
    final answerCubit = getIt<AnswerQuestionCubit>();

    Navigator.of(outerContext).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: pendingCubit),
            BlocProvider.value(value: answerCubit),
          ],
          child: AnswerScreen(
            questionId: question.id,
            questionText: question.questionText,
            isAnonymous: question.isAnonymous,
            questionType: question.questionType,
            mediaRec: question.mediaRec,
          ),
        ),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  /**
   * Confirms and deletes one pending question.
   *
   * Takes:
   * - build context and target question id.
   *
   * Returns:
   * - Future completing after delete request and UI feedback.
   *
   * Used for:
   * - Inbox moderation/removal workflow.
   */
  Future<void> _deleteQuestion(BuildContext context, String questionId) async {
    if (_deletingQuestionIds.contains(questionId)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete Question',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this question? This action cannot be undone.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
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

    setState(() => _deletingQuestionIds.add(questionId));

    final deleteQuestionCubit = context.read<DeleteQuestionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await deleteQuestionCubit.deleteQuestion(questionId);
    if (!mounted) return;

    final state = deleteQuestionCubit.state;
    if (!state.hasError) {
      setState(() => _deletingQuestionIds.remove(questionId));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Question deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _deletingQuestionIds.remove(questionId);
        _hiddenQuestionIds.remove(questionId);
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to delete question'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /**
   * Archives one pending question with optimistic UI and rollback on failure.
   *
   * Takes:
   * - build context and target question id.
   *
   * Returns:
   * - Future completing after archive request and UI feedback.
   *
   * Used for:
   * - Archive action in each inbox question card.
   */
  Future<void> _archiveQuestion(BuildContext context, String questionId) async {
    if (_hiddenQuestionIds.contains(questionId) ||
        _archivingQuestionIds.contains(questionId))
      return;

    setState(() {
      _hiddenQuestionIds.add(questionId);
      _archivingQuestionIds.add(questionId);
    });

    final archiveCubit = context.read<ArchiveQuestionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await archiveCubit.archiveQuestion(questionId);
    if (!mounted) return;

    final state = archiveCubit.state;
    setState(() => _archivingQuestionIds.remove(questionId));

    if (state is ArchiveQuestionSuccess) {
      // Update in-memory without recall
      context.read<PendingQuestionsCubit>().updateQuestionStatus(
        questionId,
        'archived',
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Question archived'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _hiddenQuestionIds.remove(questionId));
    final message = state is ArchiveQuestionFailure
        ? state.message
        : 'Failed to archive question';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /**
   * Unarchives one question and moves it back to pending.
   *
   * Takes:
   * - build context and target question id.
   *
   * Returns:
   * - Future completing after unarchive request and UI feedback.
   *
   * Used for:
   * - Restoring archived questions to pending list.
   */
  Future<void> _unarchiveQuestion(
    BuildContext context,
    String questionId,
  ) async {
    if (_archivingQuestionIds.contains(questionId)) return;

    setState(() => _archivingQuestionIds.add(questionId));

    final archiveCubit = context.read<ArchiveQuestionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await archiveCubit.unarchiveQuestion(questionId);
    if (!mounted) return;

    final state = archiveCubit.state;
    setState(() => _archivingQuestionIds.remove(questionId));

    if (state is ArchiveQuestionSuccess) {
      await context.read<PendingQuestionsCubit>().loadUnansweredQuestions();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Moved back to pending'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final message = state is ArchiveQuestionFailure
        ? state.message
        : 'Failed to move question to pending';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /**
   * Builds inbox page with state-driven list sections.
   *
   * Takes:
   * - build context.
   *
   * Returns:
   * - Scaffold containing top bar, share card, and question cards with theming and responsiveness.
   *
   * Used for:
   * - Rendering loading, error, empty, and success inbox states with proper theming.
   */
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _pendingQuestionsCubit),
        BlocProvider.value(value: _deleteQuestionCubit),
        BlocProvider.value(value: _archiveQuestionCubit),
      ],
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: BlocBuilder<PendingQuestionsCubit, PendingQuestionsState>(
            builder: (context, questionsState) {
              if (questionsState is PendingQuestionsLoading ||
                  questionsState is PendingQuestionsInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (questionsState is PendingQuestionsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      SizedBox(height: AppSizes.r16),
                      Text(
                        'Failed to load questions',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSizes.r12),
                      Text(
                        questionsState.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSizes.r16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<PendingQuestionsCubit>().refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (questionsState is! PendingQuestionsSuccess)
                return const SizedBox.shrink();

              final filteredQuestions = filterQuestions(
                questionsState.questions,
                _selectedFilter,
              ).where((q) => !_hiddenQuestionIds.contains(q.id)).toList();
              final showShareCard = _selectedFilter != QuestionFilter.archived;
              final listStart = showShareCard ? 2 : 1;

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentAfter < 500 &&
                      !questionsState.isLoadingMore &&
                      questionsState.hasMore) {
                    context.read<PendingQuestionsCubit>().loadMoreQuestions();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: () async {
                    _hiddenQuestionIds.clear();
                    await context.read<PendingQuestionsCubit>().refresh();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.r16,
                      AppSizes.s8,
                      AppSizes.r16,
                      AppSizes.r24,
                    ),
                    itemCount:
                        listStart +
                        (filteredQuestions.isEmpty
                            ? 1
                            : filteredQuestions.length) +
                        (questionsState.isLoadingMore ? 1 : 0) +
                        (!questionsState.hasMore && filteredQuestions.isNotEmpty
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return InboxTopBar(
                          totalQuestions: questionsState.questions
                              .map((q) => q.status)
                              .where(
                                (status) =>
                                    isNotAnsweredStatus(status) &&
                                    !isArchivedStatus(status),
                              )
                              .length,
                          selectedFilter: _selectedFilter,
                          onFilterSelected: _onFilterSelected,
                          filterQuestionsCount: filterQuestionsCount,
                        );
                      }

                      if (showShareCard && index == 1) {
                        return ShareCard(
                          shareProfileUrl: shareProfileUrl,
                          onCopyProfileLink: () => copyProfileLink(context),
                        );
                      }

                      final questionEnd =
                          listStart +
                          (filteredQuestions.isEmpty
                              ? 1
                              : filteredQuestions.length);

                      if (index < questionEnd) {
                        if (filteredQuestions.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.58,
                            child: EmptyState(selectedFilter: _selectedFilter),
                          );
                        }

                        final question = filteredQuestions[index - listStart];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.r12),
                          child: QuestionCard(
                            question: question,
                            accentColor: colorForQuestion(index),
                            onAnswer: () => _showAnswerModal(context, question),
                            onDelete: () =>
                                _deleteQuestion(context, question.id),
                            onArchive: () =>
                                _archiveQuestion(context, question.id),
                            onUnarchive: () =>
                                _unarchiveQuestion(context, question.id),
                            deletingQuestionIds: _deletingQuestionIds,
                            archivingQuestionIds: _archivingQuestionIds,
                            selectedFilter: _selectedFilter,
                            getTimeAgo: getTimeAgo,
                          ),
                        );
                      }

                      if (questionsState.isLoadingMore &&
                          index == questionEnd) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.r16),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.r20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 44,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              SizedBox(height: AppSizes.r12),
                              Text(
                                'No more questions',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
