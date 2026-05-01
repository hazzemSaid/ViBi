import 'package:equatable/equatable.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';

abstract class CommentsState extends Equatable {
  final List<CommentItem> comments;
  final bool isSending;

  const CommentsState({
    this.comments = const [],
    this.isSending = false,
  });

  @override
  List<Object?> get props => [comments, isSending];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial() : super();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading({super.comments, super.isSending});
}

class CommentsLoaded extends CommentsState {
  const CommentsLoaded({required super.comments, super.isSending});
}

class CommentsFailure extends CommentsState {
  final String message;
  const CommentsFailure(this.message, {super.comments, super.isSending});

  @override
  List<Object?> get props => [message, ...super.props];
}
