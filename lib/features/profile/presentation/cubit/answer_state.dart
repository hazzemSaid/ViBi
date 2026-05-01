// User Answers State
import 'package:equatable/equatable.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';

abstract class UserAnswersState extends Equatable {
  const UserAnswersState();
  @override
  List<Object?> get props => [];
}

class UserAnswersInitial extends UserAnswersState {
  const UserAnswersInitial();
}

class UserAnswersLoading extends UserAnswersState {
  const UserAnswersLoading();
}

class UserAnswersLoaded extends UserAnswersState {
  final List<AnsweredQuestion> answers;
  const UserAnswersLoaded(this.answers);
  @override
  List<Object?> get props => [answers];
}

class UserAnswersFailure extends UserAnswersState {
  final String message;
  const UserAnswersFailure(this.message);
  @override
  List<Object?> get props => [message];
}
