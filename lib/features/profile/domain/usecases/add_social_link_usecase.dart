import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

/// Use case for adding a new social media link to a user's profile.
///
/// This use case creates a new social link by delegating to the [SocialLinksRepository].
class AddSocialLinkUseCase {
  final SocialLinksRepository _repository;

  AddSocialLinkUseCase(this._repository);

  /// Adds a new social link for a user.
  ///
  /// [userId] is the ID of the user adding the social link.
  /// [platform] is the social media platform (e.g., 'instagram', 'twitter', 'custom').
  /// [url] is the full URL to the social media profile.
  /// [title] is an optional display title for the link.
  /// [displayLabel] is an optional label shown to users (e.g., "Follow me!").
  /// [displayOrder] determines the position of this link in the list.
  ///
  /// Returns:
  /// - [Right] with the created [SocialLink] on success.
  /// - [Left] with an error message on failure.
  Future<Either<String, SocialLink>> call({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  }) {
    return _repository.addSocialLink(
      userId: userId,
      platform: platform,
      url: url,
      title: title,
      displayLabel: displayLabel,
      displayOrder: displayOrder,
    );
  }
}
