import 'package:equatable/equatable.dart';

abstract class AuthActionState extends Equatable {
  const AuthActionState();

  @override
  List<Object?> get props => [];
}

class AuthActionInitial extends AuthActionState {
  const AuthActionInitial();
}

class AuthActionLoading extends AuthActionState {
  const AuthActionLoading();
}

class AuthActionSuccess extends AuthActionState {
  const AuthActionSuccess();
}

class AuthActionFailure extends AuthActionState {
  final String message;
  const AuthActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
