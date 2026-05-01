import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/cubit/reaction_cubit.dart';
import 'package:vibi/features/reactions/presentation/cubit/reaction_state.dart';
import 'package:vibi/core/common/widgets/comment_sheet.dart';

const Map<String, String> _emojis = {'love': '❤️', 'sad': '😢', 'haha': '😂'};
const Map<String, IconData> _reactionIcons = {
  'love': Icons.favorite_border,
  'sad': Icons.sentiment_dissatisfied_outlined,
  'haha': Icons.sentiment_very_satisfied_outlined,
};

class ReactionBar extends StatefulWidget {
  const ReactionBar({
    super.key,
    required this.answerId,
    this.initialCommentCount = 0,
    this.onCountsChanged,
    this.compact = false,
    this.showCommentButton = true,
    this.inactiveColor,
    this.activeColor,
  });

  final String answerId;
  final int initialCommentCount;
  final void Function(int reactionsCount, int commentsCount)? onCountsChanged;
  final bool compact;
  final bool showCommentButton;
  final Color? inactiveColor;
  final Color? activeColor;

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  late final ReactionCubit _reactionCubit;
  late final ReactionsRepository _repository;

  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _reactionCubit = getIt<ReactionCubit>();
    _repository = getIt<ReactionsRepository>();
    _commentCount = widget.initialCommentCount;

    _reactionCubit.load(widget.answerId);
    if (widget.showCommentButton) {
      _loadCommentCount();
    }
  }

  @override
  void dispose() {
    _reactionCubit.close();
    super.dispose();
  }

  Future<void> _loadCommentCount() async {
    try {
      final count = await _repository.getCommentsCount(widget.answerId);
      if (!mounted) return;
      setState(() => _commentCount = count);
      
      final currentState = _reactionCubit.state;
      final reactionsCount = (currentState is ReactionLoaded) ? currentState.summary.total : 0;
      _notifyCounts(reactionsCount: reactionsCount);
    } catch (_) {
      // Keep existing count if refresh fails.
    }
  }

  void _notifyCounts({required int reactionsCount}) {
    widget.onCountsChanged?.call(reactionsCount, _commentCount);
  }

  Future<void> _pick(String reaction) async {
    HapticFeedback.selectionClick();

    await _reactionCubit.toggleReaction(
      answerId: widget.answerId,
      reaction: reaction,
    );
  }

  Future<void> _openComments() async {
    await CommentSheet.show(context, widget.answerId);
    await _loadCommentCount();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reactionCubit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocConsumer<ReactionCubit, ReactionState>(
            listenWhen: (previous, current) {
              final previousTotal = (previous is ReactionLoaded) ? previous.summary.total : null;
              final currentTotal = (current is ReactionLoaded) ? current.summary.total : null;
              return previousTotal != currentTotal;
            },
            listener: (_, state) {
              if (state is ReactionLoaded) {
                _notifyCounts(reactionsCount: state.summary.total);
              }
            },
            builder: (context, state) {
              final data = (state is ReactionLoaded)
                  ? state.summary
                  : const ReactionSummary(
                    counts: {'love': 0, 'sad': 0, 'haha': 0},
                  );

              if (widget.compact) {
                final inactiveColor =
                    widget.inactiveColor ??
                    Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
                final activeColor =
                    widget.activeColor ??
                    Theme.of(context).colorScheme.secondary;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _reactionIcons.entries.map((entry) {
                    final isActive = data.myReaction == entry.key;
                    final count = data.counts[entry.key] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _BouncingReactionWidget(
                        onTap: () => _pick(entry.key),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.value,
                              size: 26,
                              color: isActive ? activeColor : inactiveColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$count',
                              style: TextStyle(
                                color: isActive
                                    ? activeColor
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: _emojis.entries.map((entry) {
                  final isActive = data.myReaction == entry.key;
                  return _ReactionChip(
                    emoji: entry.value,
                    count: data.counts[entry.key] ?? 0,
                    active: isActive,
                    onTap: () => _pick(entry.key),
                  );
                }).toList(),
              );
            },
          ),
          if (widget.showCommentButton) ...[
            const SizedBox(height: 2),
            TextButton.icon(
              onPressed: _openComments,
              icon: Icon(Icons.chat_bubble_outline, size: 16),
              label: Text('Comment ($_commentCount)'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.emoji,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BouncingReactionWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BouncingReactionWidget extends StatefulWidget {
  const _BouncingReactionWidget({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BouncingReactionWidget> createState() =>
      _BouncingReactionWidgetState();
}

class _BouncingReactionWidgetState extends State<_BouncingReactionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
