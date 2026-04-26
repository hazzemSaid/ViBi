import 'package:equatable/equatable.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

sealed class SocialLinksState extends Equatable {
  const SocialLinksState();

  @override
  List<Object?> get props => [];
}

class SocialLinksInitial extends SocialLinksState {
  const SocialLinksInitial();
}

class SocialLinksLoading extends SocialLinksState {
  final List<SocialLink> previousLinks;

  const SocialLinksLoading({this.previousLinks = const <SocialLink>[]});

  @override
  List<Object?> get props => [previousLinks];
}

class SocialLinksLoaded extends SocialLinksState {
  final List<SocialLink> links;

  const SocialLinksLoaded(this.links);

  @override
  List<Object?> get props => [links];
}

class SocialLinksFailure extends SocialLinksState {
  final String message;
  final List<SocialLink> previousLinks;

  const SocialLinksFailure(
    this.message, {
    this.previousLinks = const <SocialLink>[],
  });

  @override
  List<Object?> get props => [message, previousLinks];
}
