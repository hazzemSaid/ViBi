import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

class DeleteSocialLinkUseCase {
  final SocialLinksRepository _repository;

  DeleteSocialLinkUseCase(this._repository);

  Future<Either<String, Unit>> call(String linkId) {
    return _repository.deleteSocialLink(linkId);
  }
}
