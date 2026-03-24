import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:vibi/features/home/data/datasources/feed_data_source_interface.dart';
import 'package:vibi/features/home/data/models/feed_item_model.dart';

class GraphQLFeedDataSource implements FeedDataSource {
  final GraphQLClient client;

  GraphQLFeedDataSource(this.client);

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
                avatar_url
              }
              questions {
                question_text
                is_anonymous
                sender_id
                profiles {
                  id
                  username
                  avatar_url
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
              avatar_url
            }
            questions {
              question_text
              is_anonymous
            }
          }
        }
      }
    }
  ''';

  Future<List<FeedItemModel>> _loadFeedFromAnswers({
    required String query,
    required Map<String, dynamic> variables,
  }) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL exception: ${result.exception}');
        throw Exception('GraphQL feed error: ${result.exception}');
      }

      print('GraphQL response data: ${result.data}');

      // Handle both feed_itemsCollection and answersCollection responses
      final edges =
          (result.data?['feed_itemsCollection']?['edges'] ??
                  result.data?['answersCollection']?['edges'])
              as List? ??
          [];

      print('Feed edges count: ${edges.length}');
      if (edges.isEmpty) return [];

      final items = <FeedItemModel>[];
      for (final edge in edges) {
        final node = edge['node'] as Map<String, dynamic>?;
        if (node == null) continue;

        try {
          final item = FeedItemModel.fromGraphQL(node);
          items.add(item);
          print('Added feed item: ${item.id}');
        } catch (e) {
          print('Error creating FeedItemModel: $e');
          print('Node data: $node');
        }
      }

      print('Total items processed: ${items.length}');
      return items;
    } catch (e) {
      print('Full error in _loadFeedFromAnswers: $e');
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
      variables: {'userId': userId, 'limit': limit, 'offset': offset},
    );
  }
}
