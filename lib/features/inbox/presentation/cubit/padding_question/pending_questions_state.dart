import 'package:equatable/equatable.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';

sealed class PendingQuestionsState extends Equatable {
  const PendingQuestionsState();

  @override
  List<Object?> get props => [];
}

class PendingQuestionsInitial extends PendingQuestionsState {
  const PendingQuestionsInitial();
}

class PendingQuestionsLoading extends PendingQuestionsState {
  const PendingQuestionsLoading();
}

class PendingQuestionsSuccess extends PendingQuestionsState {
  const PendingQuestionsSuccess({
    required this.questions,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<InboxQuestion> questions;
  final bool hasMore;
  final bool isLoadingMore;

  PendingQuestionsSuccess copyWith({
    List<InboxQuestion>? questions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PendingQuestionsSuccess(
      questions: questions ?? this.questions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [questions, hasMore, isLoadingMore];
}

class PendingQuestionsError extends PendingQuestionsState {
  const PendingQuestionsError(this.message, {this.questions = const []});

  final String message;
  final List<InboxQuestion> questions;

  @override
  List<Object?> get props => [message, questions];
}
