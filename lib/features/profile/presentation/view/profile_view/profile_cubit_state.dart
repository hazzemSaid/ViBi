import 'package:equatable/equatable.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileSaving extends ProfileState {
  final UserProfile profile;

  const ProfileSaving(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileFailure extends ProfileState {
  final String message;
  final UserProfile? profile;

  const ProfileFailure(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
