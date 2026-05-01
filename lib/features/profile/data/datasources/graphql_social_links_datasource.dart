import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/mutations/social_links_mutations.dart';
import 'package:vibi/core/graphql/queries/social_links_queries.dart';
import 'package:vibi/features/profile/data/datasources/social_links_datasource.dart';
import 'package:vibi/features/profile/data/models/social_link_dtos.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

/// GraphQL-only Social Links data source.
class GraphQLSocialLinksDataSource implements SocialLinksDataSource {
  final ferry.Client _ferryClient;

  GraphQLSocialLinksDataSource({ferry.Client? ferryClient})
    : _ferryClient = ferryClient ?? GraphQLConfig.ferryClient;

  static const Set<String> _allowedPlatforms = {
    'instagram',
    'twitter',
    'facebook',
    'youtube',
    'tiktok',
    'linkedin',
    'github',
    'website',
    'custom',
  };

  String _normalizePlatform(String platform) {
    final normalized = platform.trim().toLowerCase();
    if (_allowedPlatforms.contains(normalized)) {
      return normalized;
    }
    return 'custom';
  }

  @override
  Future<Either<String, List<SocialLink>>> fetchSocialLinks(
    String userId,
  ) async {
    final result = await GraphQLConfig.ferryQuery(
      'GetSocialLinks',
      document: SocialLinksQueries.getSocialLinks,
      variables: {'userId': userId},
      clientOverride: _ferryClient,
    );

    if (result.hasErrors) {
      return left(SupabaseErrorHandler.getErrorMessage(result));
    }

    final edges =
        result.data?['social_linksCollection']?['edges'] as List? ?? [];

    final links = edges
        .map((edge) {
          final node = edge['node'] as Map<String, dynamic>;
          return SocialLink.fromMap(node);
        })
        .toList(growable: false);

    return right(links);
  }

  @override
  Future<Either<String, SocialLink>> addSocialLink(AddSocialLinkDto dto) async {
    final normalizedPlatform = _normalizePlatform(dto.platform);

    final result = await GraphQLConfig.ferryMutate(
      'AddSocialLink',
      document: SocialLinksMutations.addSocialLink,
      variables: {
        ...dto.toMap(),
        'platform': normalizedPlatform,
      },
      clientOverride: _ferryClient,
    );

    if (result.hasErrors) {
      return left(SupabaseErrorHandler.getErrorMessage(result));
    }

    final records =
        result.data?['insertIntosocial_linksCollection']?['records'] as List? ??
        [];
    if (records.isEmpty) {
      return left('Failed to create social link.');
    }

    final node = records.first as Map<String, dynamic>;
    return right(SocialLink.fromMap(node));
  }

  @override
  Future<Either<String, SocialLink>> updateSocialLink(UpdateSocialLinkDto dto) async {
    final normalizedPlatform = _normalizePlatform(dto.platform);

    final result = await GraphQLConfig.ferryMutate(
      'UpdateSocialLink',
      document: SocialLinksMutations.updateSocialLink,
      variables: {
        ...dto.toMap(),
        'platform': normalizedPlatform,
      },
      clientOverride: _ferryClient,
    );

    if (result.hasErrors) {
      return left(SupabaseErrorHandler.getErrorMessage(result));
    }

    final records =
        result.data?['updatesocial_linksCollection']?['records'] as List? ?? [];
    if (records.isEmpty) {
      return left('Failed to update social link.');
    }

    final node = records.first as Map<String, dynamic>;
    return right(SocialLink.fromMap(node));
  }

  @override
  Future<Either<String, Unit>> deleteSocialLink(String linkId) async {
    final result = await GraphQLConfig.ferryMutate(
      'DeleteSocialLink',
      document: SocialLinksMutations.deleteSocialLink,
      variables: {'id': linkId},
      clientOverride: _ferryClient,
    );

    if (result.hasErrors) {
      return left(SupabaseErrorHandler.getErrorMessage(result));
    }

    final affectedCount =
        result.data?['deleteFromsocial_linksCollection']?['affectedCount']
            as int? ??
        0;

    if (affectedCount == 0) {
      return left('Social link not found or already deleted.');
    }

    return right(unit);
  }
}
