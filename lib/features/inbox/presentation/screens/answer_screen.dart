import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/inbox/presentation/cubits/answer_question_cubit.dart';
import 'package:vibi/features/inbox/presentation/cubits/pending_questions_cubit.dart';
import 'package:vibi/features/inbox/presentation/screens/share_answer_screen.dart';
import 'package:vibi/features/inbox/presentation/state/answer_screen_visibility.dart';

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
  });

  final String questionId;
  final String questionText;
  final bool isAnonymous;

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final _answerController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPosting = false;

  static const Color _pink = Color(0xFFFE2C55);

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

  // ── Helpers ────────────────────────────────────────────────────────────────

  /**
   * Resolves username from current Supabase user metadata/email.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - best-effort username string for share attribution.
   *
   * Used for:
   * - Passing user handle into [ShareAnswerScreen].
   */
  String get _username {
    final user = Supabase.instance.client.auth.currentUser;
    return (user?.userMetadata?['username'] as String?)?.trim() ??
        user?.email?.split('@').first ??
        'me';
  }

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

  // ── Actions ────────────────────────────────────────────────────────────────

  /**
   * Shows validation dialog when user attempts to post empty answer.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - void.
   *
   * Used for:
   * - Blocking empty submissions with clear feedback.
   */
  void _showEmptyAnswerError() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Answer required',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Please type your answer before posting.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.60),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Color(0xFFFE2C55),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      _showEmptyAnswerError();
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

    // Navigate to share screen
    final didShare = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ShareAnswerScreen(
          questionText: widget.questionText,
          answerText: text,
          isAnonymous: widget.isAnonymous,
          username: _username,
        ),
      ),
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

  // ── Build ──────────────────────────────────────────────────────────────────

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
    final answerState = context.watch<AnswerQuestionCubit>().state;
    final isLoading = answerState.isLoading || _isPosting;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _buildTopBar(isLoading),

            // ── Question card ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionBubble(),
                    const SizedBox(height: 24),
                    _buildAnswerField(),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ────────────────────────────────────────
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

  // ── Top bar ────────────────────────────────────────────────────────────────

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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
          // Title
          const Expanded(
            child: Text(
              'Reply',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          // Spacer to balance back button
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── Question bubble ────────────────────────────────────────────────────────

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _pink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isAnonymous ? '👻' : '👤',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.isAnonymous ? 'ANONYMOUS' : 'FROM USER',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.questionText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ── Answer field ───────────────────────────────────────────────────────────

  /**
   * Builds multi-line text field for entering answer content.
   *
   * Takes:
   * - no arguments.
   *
   * Returns:
   * - Configured [TextField] with live character counting behavior.
   *
   * Used for:
   * - Capturing user answer text input.
   */
  Widget _buildAnswerField() {
    return TextField(
      controller: _answerController,
      focusNode: _focusNode,
      maxLines: null,
      minLines: 3,
      maxLength: 200,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Type your reply...',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        counterStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.30),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────

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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Character count
          Text(
            '${_answerController.text.length}/200',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          const Spacer(),
          // Post button
          GestureDetector(
            onTap: isLoading ? null : _postAnswer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _canPost ? _pink : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(999),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Post & Share',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _canPost ? Colors.white : Colors.white30,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
