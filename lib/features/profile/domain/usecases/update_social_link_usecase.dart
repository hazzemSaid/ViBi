import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

/// Use case for updating an existing social media link.
///
/// This use case modifies social link data by delegating to the [SocialLinksRepository].
class UpdateSocialLinkUseCase {
  final SocialLinksRepository _repository;

  UpdateSocialLinkUseCase(this._repository);

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
  Future<Either<String, SocialLink>> call({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  }) {
    return _repository.updateSocialLink(
      linkId: linkId,
      platform: platform,
      url: url,
      title: title,
      displayLabel: displayLabel,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }
}
