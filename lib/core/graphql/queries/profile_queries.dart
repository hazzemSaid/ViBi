/// GraphQL queries for profile-related operations
/// Fetches user profiles with all related data in a single request
class ProfileQueries {
  /// Get user profile with all related data
  /// Includes: social links, recent answers, active stories, followers/following
  /// This eliminates multiple REST API calls
  static const String getUserProfile = r'''
    query GetUserProfile($userId: UUID!) {
      profilesCollection(filter: { id: { eq: $userId } }) {
        edges {
          node {
            id
            username
            full_name
            avatar_url
            bio
            is_private
            allow_anonymous_questions
            public_profile_enabled
            public_theme_key
            public_cta_text
            followersCount: followsByFollowingId {
              totalCount
            }
            followingCount: followsByFollowerId {
              totalCount
            }
            questionsCount: questionsCollection {
              totalCount
            }
            answersCount: answersCollection {
              totalCount
            }
            created_at
            updated_at
            
            # Social links (JOIN - no N+1!)
            social_links: social_linksCollection(
              filter: { is_active: { eq: true } }
              orderBy: { display_order: AscNullsLast }
            ) {
              edges {
                node {
                  id
                  platform
                  url
                  title
                  display_label
                  display_order
                  created_at
                }
              }
            }
            
            # Recent answers (JOIN - no N+1!)
            answers: answersCollection(
              first: 20
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
                  
                  # Question for each answer
                  questions {
                    id
                    question_text
                    is_anonymous
                  }
                  
                  # Answer media
                  answer_media: answer_mediaCollection {
                    edges {
                      node {
                        id
                        media_url
                        media_type
                        thumbnail_url
                      }
                    }
                  }
                }
              }
            }
            
            # Active stories (JOIN - no N+1!)
            stories: storiesCollection(
              filter: { 
                expires_at: { gt: "now()" } 
              }
              orderBy: { created_at: AscNullsLast }
            ) {
              edges {
                node {
                  id
                  media_url
                  media_type
                  thumbnail_url
                  duration
                  views_count
                  created_at
                  expires_at
                }
              }
            }
          }
        }
      }
    }
  ''';

  /// Get user profile with followers list
  static const String getUserWithFollowers = r'''
    query GetUserWithFollowers($userId: UUID!, $limit: Int!, $offset: Int!) {
      profilesCollection(filter: { id: { eq: $userId } }) {
        edges {
          node {
            id
            username
            full_name
            avatar_url
            followersCount: followsByFollowingId {
              totalCount
            }
            
            # Followers (people who follow this user)
            followers: followsCollection(
              filter: { following_id: { eq: $userId } }
              first: $limit
              offset: $offset
            ) {
              edges {
                node {
                  follower_id
                  created_at
                  
                  # Follower profile
                  follower: profilesCollection(
                    filter: { id: { eq: $follower_id } }
                  ) {
                    edges {
                      node {
                        id
                        username
                        full_name
                        avatar_url
                        bio
                        followersCount: followsByFollowingId {
                          totalCount
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

  /// Get user profile with following list
  static const String getUserWithFollowing = r'''
    query GetUserWithFollowing($userId: UUID!, $limit: Int!, $offset: Int!) {
      profilesCollection(filter: { id: { eq: $userId } }) {
        edges {
          node {
            id
            username
            full_name
            avatar_url
            followingCount: followsByFollowerId {
              totalCount
            }
            
            # Following (people this user follows)
            following: followsCollection(
              filter: { follower_id: { eq: $userId } }
              first: $limit
              offset: $offset
            ) {
              edges {
                node {
                  following_id
                  created_at
                  
                  # Following profile
                  following_profile: profilesCollection(
                    filter: { id: { eq: $following_id } }
                  ) {
                    edges {
                      node {
                        id
                        username
                        full_name
                        avatar_url
                        bio
                        followersCount: followsByFollowingId {
                          totalCount
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

  /// Get user's pending questions (inbox)
  static const String getUserQuestions = r'''
    query GetUserQuestions($userId: UUID!, $status: String, $limit: Int!, $offset: Int!) {
      questionsCollection(
        filter: { 
          recipient_id: { eq: $userId }
          status: { eq: $status }
        }
        orderBy: { created_at: DescNullsLast }
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            question_text
            is_anonymous
            status
            created_at
            answered_at
            
            # Sender profile (if not anonymous)
            sender: profilesCollection(
              filter: { id: { eq: $sender_id } }
            ) {
              edges {
                node {
                  id
                  username
                  avatar_url
                }
              }
            }
            
            # Question media
            question_media: question_mediaCollection {
              edges {
                node {
                  id
                  media_url
                  media_type
                  thumbnail_url
                }
              }
            }
            
            # Answer (if already answered)
            answers: answersCollection {
              edges {
                node {
                  id
                  answer_text
                  likes_count
                  comments_count
                  created_at
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

  /// Get user notifications with all related data
  static const String getUserNotifications = r'''
    query GetUserNotifications($userId: UUID!, $limit: Int!, $offset: Int!) {
      notificationsCollection(
        filter: { user_id: { eq: $userId } }
        orderBy: { created_at: DescNullsLast }
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            notification_type
            content
            is_read
            created_at
            reference_id
            reference_type
            
            # Actor (who triggered the notification)
            actor: profilesCollection(
              filter: { id: { eq: $actor_id } }
            ) {
              edges {
                node {
                  id
                  username
                  avatar_url
                }
              }
            }
            
            # Referenced question (if applicable)
            question: questionsCollection(
              filter: { id: { eq: $reference_id } }
            ) {
              edges {
                node {
                  id
                  question_text
                }
              }
            }
            
            # Referenced answer (if applicable)
            answer: answersCollection(
              filter: { id: { eq: $reference_id } }
            ) {
              edges {
                node {
                  id
                  answer_text
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

  /// Check if current user follows target user
  static const String checkFollowStatus = r'''
    query CheckFollowStatus($currentUserId: UUID!, $targetUserId: UUID!) {
      followsCollection(
        filter: {
          follower_id: { eq: $currentUserId }
          following_id: { eq: $targetUserId }
        }
      ) {
        edges {
          node {
            id
            created_at
          }
        }
      }
    }
  ''';

  /// Search users by username
  static const String searchUsers = r'''
    query SearchUsers($searchTerm: String!, $limit: Int!, $offset: Int!) {
      profilesCollection(
        filter: {
          username: { ilike: $searchTerm }
        }
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            username
            full_name
            avatar_url
            bio
            is_private
            followersCount: followsByFollowingId {
              totalCount
            }
            answersCount: answersCollection {
              totalCount
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
