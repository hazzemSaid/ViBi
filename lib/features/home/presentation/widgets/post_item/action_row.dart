import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/services/instagram_share_service.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';
import 'package:vibi/features/home/presentation/providers/feed_providers.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/widgets/comment_sheet.dart';
import 'package:vibi/features/reactions/presentation/widgets/reaction_bar.dart';

class ActionRow extends StatefulWidget {
  const ActionRow({super.key, required this.item, this.onCountsChanged});

  final FeedItem item;
  final void Function(String answerId, int reactionsCount, int commentsCount)?
  onCountsChanged;

  @override
  State<ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<ActionRow> {
  late final ReactionsRepository _reactionsRepository;
  late int _commentsCount;
  late int _reactionsCount;

  @override
  void initState() {
    super.initState();
    _reactionsRepository = getIt<ReactionsRepository>();
    _commentsCount = widget.item.commentsCount;
    _reactionsCount = widget.item.likesCount;
  }

  Future<void> showShareDialogHome(
    String answeredText,
    String questionText,
    String username,
  ) async {
    if (!mounted) return;
    await InstagramShareService.showShareSheet(
      context,
      questionText: questionText,
      answerText: answeredText,
      username: username,
    );
  }

  Future<void> _openComments() async {
    await CommentSheet.show(context, widget.item.id);
    final freshCount = await _reactionsRepository.getCommentsCount(
      widget.item.id,
    );
    if (!mounted) return;
    setState(() => _commentsCount = freshCount);

    _patchCountsInCubit(
      reactionsCount: _reactionsCount,
      commentsCount: _commentsCount,
    );

    widget.onCountsChanged?.call(
      widget.item.id,
      _reactionsCount,
      _commentsCount,
    );
  }

  void _patchCountsInCubit({
    required int reactionsCount,
    required int commentsCount,
  }) {
    context.read<GlobalFeedCubit>().patchAnswerCounts(
      answerId: widget.item.id,
      reactionsCount: reactionsCount,
      commentsCount: commentsCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReactionBar(
          answerId: widget.item.id,
          initialCommentCount: widget.item.commentsCount,
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
              widget.item.id,
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
          onTap: () => showShareDialogHome(
            widget.item.answerText,
            widget.item.questionText,
            widget.item.answerAuthorUsername,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF5A4FCF).withValues(alpha: 0.35),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                SizedBox(width: 7),
                Text(
                  'Send Tell',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
            color: const Color(0xFF5A4FCF).withValues(alpha: 0.35),
          ),
        ),
        child: Icon(icon, color: Colors.white70, size: 21),
      ),
    );
  }
}
