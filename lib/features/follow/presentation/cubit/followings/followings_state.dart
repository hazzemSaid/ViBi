import 'package:vibi/features/follow/domain/entities/following_user.dart';

abstract class FollowingState {}

class FollowingInitial extends FollowingState {}

class FollowingLoading extends FollowingState {}

class FollowingLoaded extends FollowingState {
  final List<FollowingUser> following;

  FollowingLoaded(this.following);
}

class FollowingFailure extends FollowingState {
  final String message;

  FollowingFailure(this.message);
}
