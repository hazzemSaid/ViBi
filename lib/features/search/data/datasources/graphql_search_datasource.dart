import 'package:ferry/ferry.dart' as ferry;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/queries/search_queries.dart';
import 'package:vibi/features/search/data/models/content_search_result_model.dart';
import 'package:vibi/features/search/data/models/user_search_result_model.dart';

class GraphQLSearchDataSource {
  final SupabaseClient _client;
  final ferry.Client _ferryClient;

  GraphQLSearchDataSource({SupabaseClient? client, ferry.Client? ferryClient})
    : _client = client ?? Supabase.instance.client,
      _ferryClient = ferryClient ?? GraphQLConfig.ferryClient;



  Future<List<UserSearchResultModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final searchPattern = '%${query.trim()}%';

    try {
      final result = await GraphQLConfig.ferryQuery(
        'SearchUsers',
        document: SearchQueries.searchUsers,
        variables: {'query': searchPattern},
        clientOverride: _ferryClient,
      );

      if (result.hasErrors) {
        debugPrint('GraphQL search users error: ${result.graphqlErrors}');
        debugPrint('GraphQL search users link error: ${result.linkException}');
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
          debugPrint('Failed to fetch blocked users: $e');
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
      debugPrint('Search users exception: $e');
      return _searchUsersViaRest(query);
    }
  }

  Future<List<UserSearchResultModel>> _searchUsersViaRest(String query) async {
    try {
      final searchPattern = '%${query.trim()}%';
      final response = await _client
          .from('profiles')
          .select('id,full_name,username,bio,avatar_urls,is_private')
          .or('username.ilike.$searchPattern,full_name.ilike.$searchPattern')
          .limit(50);

      return (response as List)
          .map(
            (row) =>
                UserSearchResultModel.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList();
    } catch (e) {
      debugPrint('REST search users error: $e');
      return [];
    }
  }

  Future<List<ContentSearchResultModel>> searchContent(String query) async {
    if (query.trim().isEmpty) return [];

    final searchPattern = '%${query.trim()}%';

    try {
      final result = await GraphQLConfig.ferryQuery(
        'SearchContent',
        document: SearchQueries.searchContent,
        variables: {'query': searchPattern},
        clientOverride: _ferryClient,
      );

      if (result.hasErrors) {
        debugPrint('GraphQL search content error: ${result.graphqlErrors}');
        debugPrint(
          'GraphQL search content link error: ${result.linkException}',
        );
        return _searchContentViaRest(query);
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        return ContentSearchResultModel.fromGraphQL(node);
      }).toList();
    } catch (e) {
      debugPrint('Search content exception: $e');
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
          .select('*, questions(*), profiles(username, avatar_urls)')
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
      debugPrint('REST search content error: $e');
      return [];
    }
  }
}
