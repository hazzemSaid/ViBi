import 'package:vibi/features/follow/domain/entities/follower_user.dart';

abstract class FollowersState {}

class FollowersInitial extends FollowersState {}

class FollowersLoading extends FollowersState {}

class FollowersLoaded extends FollowersState {
  final List<FollowerUser> followers;

  FollowersLoaded(this.followers);
}

class FollowersFailure extends FollowersState {
  final String message;

  FollowersFailure(this.message);
}
