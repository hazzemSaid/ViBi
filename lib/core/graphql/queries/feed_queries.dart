class FeedQueries {
  static const String getGlobalFeedItems = r'''
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

  static const String getFollowingFeedItems = r'''
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
}
