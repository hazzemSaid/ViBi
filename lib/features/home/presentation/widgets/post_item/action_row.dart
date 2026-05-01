import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/constants/app_sizes.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:vibi/features/feed/presentation/cubit/feed_state.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/core/common/widgets/comment_sheet.dart';
import 'package:vibi/core/common/widgets/reaction_bar.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.answerId,
    required this.fallbackAnswerText,
    required this.fallbackQuestionText,
    required this.fallbackUsername,
    required this.fallbackIsAnonymous,
  });

  final String answerId;
  final String fallbackAnswerText;
  final String fallbackQuestionText;
  final String fallbackUsername;
  final bool fallbackIsAnonymous;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ReactionSection(answerId: answerId),
        const Spacer(),
        _CommentActionButton(answerId: answerId),
        AppSizes.gapW12,
        _ShareActionButton(
          answerId: answerId,
          fallbackAnswerText: fallbackAnswerText,
          fallbackQuestionText: fallbackQuestionText,
          fallbackUsername: fallbackUsername,
          fallbackIsAnonymous: fallbackIsAnonymous,
        ),
        AppSizes.gapW12,
        const _SendTellButton(),
      ],
    );
  }
}

class _ReactionSection extends StatelessWidget {
  const _ReactionSection({required this.answerId});

  final String answerId;

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    return BlocSelector<GlobalFeedCubit, FeedState, int>(
      selector: (state) {
        if (state is! FeedLoaded) return 0;
        return feedCubit.getItemById(answerId)?.commentsCount ?? 0;
      },
      builder: (context, commentsCount) {
        return RepaintBoundary(
          child: ReactionBar(
            key: ValueKey('reaction_bar_$answerId'),
            answerId: answerId,
            initialCommentCount: commentsCount,
            compact: true,
            showCommentButton: false,
            onCountsChanged: (reactionsCount, nextCommentsCount) {
              context.read<GlobalFeedCubit>().patchAnswerCounts(
                answerId: answerId,
                reactionsCount: reactionsCount,
                commentsCount: nextCommentsCount,
              );
            },
          ),
        );
      },
    );
  }
}

class _CommentActionButton extends StatefulWidget {
  const _CommentActionButton({required this.answerId});

  final String answerId;

  @override
  State<_CommentActionButton> createState() => _CommentActionButtonState();
}

class _CommentActionButtonState extends State<_CommentActionButton> {
  late final ReactionsRepository _reactionsRepository;

  @override
  void initState() {
    super.initState();
    _reactionsRepository = getIt<ReactionsRepository>();
  }

  Future<void> _openComments() async {
    await CommentSheet.show(context, widget.answerId);
    final freshCount = await _reactionsRepository.getCommentsCount(
      widget.answerId,
    );
    if (!mounted) return;

    context.read<GlobalFeedCubit>().patchAnswerCounts(
      answerId: widget.answerId,
      commentsCount: freshCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionIconButton(
      icon: Icons.chat_bubble_outline,
      onTap: _openComments,
    );
  }
}

class _ShareActionButton extends StatelessWidget {
  const _ShareActionButton({
    required this.answerId,
    required this.fallbackAnswerText,
    required this.fallbackQuestionText,
    required this.fallbackUsername,
    required this.fallbackIsAnonymous,
  });

  final String answerId;
  final String fallbackAnswerText;
  final String fallbackQuestionText;
  final String fallbackUsername;
  final bool fallbackIsAnonymous;
  /**
   * Opens the share screen for the given answer.
   */
  Future<void> _openShareScreen(
    BuildContext context,
    ({
      String answerText,
      String questionText,
      String username,
      bool isAnonymous,
      bool canShare,
    })
    payload,
  ) async {
    if (!payload.canShare) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only share your own answers or questions.'),
        ),
      );
      return;
    }

    await context.pushNamed<bool>(
      'share-answer',
      extra: {
        'questionText': payload.questionText,
        'answerText': payload.answerText,
        'username': payload.username,
        'isAnonymous': payload.isAnonymous,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    return BlocSelector<
      GlobalFeedCubit,
      FeedState,
      ({
        String answerText,
        String questionText,
        String username,
        bool isAnonymous,
        bool canShare,
      })
    >(
      selector: (state) {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final item = state is FeedLoaded
            ? feedCubit.getItemById(answerId)
            : null;
        if (item == null) {
          return (
            answerText: fallbackAnswerText,
            questionText: fallbackQuestionText,
            username: fallbackUsername,
            isAnonymous: fallbackIsAnonymous,
            canShare: false,
          );
        }

        final canShare =
            currentUserId != null &&
            (item.answerAuthorId == currentUserId ||
                item.userId == currentUserId ||
                item.questionSenderId == currentUserId);

        return (
          answerText: item.answerText,
          questionText: item.questionText,
          username: item.answerAuthorUsername,
          isAnonymous: item.isAnonymous,
          canShare: canShare,
        );
      },
      builder: (context, payload) {
        return _ActionIconButton(
          icon: Icons.share_outlined,
          onTap: () {
            _openShareScreen(context, payload);
          },
        );
      },
    );
  }
}

class _SendTellButton extends StatelessWidget {
  const _SendTellButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: implement send tell , to send question to the user related to the post
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s10,
          vertical: AppSizes.s10,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.onSurface,
              size: AppSizes.iconSmall,
            ),
            AppSizes.gapW4, // Using gapW6 as closest to 7
            Text(
              'Send Ask',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.s12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.s48,
        height: AppSizes.s48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: AppSizes.s22,
        ),
      ),
    );
  }
}
