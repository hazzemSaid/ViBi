import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

/// Use case for deleting a social media link from a user's profile.
///
/// This use case removes a social link by delegating to the [SocialLinksRepository].
class DeleteSocialLinkUseCase {
  final SocialLinksRepository _repository;

  DeleteSocialLinkUseCase(this._repository);

  /// Deletes a social link by its ID.
  ///
  /// [linkId] is the unique ID of the social link to delete.
  ///
  /// Returns:
  /// - [Right] with [Unit] on successful deletion.
  /// - [Left] with an error message on failure.
  Future<Either<String, Unit>> call(String linkId) {
    return _repository.deleteSocialLink(linkId);
  }
}
