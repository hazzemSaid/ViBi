import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

class AddSocialLinkUseCase {
  final SocialLinksRepository _repository;

  AddSocialLinkUseCase(this._repository);

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
