import 'package:equatable/equatable.dart';

abstract class FollowActionState extends Equatable {
  const FollowActionState();

  @override
  List<Object?> get props => [];
}

class FollowActionInitial extends FollowActionState {
  const FollowActionInitial();
}

class FollowActionLoading extends FollowActionState {
  const FollowActionLoading();
}

class FollowActionSuccess extends FollowActionState {
  const FollowActionSuccess();
}

class FollowActionFailure extends FollowActionState {
  final String message;
  const FollowActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
