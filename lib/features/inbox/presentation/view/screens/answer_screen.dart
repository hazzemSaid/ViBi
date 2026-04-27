import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/notifiers/answerScreenVisibilityNotifier.dart';
import 'package:vibi/features/inbox/presentation/helpers/answer_screen_helpers.dart';
import 'package:vibi/features/inbox/presentation/helpers/question_media_helpers.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/answer_question_cubit/answer_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/viewmodle/pending_questions_cubit/pending_questions_cubit.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';
import 'package:vibi/features/recommendation/presentation/widgets/media_card.dart';

/**
 * Full-screen answer composer for one inbox question.
 *
 * Takes:
 * - question id, text, and anonymity metadata.
 *
 * Returns:
 * - Screen that posts an answer and routes to share composer.
 *
 * Used for:
 * - Reply flow launched from inbox question cards.
 */
class AnswerScreen extends StatefulWidget {
  const AnswerScreen({
    super.key,
    required this.questionId,
    required this.questionText,
    this.isAnonymous = false,
    this.questionType = 'text',
    this.mediaRec,
  });

  final String questionId;
  final String questionText;
  final bool isAnonymous;
  final String questionType;
  final TmdbMedia? mediaRec;

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final _answerController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      answerScreenVisibilityNotifier.value = true;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      answerScreenVisibilityNotifier.value = false;
    });
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────

  /**
   * Indicates whether posting is currently allowed.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - true when answer text is not empty and post is not in progress.
   *
   * Used for:
   * - Post button visual/interaction state.
   */
  bool get _canPost => _answerController.text.trim().isNotEmpty && !_isPosting;

  // ── Actions ─────────────────────────────────────────────────────────

  /**
   * Posts answer, refreshes pending list, then opens share composer.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Future completing when post and navigation workflow finishes.
   *
   * Used for:
   * - Primary action behind "Post & Share" button.
   */
  Future<void> _postAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      showEmptyAnswerError(context);
      return;
    }

    setState(() => _isPosting = true);

    final answerCubit = context.read<AnswerQuestionCubit>();
    final pendingCubit = context.read<PendingQuestionsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await answerCubit.answerQuestion(
      questionId: widget.questionId,
      answerText: text,
    );
    if (!mounted) return;

    final state = answerCubit.state;
    if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to post answer. Please try again.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isPosting = false);
      return;
    }

    await pendingCubit.refresh();
    if (!mounted) return;

    setState(() => _isPosting = false);

    if (isRecommendationQuestion(widget.questionType)) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Answer posted'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    // Navigate to share screen
    final didShare = await context.pushNamed<bool>(
      'share-answer',
      extra: {
        'questionText': widget.questionText,
        'answerText': text,
        'isAnonymous': widget.isAnonymous,
        'username': getUsername(context),
      },
    );

    if (mounted) Navigator.of(context).pop(didShare ?? true);
  }

  /**
   * Closes the current answer composer route.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - void.
   *
   * Used for:
   * - Top-bar close action.
   */
  void _close() => Navigator.of(context).pop();

  // ── Build ──────────────────────────────────────────────────────────

  /**
   * Builds answer composer screen scaffold and sections.
   *
   * Takes:
   * - build context.
   *
   * Returns:
   * - Complete answer composer UI.
   *
   * Used for:
   * - Rendering post-and-share interaction flow.
   */
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answerState = context.watch<AnswerQuestionCubit>().state;
    final isLoading = answerState.isLoading || _isPosting;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────
            _buildTopBar(isLoading),

            // ── Question card ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.s20,
                  AppSizes.s24,
                  AppSizes.s20,
                  AppSizes.s24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionBubble(),
                    AppSizes.gapH24,
                    _buildAnswerField(),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ───────────────────────
            AnimatedPadding(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _buildBottomBar(isLoading),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────

  /**
   * Builds top bar with close action and title.
   *
   * Takes:
   * - loading state (reserved for behavior parity).
   *
   * Returns:
   * - Header widget for composer screen.
   *
   * Used for:
   * - Consistent navigation chrome on answer composer.
   */
  Widget _buildTopBar(bool isLoading) {
    final theme = Theme.of(context);
    return Container(
      height: AppSizes.s56,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.s12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: _close,
            child: Container(
              width: AppSizes.s32,
              height: AppSizes.s32,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: theme.colorScheme.onSurface,
                size: AppSizes.iconNormal,
              ),
            ),
          ),
          // Title
          Expanded(
            child: Text(
              'Reply',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Spacer to balance back button
          SizedBox(width: AppSizes.s32),
        ],
      ),
    );
  }

  // ── Question bubble ─────────────────────────────────────────────────

  /**
   * Builds highlighted question bubble at top of composer.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Styled card containing source badge and question text.
   *
   * Used for:
   * - Providing question context while composing answer.
   */
  Widget _buildQuestionBubble() {
    final theme = Theme.of(context);
    if (isRecommendationQuestion(widget.questionType)) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.s16),
        decoration: BoxDecoration(
          color: pinkColor,
          borderRadius: BorderRadius.circular(AppSizes.r20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.s10,
                vertical: AppSizes.s4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(AppSizes.rMax),
              ),
              child: Text(
                'RECOMMENDATION',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            AppSizes.gapH12,
            MediaCard(
              media: buildRecommendationMedia(
                widget.mediaRec,
                widget.questionText,
              ),
              compact: true,
              showOverview: true,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.s20),
      decoration: BoxDecoration(
        color: pinkColor,
        borderRadius: BorderRadius.circular(AppSizes.r20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.s10,
              vertical: AppSizes.s4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(AppSizes.rMax),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isAnonymous ? '👻' : '👤',
                  style: TextStyle(fontSize: AppSizes.s10),
                ),
                AppSizes.gapW4,
                Text(
                  widget.isAnonymous ? 'ANONYMOUS' : 'FROM USER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          AppSizes.gapH12,
          Text(
            widget.questionText,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ── Answer field ───────────────────────────────────────────────────

  /**
   * Builds multi-line text field for entering answer content.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Configured TextField with live character counting behavior.
   *
   * Used for:
   * - Capturing user answer text input.
   */
  Widget _buildAnswerField() {
    final theme = Theme.of(context);
    return TextField(
      controller: _answerController,
      focusNode: _focusNode,
      maxLines: null,
      minLines: 3,
      maxLength: 200,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Type your reply...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          fontWeight: FontWeight.w400,
        ),
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
          fontWeight: FontWeight.w600,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────

  /**
   * Builds footer containing character count and post action.
   *
   * Takes:
   * - loading state to disable interactions and show progress spinner.
   *
   * Returns:
   * - Bottom action row widget.
   *
   * Used for:
   * - Triggering post workflow and exposing input length feedback.
   */
  Widget _buildBottomBar(bool isLoading) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.s20,
        AppSizes.s12,
        AppSizes.s20,
        AppSizes.s12,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Character count
          Text(
            '${_answerController.text.length}/200',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
            ),
          ),
          const Spacer(),
          // Post button
          GestureDetector(
            onTap: isLoading ? null : _postAnswer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.s24,
                vertical: AppSizes.s12,
              ),
              decoration: BoxDecoration(
                color: _canPost
                    ? pinkColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.rMax),
              ),
              child: isLoading
                  ? SizedBox(
                      width: AppSizes.s20,
                      height: AppSizes.s20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      isRecommendationQuestion(widget.questionType)
                          ? 'Post Answer'
                          : 'Post & Share',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _canPost
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.30,
                              ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
