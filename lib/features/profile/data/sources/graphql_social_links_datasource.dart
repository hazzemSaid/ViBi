import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/profile/domain/entities/social_link.dart';

/// GraphQL-based Social Links Data Source
/// Uses GraphQL queries and mutations for social link operations
/// Benefits:
/// - Better performance than sequential REST calls
/// - Single network request for all operations
/// - Consistent with profile data source architecture
class GraphQLSocialLinksDataSource {
  final SupabaseClient _client;

  GraphQLSocialLinksDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Lazy getter for GraphQL client
  GraphQLClient get _graphqlClient => GraphQLConfig.client;

  /// Fetch user's social links using GraphQL query
  Future<List<SocialLink>> fetchSocialLinks(String userId) async {
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

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL fetch social links error: ${result.exception}');
        return _fetchSocialLinksViaRest(userId);
      }

      final edges =
          result.data?['social_linksCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        return SocialLink.fromMap(node);
      }).toList();
    } catch (e) {
      print('Fetch social links exception: $e');
      return _fetchSocialLinksViaRest(userId);
    }
  }

  Future<List<SocialLink>> _fetchSocialLinksViaRest(String userId) async {
    try {
      final response = await _client
          .from('social_links')
          .select(
            'id, platform, url, title, display_label, display_order, is_active',
          )
          .eq('user_id', userId)
          .order('display_order', ascending: true);

      return (response as List<dynamic>)
          .map(
            (row) => SocialLink.fromMap(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    } catch (e) {
      print('REST fetch social links error: $e');
      return [];
    }
  }

  /// Add new social link using GraphQL mutation
  Future<SocialLink> addSocialLink({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  }) async {
    const mutation = r'''
      mutation AddSocialLink(
        $userId: UUID!
        $platform: String!
        $url: String!
        $title: String
        $displayLabel: String
        $displayOrder: Int!
      ) {
        insertsocial_linksCollection(
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

    try {
      final result = await _graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'userId': userId,
            'platform': platform,
            'url': url,
            'title': title,
            'displayLabel': displayLabel,
            'displayOrder': displayOrder,
          },
        ),
      );

      if (result.hasException) {
        print('GraphQL add social link error: ${result.exception}');
        return _addSocialLinkViaRest(
          userId: userId,
          platform: platform,
          url: url,
          title: title,
          displayLabel: displayLabel,
          displayOrder: displayOrder,
        );
      }

      final records =
          result.data?['insertsocial_linksCollection']?['records'] as List? ??
          [];
      if (records.isEmpty) {
        throw Exception('Failed to create social link');
      }

      final node = records.first as Map<String, dynamic>;
      print('Social link added successfully via GraphQL');
      return SocialLink.fromMap(node);
    } catch (e) {
      print('Add social link exception: $e');
      rethrow;
    }
  }

  Future<SocialLink> _addSocialLinkViaRest({
    required String userId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
  }) async {
    try {
      final response = await _client
          .from('social_links')
          .insert({
            'user_id': userId,
            'platform': platform,
            'url': url,
            'title': title,
            'display_label': displayLabel,
            'display_order': displayOrder,
            'is_active': true,
          })
          .select()
          .single();

      return SocialLink.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      print('REST add social link error: $e');
      rethrow;
    }
  }

  /// Update existing social link using GraphQL mutation
  Future<SocialLink> updateSocialLink({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  }) async {
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

    try {
      final result = await _graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'id': linkId,
            'platform': platform,
            'url': url,
            'title': title,
            'displayLabel': displayLabel,
            'displayOrder': displayOrder,
            'isActive': isActive,
          },
        ),
      );

      if (result.hasException) {
        print('GraphQL update social link error: ${result.exception}');
        return _updateSocialLinkViaRest(
          linkId: linkId,
          platform: platform,
          url: url,
          title: title,
          displayLabel: displayLabel,
          displayOrder: displayOrder,
          isActive: isActive,
        );
      }

      final records =
          result.data?['updatesocial_linksCollection']?['records'] as List? ??
          [];
      if (records.isEmpty) {
        throw Exception('Failed to update social link');
      }

      final node = records.first as Map<String, dynamic>;
      print('Social link updated successfully via GraphQL');
      return SocialLink.fromMap(node);
    } catch (e) {
      print('Update social link exception: $e');
      rethrow;
    }
  }

  Future<SocialLink> _updateSocialLinkViaRest({
    required String linkId,
    required String platform,
    required String url,
    required String? title,
    required String? displayLabel,
    required int displayOrder,
    required bool isActive,
  }) async {
    try {
      final response = await _client
          .from('social_links')
          .update({
            'platform': platform,
            'url': url,
            'title': title,
            'display_label': displayLabel,
            'display_order': displayOrder,
            'is_active': isActive,
          })
          .eq('id', linkId)
          .select()
          .single();

      return SocialLink.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      print('REST update social link error: $e');
      rethrow;
    }
  }

  /// Delete social link using GraphQL mutation
  Future<void> deleteSocialLink(String linkId) async {
    const mutation = r'''
      mutation DeleteSocialLink($id: UUID!) {
        deletesocial_linksCollection(filter: { id: { eq: $id } }) {
          affectedCount
        }
      }
    ''';

    try {
      final result = await _graphqlClient.mutate(
        MutationOptions(document: gql(mutation), variables: {'id': linkId}),
      );

      if (result.hasException) {
        print('GraphQL delete social link error: ${result.exception}');
        return _deleteSocialLinkViaRest(linkId);
      }

      final affectedCount =
          result.data?['deletesocial_linksCollection']?['affectedCount']
              as int? ??
          0;
      if (affectedCount == 0) {
        throw Exception('Social link not found or already deleted');
      }

      print('Social link deleted successfully via GraphQL');
    } catch (e) {
      print('Delete social link exception: $e');
      rethrow;
    }
  }

  Future<void> _deleteSocialLinkViaRest(String linkId) async {
    try {
      await _client.from('social_links').delete().eq('id', linkId);
      print('Social link deleted successfully via REST');
    } catch (e) {
      print('REST delete social link error: $e');
      rethrow;
    }
  }
}
