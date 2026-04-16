import 'package:equatable/equatable.dart';

enum AnswerQuestionStatus { initial, loading, success, failure }

class AnswerQuestionState extends Equatable {
  const AnswerQuestionState({
    this.status = AnswerQuestionStatus.initial,
    this.errorMessage,
  });

  final AnswerQuestionStatus status;
  final String? errorMessage;

  bool get isLoading => status == AnswerQuestionStatus.loading;
  bool get hasError => status == AnswerQuestionStatus.failure;

  AnswerQuestionState copyWith({
    AnswerQuestionStatus? status,
    String? errorMessage,
  }) {
    return AnswerQuestionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
