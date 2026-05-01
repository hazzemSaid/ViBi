import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

/// Use case for fetching a user's social media links.
///
/// This use case retrieves all social links for a user by delegating
/// to the [SocialLinksRepository].
class FetchSocialLinksUseCase {
  final SocialLinksRepository _repository;

  FetchSocialLinksUseCase(this._repository);

  /// Fetches all social links for a specific user.
  ///
  /// [userId] is the ID of the user whose social links to fetch.
  ///
  /// Returns:
  /// - [Right] with a list of [SocialLink] objects ordered by display order on success.
  /// - [Left] with an error message on failure.
  Future<Either<String, List<SocialLink>>> call(String userId) {
    return _repository.fetchSocialLinks(userId);
  }
}
