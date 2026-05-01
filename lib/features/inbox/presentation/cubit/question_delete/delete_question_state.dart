import 'package:equatable/equatable.dart';

enum DeleteQuestionStatus { initial, loading, success, failure }

class DeleteQuestionState extends Equatable {
  const DeleteQuestionState({
    this.status = DeleteQuestionStatus.initial,
    this.errorMessage,
  });

  final DeleteQuestionStatus status;
  final String? errorMessage;

  bool get isLoading => status == DeleteQuestionStatus.loading;
  bool get hasError => status == DeleteQuestionStatus.failure;

  DeleteQuestionState copyWith({
    DeleteQuestionStatus? status,
    String? errorMessage,
  }) {
    return DeleteQuestionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
