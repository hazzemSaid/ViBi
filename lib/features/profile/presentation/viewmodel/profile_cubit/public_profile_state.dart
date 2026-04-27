import 'package:equatable/equatable.dart';
import 'package:vibi/features/inbox/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/follower_user.dart';
import 'package:vibi/features/profile/domain/entities/following_user.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';

// Public Profile State
abstract class PublicProfileState extends Equatable {
  const PublicProfileState();
  @override
  List<Object?> get props => [];
}

class PublicProfileInitial extends PublicProfileState {
  const PublicProfileInitial();
}

class PublicProfileLoading extends PublicProfileState {
  const PublicProfileLoading();
}

class PublicProfileLoaded extends PublicProfileState {
  final PublicProfile? profile;
  const PublicProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class PublicProfileFailure extends PublicProfileState {
  final String message;
  const PublicProfileFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// User Answers State
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

// Followers State
abstract class FollowersState extends Equatable {
  const FollowersState();
  @override
  List<Object?> get props => [];
}

class FollowersInitial extends FollowersState {
  const FollowersInitial();
}

class FollowersLoading extends FollowersState {
  const FollowersLoading();
}

class FollowersLoaded extends FollowersState {
  final List<FollowerUser> followers;
  const FollowersLoaded(this.followers);
  @override
  List<Object?> get props => [followers];
}

class FollowersFailure extends FollowersState {
  final String message;
  const FollowersFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Following State
abstract class FollowingState extends Equatable {
  const FollowingState();
  @override
  List<Object?> get props => [];
}

class FollowingInitial extends FollowingState {
  const FollowingInitial();
}

class FollowingLoading extends FollowingState {
  const FollowingLoading();
}

class FollowingLoaded extends FollowingState {
  final List<FollowingUser> following;
  const FollowingLoaded(this.following);
  @override
  List<Object?> get props => [following];
}

class FollowingFailure extends FollowingState {
  final String message;
  const FollowingFailure(this.message);
  @override
  List<Object?> get props => [message];
}
