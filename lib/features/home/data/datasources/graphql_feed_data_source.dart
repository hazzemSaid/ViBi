import 'dart:async';

import 'package:ferry/ferry.dart' as ferry;
import 'package:flutter/foundation.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/home/data/datasources/feed_data_source_interface.dart';
import 'package:vibi/features/home/data/models/feed_item_model.dart';

class GraphQLFeedDataSource implements FeedDataSource {
  final ferry.Client _ferryClient;
  static const Duration _queryTimeout = Duration(seconds: 20);

  GraphQLFeedDataSource(this._ferryClient);

  static const _globalFeedItemsQuery = r'''
     query GetGlobalFeedItems($limit: Int!, $offset: Int!) {
      feed_itemsCollection(
        orderBy: [{ created_at: DescNullsLast }]
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            user_id
            answer_id
            created_at
            answers {
              id
              answer_text
              likes_count
              comments_count
              shares_count
              created_at
              user_id
              profiles {
                id
                username
                avatar_urls
              }
              questions {
                question_text
                question_type
                media_rec_id
                is_anonymous
                sender_id
                
                profiles {
                  id
                  username
                  avatar_urls
                }
                media_recommendations {
                  id
                  tmdb_id
                  media_type
                  title
                  poster_path
                  overview
                  release_date
                  vote_average
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const _followingFeedItemsQuery = r'''
    query GetFollowingFeedItems($userId: UUID!, $limit: Int!, $offset: Int!) {
      answersCollection(
        filter: {
          user: {
            followers: {
              follower_id: { eq: $userId }
            }
          }
        }
        orderBy: [{ created_at: DescNullsLast }]
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            answer_text
            likes_count
            comments_count
            shares_count
            created_at
            user_id
            profiles {
              id
              username
              avatar_urls
            }
            questions {
              question_text
              question_type
              media_rec_id
              is_anonymous
              media_recommendations {
                id
                tmdb_id
                media_type
                title
                poster_path
                overview
                release_date
                vote_average
              }
            }
          }
        }
      }
    }
  ''';

  Future<List<FeedItemModel>> _loadFeedFromAnswers({
    required String query,
    required String operationName,
    required Map<String, dynamic> variables,
  }) async {
    try {
      ferry.OperationResponse<Map<String, dynamic>, Map<String, dynamic>>
      result;

      try {
        result = await GraphQLConfig.ferryQuery(
          operationName,
          document: query,
          variables: variables,
          clientOverride: _ferryClient,
        ).timeout(_queryTimeout);
      } on TimeoutException {
        // Retry once for transient network delays before surfacing an error.
        result = await GraphQLConfig.ferryQuery(
          operationName,
          document: query,
          variables: variables,
          clientOverride: _ferryClient,
        ).timeout(_queryTimeout);
      }

      if (result.hasErrors) {
        throw Exception(
          'GraphQL feed error: ${SupabaseErrorHandler.getErrorMessage(result)}',
        );
      }

      debugPrint('GraphQL response data: ${result.data}');

      // Handle both feed_itemsCollection and answersCollection responses
      final edges =
          (result.data?['feed_itemsCollection']?['edges'] ??
                  result.data?['answersCollection']?['edges'])
              as List? ??
          [];

      debugPrint('Feed edges count: ${edges.length}');
      if (edges.isEmpty) return [];

      final items = <FeedItemModel>[];
      for (final edge in edges) {
        final node = edge['node'] as Map<String, dynamic>?;
        if (node == null) continue;

        try {
          final item = FeedItemModel.fromGraphQL(node);
          items.add(item);
          debugPrint('Added feed item: ${item.id}');
        } catch (e) {
          debugPrint('Error creating FeedItemModel: $e');
          debugPrint('Node data: $node');
        }
      }

      debugPrint('Total items processed: ${items.length}');
      return items;
    } catch (e) {
      debugPrint('Full error in _loadFeedFromAnswers: $e');
      rethrow;
    }
  }

  @override
  Future<List<FeedItemModel>> getGlobalFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    return _loadFeedFromAnswers(
      query: _globalFeedItemsQuery,
      operationName: 'GetGlobalFeedItems',
      variables: {'limit': limit, 'offset': offset},
    );
  }

  @override
  Future<List<FeedItemModel>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return _loadFeedFromAnswers(
      query: _followingFeedItemsQuery,
      operationName: 'GetFollowingFeedItems',
      variables: {'userId': userId, 'limit': limit, 'offset': offset},
    );
  }
}
