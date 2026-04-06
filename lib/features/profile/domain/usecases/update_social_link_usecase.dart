import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

class UpdateSocialLinkUseCase {
  final SocialLinksRepository _repository;

  UpdateSocialLinkUseCase(this._repository);

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
