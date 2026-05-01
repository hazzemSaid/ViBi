import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/reactions/presentation/cubit/comments_cubit.dart';
import 'package:vibi/features/reactions/presentation/cubit/comments_state.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key, required this.answerId});

  final String answerId;

  static Future<void> show(BuildContext context, String answerId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.12),
      useRootNavigator: false,
      builder: (_) => CommentSheet(answerId: answerId),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  late final CommentsCubit _commentsCubit;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsCubit = getIt<CommentsCubit>();
    _commentsCubit.load(widget.answerId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentsCubit.close();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.selectionClick();
    _controller.clear();

    await _commentsCubit.addComment(answerId: widget.answerId, body: text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.translucent,
      child: BlocProvider.value(
        value: _commentsCubit,
        child: GestureDetector(
          onTap: null,
          behavior: HitTestBehavior.opaque,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.92,
            minChildSize: 0.4,
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BlocBuilder<CommentsCubit, CommentsState>(
                        builder: (context, state) {
                          if (state is CommentsLoading && state.comments.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final comments = state.comments;
                          if (comments.isEmpty) {
                            return Center(
                              child: Text(
                                'No comments yet',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium!.color!
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: comments.length,
                            itemBuilder: (_, index) {
                              final comment = comments[index];
                              final username =
                                  (comment.username?.trim().isNotEmpty ?? false)
                                  ? comment.username!.trim()
                                  : 'Anonymous';
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.28,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.scrim
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          theme.colorScheme.surfaceContainerLow,
                                      backgroundImage: comment.avatarUrl != null
                                          ? NetworkImage(comment.avatarUrl!)
                                          : null,
                                      child: comment.avatarUrl == null
                                          ? Icon(
                                              Icons.person,
                                              size: 16,
                                              color: theme
                                                  .textTheme
                                                  .labelSmall
                                                  ?.color,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  username,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatDate(comment.createdAt),
                                                style:
                                                    theme.textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            comment.body,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(height: 1.3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (comment.isOptimistic)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    BlocBuilder<CommentsCubit, CommentsState>(
                      builder: (context, state) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 12,
                            left: 16,
                            right: 16,
                            top: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _send(),
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
                                    filled: true,
                                    fillColor:
                                        theme.colorScheme.surfaceContainer,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: state.isSending ? null : _send,
                                child: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary,
                                  child: state.isSending
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        )
                                      : Icon(
                                          Icons.send,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
