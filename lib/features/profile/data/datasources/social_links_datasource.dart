import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/data/models/social_link_dtos.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

abstract class SocialLinksDataSource {
  Future<Either<String, List<SocialLink>>> fetchSocialLinks(String userId);
  Future<Either<String, SocialLink>> addSocialLink(AddSocialLinkDto dto);
  Future<Either<String, SocialLink>> updateSocialLink(UpdateSocialLinkDto dto);
  Future<Either<String, Unit>> deleteSocialLink(String linkId);
}
