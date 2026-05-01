import 'package:equatable/equatable.dart';
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
