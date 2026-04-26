import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

abstract class SocialLinksRepository {
  /// Fetches all social links for a specific user.
  ///
  /// [userId] is the ID of the user whose social links to fetch.
  ///
  /// Returns:
  /// - [Right] with a list of [SocialLink] objects ordered by display order on success.
  /// - [Left] with an error message on failure.
  Future<Either<String, List<SocialLink>>> fetchSocialLinks(String userId);

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
  Future<Either<String, SocialLink>> addSocialLink({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  });

  /// Updates an existing social link.
  ///
  /// [linkId] is the unique ID of the social link to update.
  /// [platform] is the updated social media platform.
  /// [url] is the updated URL.
  /// [title] is the updated display title.
  /// [displayLabel] is the updated display label.
  /// [displayOrder] is the updated position in the list.
  /// [isActive] determines whether the link is visible on the profile.
  ///
  /// Returns:
  /// - [Right] with the updated [SocialLink] on success.
  /// - [Left] with an error message on failure.
  Future<Either<String, SocialLink>> updateSocialLink({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  });

  /// Deletes a social link by its ID.
  ///
  /// [linkId] is the unique ID of the social link to delete.
  ///
  /// Returns:
  /// - [Right] with [Unit] on successful deletion.
  /// - [Left] with an error message on failure.
  Future<Either<String, Unit>> deleteSocialLink(String linkId);
}
