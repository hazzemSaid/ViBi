import 'package:vibi/features/profile/domain/entities/user_profile.dart';

sealed class ProfileState {
  const ProfileState();
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
}

class ProfileSaving extends ProfileState {
  final UserProfile profile;

  const ProfileSaving(this.profile);
}

class ProfileFailure extends ProfileState {
  final String message;
  final UserProfile? profile;

  const ProfileFailure(this.message, {this.profile});
}
