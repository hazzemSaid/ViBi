import 'package:vibi/features/profile/domain/entities/social_link.dart';

sealed class SocialLinksState {
  const SocialLinksState();
}

class SocialLinksInitial extends SocialLinksState {
  const SocialLinksInitial();
}

class SocialLinksLoading extends SocialLinksState {
  final List<SocialLink> previousLinks;

  const SocialLinksLoading({this.previousLinks = const <SocialLink>[]});
}

class SocialLinksLoaded extends SocialLinksState {
  final List<SocialLink> links;

  const SocialLinksLoaded(this.links);
}

class SocialLinksFailure extends SocialLinksState {
  final String message;
  final List<SocialLink> previousLinks;

  const SocialLinksFailure(
    this.message, {
    this.previousLinks = const <SocialLink>[],
  });
}
