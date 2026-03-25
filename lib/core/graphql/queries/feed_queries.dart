/// GraphQL queries for feed-related operations
/// These queries fetch all related data in a single request, avoiding N+1 problems
class FeedQueries {
  /// Get global feed with all related data
  /// Fetches: answers, user profiles, questions, media, and top comments
  /// This replaces multiple REST API calls with a single GraphQL query
  static const String getGlobalFeed = r'''
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
            updated_at
            user_id
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  /// Get following feed (answers from users you follow)
  /// Single query that fetches follows, then their answers with all details
  static const String getFollowingFeed = r'''
    query GetFollowingFeed($userId: UUID!, $limit: Int!, $offset: Int!) {
      # First get all follows
      followsCollection(
        filter: { follower_id: { eq: $userId } }
      ) {
        edges {
          node {
            following_id
            
            # Get the followed user's answers
            following: profilesCollection(
              filter: { id: { eq: $following_id } }
            ) {
              edges {
                node {
                  id
                  username
                  avatar_url
                  
                  # Their answers
                  answers: answersCollection(
                    first: $limit
                    offset: $offset
                    orderBy: { created_at: DescNullsLast }
                  ) {
                    edges {
                      node {
                        id
                        answer_text
                        likes_count
                        comments_count
                        shares_count
                        created_at
                        
                        # Question
                        questions {
                          id
                          question_text
                          is_anonymous
                        }
                        
                        # Media
                        answer_media: answer_mediaCollection {
                          edges {
                            node {
                              media_url
                              media_type
                              thumbnail_url
                            }
                          }
                        }
                        
                        # Top comments
                        comments: commentsCollection(first: 2) {
                          edges {
                            node {
                              id
                              body
                              profiles {
                                username
                                avatar_url
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  /// Get a single answer with all details
  static const String getAnswerById = r'''
    query GetAnswerById($answerId: UUID!) {
      answersCollection(filter: { id: { eq: $answerId } }) {
        edges {
          node {
            id
            answer_text
            likes_count
            comments_count
            shares_count
            created_at
            updated_at
            
            profiles {
              id
              username
              full_name
              avatar_url
              bio
            }
            
            questions {
              id
              question_text
              is_anonymous
              sender_id
              sender: profiles {
                username
                avatar_url
              }
            }
            
            answer_media: answer_mediaCollection(
              orderBy: { display_order: AscNullsLast }
            ) {
              edges {
                node {
                  id
                  media_url
                  media_type
                  thumbnail_url
                  display_order
                }
              }
            }
            
            # All comments (not just top 3)
            comments: commentsCollection(
              orderBy: { created_at: AscNullsLast }
            ) {
              edges {
                node {
                  id
                  body
                  likes_count
                  created_at
                  updated_at
                  profiles {
                    id
                    username
                    avatar_url
                  }
                }
              }
            }
            
            # Likes
            likes: likesCollection(
              filter: { likeable_type: { eq: "answer" } }
            ) {
              edges {
                node {
                  id
                  user_id
                  created_at
                  profiles {
                    username
                    avatar_url
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  /// Get trending answers (based on trending_scores table)
  static const String getTrendingFeed = r'''
    query GetTrendingFeed($limit: Int!, $offset: Int!) {
      trending_scoresCollection(
        orderBy: { score: DescNullsLast }
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            score
            calculated_at
            
            # Answer with all details
            answers {
              id
              answer_text
              likes_count
              comments_count
              shares_count
              created_at
              
              profiles {
                id
                username
                avatar_url
              }
              
              questions {
                question_text
                is_anonymous
              }
              
              answer_media: answer_mediaCollection {
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
        pageInfo {
          hasNextPage
        }
      }
    }
  ''';
}
