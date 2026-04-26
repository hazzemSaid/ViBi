import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/inbox/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/widgets/comment_sheet.dart';
import 'package:vibi/features/reactions/presentation/widgets/reaction_bar.dart';

class ProfileAnswerActionRow extends StatefulWidget {
  final AnsweredQuestion answer;
  final VoidCallback? onShareTap;
  final void Function(String answerId, int reactionsCount, int commentsCount)?
  onCountsChanged;
  final bool compact;

  const ProfileAnswerActionRow({
    super.key,
    required this.answer,
    this.onShareTap,
    this.onCountsChanged,
    this.compact = false,
  });

  @override
  State<ProfileAnswerActionRow> createState() => _ProfileAnswerActionRowState();
}

class _ProfileAnswerActionRowState extends State<ProfileAnswerActionRow> {
  late final ReactionsRepository _reactionsRepository;
  late int _commentsCount;
  late int _reactionsCount;

  @override
  void initState() {
    super.initState();
    _reactionsRepository = getIt<ReactionsRepository>();
    _commentsCount = widget.answer.commentsCount;
    _reactionsCount = widget.answer.likesCount;
  }

  Future<void> _openComments() async {
    await CommentSheet.show(context, widget.answer.id);
    final freshCount = await _reactionsRepository.getCommentsCount(
      widget.answer.id,
    );
    if (!mounted) return;
    setState(() => _commentsCount = freshCount);

    _patchCountsInCubit(
      reactionsCount: _reactionsCount,
      commentsCount: _commentsCount,
    );

    widget.onCountsChanged?.call(
      widget.answer.id,
      _reactionsCount,
      _commentsCount,
    );
  }

  void _patchCountsInCubit({
    required int reactionsCount,
    required int commentsCount,
  }) {
    try {
      context.read<UserAnswersCubit>().patchAnswerCounts(
        answerId: widget.answer.id,
        reactionsCount: reactionsCount,
        commentsCount: commentsCount,
      );
    } catch (_) {
      // Some contexts may not provide UserAnswersCubit.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Row(
        children: [
          ReactionBar(
            answerId: widget.answer.id,
            initialCommentCount: widget.answer.commentsCount,
            compact: true,
            showCommentButton: false,
            onCountsChanged: (reactionsCount, commentsCount) {
              _reactionsCount = reactionsCount;
              _commentsCount = commentsCount;

              _patchCountsInCubit(
                reactionsCount: reactionsCount,
                commentsCount: commentsCount,
              );

              widget.onCountsChanged?.call(
                widget.answer.id,
                reactionsCount,
                commentsCount,
              );
            },
          ),
          const Spacer(),
          _ActionIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: _openComments,
          ),
          const SizedBox(width: 10),
          _ActionIconButton(
            icon: Icons.share_outlined,
            onTap: () => widget.onShareTap?.call(),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
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
                    size: 16,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Send Ask',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final spacing = screenWidth < 360 ? 12.0 : 20.0;

    return Row(
      children: [
        Expanded(
          child: ReactionBar(
            answerId: widget.answer.id,
            initialCommentCount: widget.answer.commentsCount,
            onCountsChanged: (reactionsCount, commentsCount) {
              _reactionsCount = reactionsCount;
              _commentsCount = commentsCount;

              _patchCountsInCubit(
                reactionsCount: reactionsCount,
                commentsCount: commentsCount,
              );

              widget.onCountsChanged?.call(
                widget.answer.id,
                reactionsCount,
                commentsCount,
              );
            },
          ),
        ),
        SizedBox(width: spacing),
        GestureDetector(
          onTap: widget.onShareTap,
          child: Icon(
            Icons.share_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            size: 20,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.onSurface,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Send Ask',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
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
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.35),
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 21,
        ),
      ),
    );
  }
}
