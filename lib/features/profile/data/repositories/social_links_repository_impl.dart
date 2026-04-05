import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/data/sources/graphql_social_links_datasource.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';
import 'package:vibi/features/profile/domain/repositories/social_links_repository.dart';

class SocialLinksRepositoryImpl implements SocialLinksRepository {
  final GraphQLSocialLinksDataSource _dataSource;

  SocialLinksRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, List<SocialLink>>> fetchSocialLinks(String userId) {
    return _dataSource.fetchSocialLinks(userId);
  }

  @override
  Future<Either<String, SocialLink>> addSocialLink({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  }) {
    return _dataSource.addSocialLink(
      userId: userId,
      platform: platform,
      url: url,
      title: title,
      displayLabel: displayLabel,
      displayOrder: displayOrder,
    );
  }

  @override
  Future<Either<String, SocialLink>> updateSocialLink({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  }) {
    return _dataSource.updateSocialLink(
      linkId: linkId,
      platform: platform,
      url: url,
      title: title,
      displayLabel: displayLabel,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }

  @override
  Future<Either<String, Unit>> deleteSocialLink(String linkId) {
    return _dataSource.deleteSocialLink(linkId);
  }
}
