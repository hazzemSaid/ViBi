class FeedQueries {
  /// Queries all answers globally (for the "For You" tab).
  static const String getGlobalFeedItems = r'''
    query GetGlobalFeedItems($limit: Int!, $offset: Int!) {
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
              avatar_urls
            }
            questions {
              id
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
              question_mediaCollection {
                edges {
                  node {
                    media_url
                    media_type
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String getFollowingUserIds = r'''
    query GetFollowingUserIds($userId: UUID!) {
      followsCollection(
        filter: { follower_id: { eq: $userId } }
        first: 1000
      ) {
        edges {
          node {
            following_id
          }
        }
      }
    }
  ''';

  static const String getFollowingFeedItems = r'''
    query GetFollowingFeedItems($userIds: [UUID!]!, $limit: Int!, $offset: Int!) {
      answersCollection(
        filter: { user_id: { in: $userIds } }
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
              question_mediaCollection {
                edges {
                  node {
                    media_url
                    media_type
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
}
