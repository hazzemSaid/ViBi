import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/search/data/models/content_search_result_model.dart';
import 'package:vibi/features/search/data/models/user_search_result_model.dart';

class GraphQLSearchDataSource {
  final SupabaseClient _client;

  GraphQLSearchDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  GraphQLClient get _graphqlClient => GraphQLConfig.client;

  static const _searchUsersQuery = r'''
    query SearchUsers($query: String!) {
      profilesCollection(
        filter: {
          or: [
            { username: { ilike: $query } }
            { full_name: { ilike: $query } }
          ]
        }
        first: 50
      ) {
        edges {
          node {
            id
            full_name
            username
            bio
            avatar_url
            followers_count
            answers_count
            is_private
          }
        }
      }
    }
  ''';

  static const _searchContentQuery = r'''
    query SearchContent($query: String!) {
      answersCollection(
        filter: {
          or: [
            { answer_text: { ilike: $query } }
          ]
        }
        orderBy: [{ created_at: DescNullsLast }]
        first: 50
      ) {
        edges {
          node {
            id
            user_id
            answer_text
            likes_count
            created_at
            questions {
              question_text
              is_anonymous
            }
            profiles {
              username
              avatar_url
            }
          }
        }
      }
    }
  ''';

  Future<List<UserSearchResultModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final searchPattern = '%${query.trim()}%';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(_searchUsersQuery),
          variables: {'query': searchPattern},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL search users error: ${result.exception}');
        return _searchUsersViaRest(query);
      }

      final edges = result.data?['profilesCollection']?['edges'] as List? ?? [];

      // Filter out blocked users (if current user exists)
      final currentUserId = _client.auth.currentUser?.id;
      final blockedIds = <String>{};

      if (currentUserId != null) {
        try {
          final blockedResponse = await _client
              .from('blocks')
              .select('blocked_id')
              .eq('blocker_id', currentUserId);

          for (final row in blockedResponse as List) {
            blockedIds.add(row['blocked_id'] as String);
          }
        } catch (e) {
          print('Failed to fetch blocked users: $e');
        }
      }

      return edges
          .map((edge) {
            final node = edge['node'] as Map<String, dynamic>;
            return UserSearchResultModel.fromGraphQL(node);
          })
          .where((user) => !blockedIds.contains(user.id))
          .toList();
    } catch (e) {
      print('Search users exception: $e');
      return _searchUsersViaRest(query);
    }
  }

  Future<List<UserSearchResultModel>> _searchUsersViaRest(String query) async {
    try {
      final searchPattern = '%${query.trim()}%';
      final response = await _client
          .from('profiles')
          .select()
          .or('username.ilike.$searchPattern,full_name.ilike.$searchPattern')
          .limit(50);

      return (response as List)
          .map(
            (row) =>
                UserSearchResultModel.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList();
    } catch (e) {
      print('REST search users error: $e');
      return [];
    }
  }

  Future<List<ContentSearchResultModel>> searchContent(String query) async {
    if (query.trim().isEmpty) return [];

    final searchPattern = '%${query.trim()}%';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(_searchContentQuery),
          variables: {'query': searchPattern},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL search content error: ${result.exception}');
        return _searchContentViaRest(query);
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        return ContentSearchResultModel.fromGraphQL(node);
      }).toList();
    } catch (e) {
      print('Search content exception: $e');
      return _searchContentViaRest(query);
    }
  }

  Future<List<ContentSearchResultModel>> _searchContentViaRest(
    String query,
  ) async {
    try {
      final searchPattern = '%${query.trim()}%';
      final response = await _client
          .from('answers')
          .select('*, questions(*), profiles(username, avatar_url)')
          .ilike('answer_text', searchPattern)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map(
            (row) => ContentSearchResultModel.fromMap(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();
    } catch (e) {
      print('REST search content error: $e');
      return [];
    }
  }
}
