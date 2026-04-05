import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

abstract class SocialLinksRepository {
  Future<Either<String, List<SocialLink>>> fetchSocialLinks(String userId);
  Future<Either<String, SocialLink>> addSocialLink({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  });
  Future<Either<String, SocialLink>> updateSocialLink({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  });
  Future<Either<String, Unit>> deleteSocialLink(String linkId);
}
