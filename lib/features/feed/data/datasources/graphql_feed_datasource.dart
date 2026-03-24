import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/features/feed/data/models/feed_item_model.dart';

class GraphQLFeedDataSource {
  final GraphQLClient _client;

  GraphQLFeedDataSource({GraphQLClient? client})
    : _client = client ?? GraphQLConfig.client;
  static const _globalFeedQuery = r'''
    query GetGlobalFeed($limit: Int!, $offset: Int!) {
      answersCollection(
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

  static const _profileFeedQuery = r'''
    query GetProfileFeed($userId: UUID!, $limit: Int!, $offset: Int!) {
      answersCollection(
        filter: { user_id: { eq: $userId } }
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

  Future<List<FeedItemModel>> getGlobalFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_globalFeedQuery),
          variables: {'limit': limit, 'offset': offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL global feed error: ${result.exception}');
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        return FeedItemModel.fromGraphQL(edge['node'] as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FeedItemModel>> getProfileFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_profileFeedQuery),
          variables: {'userId': userId, 'limit': limit, 'offset': offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL profile feed error: ${result.exception}');
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        return FeedItemModel.fromGraphQL(edge['node'] as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Following feed: Answers from users you follow
  static const _followingFeedQuery = r'''
    query GetFollowingFeed($userId: UUID!, $limit: Int!, $offset: Int!) {
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

  Future<List<FeedItemModel>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_followingFeedQuery),
          variables: {'userId': userId, 'limit': limit, 'offset': offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL following feed error: ${result.exception}');
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        return FeedItemModel.fromGraphQL(edge['node'] as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FeedItemModel>> getUserFeed(
    String userId,
    String feedType, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      late final String query;
      late final Map<String, dynamic> variables;

      switch (feedType) {
        case 'profile':
          query = _profileFeedQuery;
          variables = {'userId': userId, 'limit': limit, 'offset': offset};
          break;
        case 'following':
          query = _followingFeedQuery;
          variables = {'userId': userId, 'limit': limit, 'offset': offset};
          break;
        case 'global':
        default:
          query = _globalFeedQuery;
          variables = {'limit': limit, 'offset': offset};
      }

      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL user feed error: ${result.exception}');
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        return FeedItemModel.fromGraphQL(edge['node'] as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
