import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/services/instagram_share_service.dart';
import 'package:vibi/features/home/presentation/providers/feed_providers.dart';
import 'package:vibi/features/home/presentation/providers/feed_state.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/widgets/comment_sheet.dart';
import 'package:vibi/features/reactions/presentation/widgets/reaction_bar.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.answerId,
    required this.fallbackAnswerText,
    required this.fallbackQuestionText,
    required this.fallbackUsername,
  });

  final String answerId;
  final String fallbackAnswerText;
  final String fallbackQuestionText;
  final String fallbackUsername;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ReactionSection(answerId: answerId),
        const Spacer(),
        _CommentActionButton(answerId: answerId),
        const SizedBox(width: 10),
        _ShareActionButton(
          answerId: answerId,
          fallbackAnswerText: fallbackAnswerText,
          fallbackQuestionText: fallbackQuestionText,
          fallbackUsername: fallbackUsername,
        ),
        const SizedBox(width: 10),
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
  });

  final String answerId;
  final String fallbackAnswerText;
  final String fallbackQuestionText;
  final String fallbackUsername;

  Future<void> _showShareDialog(
    BuildContext context,
    ({String answerText, String questionText, String username}) payload,
  ) async {
    await InstagramShareService.showShareSheet(
      context,
      questionText: payload.questionText,
      answerText: payload.answerText,
      username: payload.username,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    return BlocSelector<
      GlobalFeedCubit,
      FeedState,
      ({String answerText, String questionText, String username})
    >(
      selector: (state) {
        final item = state is FeedLoaded
            ? feedCubit.getItemById(answerId)
            : null;
        if (item == null) {
          return (
            answerText: fallbackAnswerText,
            questionText: fallbackQuestionText,
            username: fallbackUsername,
          );
        }

        return (
          answerText: item.answerText,
          questionText: item.questionText,
          username: item.answerAuthorUsername,
        );
      },
      builder: (context, payload) {
        return _ActionIconButton(
          icon: Icons.share_outlined,
          onTap: () {
            _showShareDialog(context, payload);
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
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onSurface, size: 16),
            SizedBox(width: 7),
            Text(
              'Send Tell',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 12,
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 21),
      ),
    );
  }
}

