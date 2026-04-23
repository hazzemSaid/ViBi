import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

/// GraphQL-only Social Links data source.
class GraphQLSocialLinksDataSource {
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

  Future<Either<String, List<SocialLink>>> fetchSocialLinks(
    String userId,
  ) async {
    const query = r'''
      query GetSocialLinks($userId: UUID!) {
        social_linksCollection(
          filter: { user_id: { eq: $userId } }
          orderBy: [{ display_order: AscNullsLast }]
        ) {
          edges {
            node {
              id
              user_id
              platform
              url
              title
              display_label
              display_order
              is_active
              created_at
              updated_at
            }
          }
        }
      }
    ''';

    final result = await GraphQLConfig.ferryQuery(
      'GetSocialLinks',
      document: query,
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

  Future<Either<String, SocialLink>> addSocialLink({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  }) async {
    final normalizedPlatform = _normalizePlatform(platform);

    const mutation = r'''
      mutation AddSocialLink(
        $userId: UUID!
        $platform: String!
        $url: String!
        $title: String
        $displayLabel: String
        $displayOrder: Int!
      ) {
        insertIntosocial_linksCollection(
          objects: [{
            user_id: $userId
            platform: $platform
            url: $url
            title: $title
            display_label: $displayLabel
            display_order: $displayOrder
            is_active: true
          }]
        ) {
          records {
            id
            user_id
            platform
            url
            title
            display_label
            display_order
            is_active
            created_at
            updated_at
          }
        }
      }
    ''';

    final result = await GraphQLConfig.ferryMutate(
      'AddSocialLink',
      document: mutation,
      variables: {
        'userId': userId,
        'platform': normalizedPlatform,
        'url': url,
        'title': title,
        'displayLabel': displayLabel,
        'displayOrder': displayOrder,
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

  Future<Either<String, SocialLink>> updateSocialLink({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  }) async {
    final normalizedPlatform = _normalizePlatform(platform);

    const mutation = r'''
      mutation UpdateSocialLink(
        $id: UUID!
        $platform: String!
        $url: String!
        $title: String
        $displayLabel: String
        $displayOrder: Int!
        $isActive: Boolean!
      ) {
        updatesocial_linksCollection(
          set: {
            platform: $platform
            url: $url
            title: $title
            display_label: $displayLabel
            display_order: $displayOrder
            is_active: $isActive
          }
          filter: { id: { eq: $id } }
        ) {
          records {
            id
            user_id
            platform
            url
            title
            display_label
            display_order
            is_active
            created_at
            updated_at
          }
        }
      }
    ''';

    final result = await GraphQLConfig.ferryMutate(
      'UpdateSocialLink',
      document: mutation,
      variables: {
        'id': linkId,
        'platform': normalizedPlatform,
        'url': url,
        'title': title,
        'displayLabel': displayLabel,
        'displayOrder': displayOrder,
        'isActive': isActive,
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

  Future<Either<String, Unit>> deleteSocialLink(String linkId) async {
    const mutation = r'''
      mutation DeleteSocialLink($id: UUID!) {
        deleteFromsocial_linksCollection(filter: { id: { eq: $id } }) {
          affectedCount
        }
      }
    ''';

    final result = await GraphQLConfig.ferryMutate(
      'DeleteSocialLink',
      document: mutation,
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
