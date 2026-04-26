abstract class ArchiveQuestionState {}

class ArchiveQuestionInitial extends ArchiveQuestionState {}

class ArchiveQuestionLoading extends ArchiveQuestionState {}

class ArchiveQuestionSuccess extends ArchiveQuestionState {}

class ArchiveQuestionFailure extends ArchiveQuestionState {
  final String message;

  ArchiveQuestionFailure({required this.message});
}
