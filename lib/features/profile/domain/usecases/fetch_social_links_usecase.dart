import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

class FetchSocialLinksUseCase {
  final SocialLinksRepository _repository;

  FetchSocialLinksUseCase(this._repository);

  Future<Either<String, List<SocialLink>>> call(String userId) {
    return _repository.fetchSocialLinks(userId);
  }
}
