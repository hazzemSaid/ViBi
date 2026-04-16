import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/theme/app_colors.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/presentation/cubits/answer_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/archive_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/delete_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/pending_questions_cubit.dart';
import 'package:vibi/features/inbox/presentation/screens/answer_screen.dart';
import 'package:vibi/features/inbox/presentation/state/archive_question_state.dart';
import 'package:vibi/features/inbox/presentation/state/pending_questions_state.dart';

/**
 * Available filters for pending inbox questions.
 *
 * Takes:
 * - enum selection from tabs.
 *
 * Returns:
 * - Filter mode applied to pending question list.
 *
 * Used for:
 * - Segmenting all, anonymous, and friend/user questions.
 */
enum QuestionFilter { all, fromUsers, anonymous, archived }

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

class _InboxScreenState extends State<InboxScreen> {
  QuestionFilter _selectedFilter = QuestionFilter.all;
  final Set<String> _hiddenQuestionIds = <String>{};
  final Set<String> _deletingQuestionIds = <String>{};
  final Set<String> _archivingQuestionIds = <String>{};
  late final PendingQuestionsCubit _pendingQuestionsCubit;
  late final DeleteQuestionCubit _deleteQuestionCubit;
  late final ArchiveQuestionCubit _archiveQuestionCubit;

