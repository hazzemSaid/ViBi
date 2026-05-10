import 'package:equatable/equatable.dart';

abstract class SendQuestionState extends Equatable {
  const SendQuestionState();

  @override
  List<Object?> get props => [];
}

class SendQuestionInitial extends SendQuestionState {
  const SendQuestionInitial();
}

class SendQuestionLoading extends SendQuestionState {
  const SendQuestionLoading();
}

class SendQuestionSuccess extends SendQuestionState {
  const SendQuestionSuccess();
}

class SendQuestionFailure extends SendQuestionState {
  final String message;
  const SendQuestionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