  static const Color _accentPink = Color(0xFFFE2C55);
  static const Color _accentPurple = Color(0xFFA855F7);
  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentOrange = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    _pendingQuestionsCubit = getIt<PendingQuestionsCubit>();
    _deleteQuestionCubit = getIt<DeleteQuestionCubit>();
    _archiveQuestionCubit = getIt<ArchiveQuestionCubit>();
  }

  @override
  void dispose() {
    _pendingQuestionsCubit.close();
    _deleteQuestionCubit.close();
    _archiveQuestionCubit.close();
    super.dispose();
  }

  bool _isArchivedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'archive' || normalized == 'archived';
  }

  bool _isNotAnsweredStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized != 'answered' && normalized != 'deleted';
  }

  /**
   * Applies current tab filter to the provided question list.
   *
   * Takes:
   * - full question list.
   *
   * Returns:
   * - Filtered list based on selected [QuestionFilter].
   *
   * Used for:
   * - Driving displayed items in inbox list view.
   */
  List<InboxQuestion> _filterQuestions(List<InboxQuestion> questions) {
    switch (_selectedFilter) {
      case QuestionFilter.all:
        return questions
            .where(
              (q) =>
                  _isNotAnsweredStatus(q.status) &&
                  !_isArchivedStatus(q.status),
            )
            .toList();
      case QuestionFilter.fromUsers:
        return questions
            .where(
              (q) =>
                  q.isFromUser &&
                  _isNotAnsweredStatus(q.status) &&
                  !_isArchivedStatus(q.status),
            )
            .toList();
      case QuestionFilter.anonymous:
        return questions
            .where(
              (q) =>
                  q.isAnonymous &&
                  _isNotAnsweredStatus(q.status) &&
                  !_isArchivedStatus(q.status),
            )
            .toList();
      case QuestionFilter.archived:
        return questions.where((q) => _isArchivedStatus(q.status)).toList();
    }
  }

  Future<void> _onFilterSelected(
    BuildContext context,
    QuestionFilter filter,
  ) async {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _hiddenQuestionIds.clear();
    });

    final pendingQuestionsCubit = context.read<PendingQuestionsCubit>();
    if (filter == QuestionFilter.archived) {
      await pendingQuestionsCubit.loadArchivedQuestions();
      return;
    }
    await pendingQuestionsCubit.loadUnansweredQuestions();
  }

  /**
   * Opens reply composer for the selected question.
   *
   * Takes:
   * - outer build context and selected [InboxQuestion].
   *
   * Returns:
   * - void; pushes modal route with slide transition.
   *
   * Used for:
   * - Launching [AnswerScreen] from inbox cards.
   */
  void _showAnswerModal(BuildContext outerContext, InboxQuestion question) {
    final pendingCubit = outerContext.read<PendingQuestionsCubit>();
    final answerCubit = getIt<AnswerQuestionCubit>();

    Navigator.of(outerContext).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: pendingCubit),
            BlocProvider.value(value: answerCubit),
          ],
          child: AnswerScreen(
            questionId: question.id,
            questionText: question.questionText,
            isAnonymous: question.isAnonymous,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) {
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
   * Copies public profile link to clipboard and confirms via snackbar.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Future completing after clipboard update and feedback.
   *
   * Used for:
   * - Share card quick-copy action.
   */
  Future<void> _copyProfileLink() async {
    final link = _shareProfileUrl;
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile link copied')));
  }

  String get _shareProfileUrl {
    final user = Supabase.instance.client.auth.currentUser;
    final rawUsername = (user?.userMetadata?['username'] as String?)?.trim();
    final username =
        rawUsername != null && rawUsername.isNotEmpty
        ? rawUsername
        : user?.email?.split('@').first ?? 'user';
    final shareBaseUrl = dotenv.env['SHARE_BASE_URL'] ?? 'https://vibi.social';
    return '$shareBaseUrl/u/$username';
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

    setState(() {
      _deletingQuestionIds.add(questionId);
    });

    final deleteQuestionCubit = context.read<DeleteQuestionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await deleteQuestionCubit.deleteQuestion(questionId);
    if (!mounted) return;

    final state = deleteQuestionCubit.state;
    if (!state.hasError) {
      if (!mounted) return;

      setState(() {
        _deletingQuestionIds.remove(questionId);
      });

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
        _archivingQuestionIds.contains(questionId)) {
      return;
    }

    setState(() {
      _hiddenQuestionIds.add(questionId);
      _archivingQuestionIds.add(questionId);
    });

    final archiveCubit = context.read<ArchiveQuestionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await archiveCubit.archiveQuestion(questionId);
    if (!mounted) return;

    final state = archiveCubit.state;
    setState(() {
      _archivingQuestionIds.remove(questionId);
    });

    if (state is ArchiveQuestionSuccess) {
      await context.read<PendingQuestionsCubit>().loadUnansweredQuestions();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Question archived'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _hiddenQuestionIds.remove(questionId);
    });

    final message = state is ArchiveQuestionFailure
        ? state.message
        : 'Failed to archive question';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _unarchiveQuestion(
    BuildContext context,
    String questionId,
  ) async {
    if (_archivingQuestionIds.contains(questionId)) return;

    setState(() {
      _archivingQuestionIds.add(questionId);
    });

    final archiveCubit = context.read<ArchiveQuestionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await archiveCubit.unarchiveQuestion(questionId);
    if (!mounted) return;

    final state = archiveCubit.state;
    setState(() {
      _archivingQuestionIds.remove(questionId);
    });

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
   * - Scaffold containing top bar, share card, and question cards.
   *
   * Used for:
   * - Rendering loading, error, empty, and success inbox states.
   */
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _pendingQuestionsCubit),
        BlocProvider.value(value: _deleteQuestionCubit),
        BlocProvider.value(value: _archiveQuestionCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                        questionsState.message,
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
              }

              if (questionsState is! PendingQuestionsSuccess) {
                return const SizedBox.shrink();
              }

              final filteredQuestions = _filterQuestions(
                questionsState.questions,
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
                        //of state padding
                        return _buildTopBar(
                          questionsState.questions
                              .map((q) => q.status)
                              .where(
                                (status) =>
                                    _isNotAnsweredStatus(status) &&
                                    !_isArchivedStatus(status),
                              )
                              .length,
                        );
                      }

                      if (showShareCard && index == 1) {
                        return _buildShareCard();
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
                            child: _buildEmptyState(),
                          );
                        }

                        final question = filteredQuestions[index - listStart];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.r12),
                          child: _buildQuestionCard(
                            onArchive: () =>
                                _archiveQuestion(context, question.id),
                            onUnarchive: () =>
                                _unarchiveQuestion(context, question.id),
                            question: question,
                            accentColor: _colorForQuestion(index),
                            onAnswer: () => _showAnswerModal(context, question),
                            onDelete: () =>
                                _deleteQuestion(context, question.id),
                          ),
                        );
                      }

                      final loadingIndex = questionEnd;
                      if (questionsState.isLoadingMore &&
                          index == loadingIndex) {
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
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: AppSizes.r12),
                              Text(
                                'No more questions',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
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

  /**
   * Builds header title and filter tabs section.
   *
   * Takes:
   * - total question count for indicator badge.
   *
   * Returns:
   * - Top bar widget for list screen.
   *
   * Used for:
   * - Displaying inbox identity and filter controls.
   */
  Widget _buildTopBar(int totalQuestions) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.r12),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Inbox',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(width: AppSizes.r12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accentPink.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.whatshot, color: _accentPink, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${_filterQuestionsCount(totalQuestions)}',
                      style: const TextStyle(
                        color: _accentPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.r12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterTab(
                    label: 'All',
                    isSelected: _selectedFilter == QuestionFilter.all,
                    count: null,
                    onTap: () => _onFilterSelected(context, QuestionFilter.all),
                  ),
                ),
                Expanded(
                  child: _buildFilterTab(
                    label: 'Anonymous',
                    isSelected: _selectedFilter == QuestionFilter.anonymous,
                    count: null,
                    onTap: () =>
                        _onFilterSelected(context, QuestionFilter.anonymous),
                  ),
                ),
                Expanded(
                  child: _buildFilterTab(
                    label: 'Friends',
                    isSelected: _selectedFilter == QuestionFilter.fromUsers,
                    count: null,
                    onTap: () =>
                        _onFilterSelected(context, QuestionFilter.fromUsers),
                  ),
                ),
                Expanded(
                  child: _buildFilterTab(
                    label: 'Archived',
                    isSelected: _selectedFilter == QuestionFilter.archived,
                    count: null,
                    onTap: () =>
                        _onFilterSelected(context, QuestionFilter.archived),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Computes displayed count for top badge.
   *
   * Takes:
   * - fallback integer count.
   *
   * Returns:
   * - Integer to render in header counter.
   *
   * Used for:
   * - Future extensibility for filtered count logic.
   */
  int _filterQuestionsCount(int fallback) {
    return fallback;
  }

  /**
   * Builds one tappable filter tab chip.
   *
   * Takes:
   * - label, selected state, tap callback, and optional count.
   *
   * Returns:
   * - Styled filter tab widget.
   *
   * Used for:
   * - Switching [QuestionFilter] from top bar.
   */
  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF7A7A7A),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /**
   * Builds share card with profile-link copy call-to-action.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Promotional card widget.
   *
   * Used for:
   * - Encouraging profile sharing to receive more messages.
   */
  Widget _buildShareCard() {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.r12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.r14,
          vertical: AppSizes.r12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withValues(alpha: 0.22),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accentPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: _accentPink,
                size: 18,
              ),
            ),
            SizedBox(width: AppSizes.r12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share to get messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _shareProfileUrl,
                    style: const TextStyle(
                      color: Color(0xFF636363),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _copyProfileLink,
              style: FilledButton.styleFrom(
                backgroundColor: _accentPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(76, 34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.copy_rounded, size: 13),
              label: const Text(
                'Copy',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * Picks a stable accent color based on card index seed.
   *
   * Takes:
   * - integer seed.
   *
   * Returns:
   * - Color from predefined accent palette.
   *
   * Used for:
   * - Visual variety across question cards.
   */
  Color _colorForQuestion(int seed) {
    final palette = <Color>[
      _accentPink,
      _accentPurple,
      _accentBlue,
      _accentGreen,
      _accentOrange,
    ];
    return palette[seed % palette.length];
  }

  /**
   * Builds one inbox question card with answer/delete actions.
   *
   * Takes:
   * - question model, accent color, answer callback, and delete callback.
   *
   * Returns:
   * - Fully styled card widget for one pending question.
   *
   * Used for:
   * - Rendering each item in the pending list.
   */
  Widget _buildQuestionCard({
    required InboxQuestion question,
    required Color accentColor,
    required VoidCallback onAnswer,
    required VoidCallback onDelete,
    required VoidCallback onArchive,
    required VoidCallback onUnarchive,
  }) {
    final timeAgo = _getTimeAgo(question.createdAt);
    final displayName = question.isAnonymous
        ? 'Anonymous'
        : '@${question.senderUsername ?? 'user'}';
    final isArchiving = _archivingQuestionIds.contains(question.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accentColor),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.r14,
              AppSizes.r14,
              AppSizes.r14,
              AppSizes.r14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: _deletingQuestionIds.contains(question.id)
                          ? const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          : question.isAnonymous
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SvgPicture.asset(
                                'assets/images/anoynemance.svg',
                                colorFilter: ColorFilter.mode(
                                  accentColor,
                                  BlendMode.srcIn,
                                ),
                                width: 35,
                                height: 35,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: question.senderAvatarUrl ?? '',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,

                              errorWidget: (_, __, ___) {
                                return Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(width: AppSizes.r12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (question.isAnonymous) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'hidden',
                                    style: TextStyle(
                                      color: Color(0xFF6D6D6D),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: AppSizes.s4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              color: Color(0xFF5D5D5D),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isArchiving
                          ? null
                          : (_selectedFilter == QuestionFilter.archived
                                ? onUnarchive
                                : onArchive),
                      icon: isArchiving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            )
                          : Icon(
                              _selectedFilter == QuestionFilter.archived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              color: const Color.fromARGB(255, 166, 165, 165),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.r12),
                Text(
                  question.questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: AppSizes.r12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAnswer,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.s8),
                    _buildIconAction(
                      icon: Icons.delete_outline,
                      onTap: onDelete,
                      color: _accentPink,
                      background: _accentPink.withValues(alpha: 0.12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Builds compact icon-only action button.
   *
   * Takes:
   * - icon, tap callback, icon color, and optional background color.
   *
   * Returns:
   * - InkWell-based icon action widget.
   *
   * Used for:
   * - Secondary actions such as delete.
   */
  Widget _buildIconAction({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    Color? background,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: background ?? Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  /**
   * Builds empty-state content according to selected filter.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Centered empty-state widget.
   *
   * Used for:
   * - Communicating no-data conditions in inbox list.
   */
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
      case QuestionFilter.archived:
        message = 'No archived questions';
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

  /**
   * Converts absolute creation time into compact relative label.
   *
   * Takes:
   * - question creation [DateTime].
   *
   * Returns:
   * - Human-readable age string (e.g., "5m ago", "2d ago").
   *
   * Used for:
   * - Metadata labels in question card headers.
   */
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    }
  }
}
