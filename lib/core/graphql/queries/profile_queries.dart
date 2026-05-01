class ProfileQueries {
  static const String getProfile = r'''
    query GetProfile($id: UUID!) {
      profilesCollection(filter: { id: { eq: $id } }) {
        edges {
          node {
            id
            full_name
            username
            bio
            avatar_urls
            is_private
            allow_anonymous_questions
            public_profile_enabled
            public_cta_text
            fav_color
            question_placeholder
            show_social_icons
            status_text
            public_font_family
            is_verified
            backgroundcolor
            followersCount: followsByFollowingId(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            followingCount: followsByFollowerId(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            answersCount: answersCollection(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            updated_at
            created_at
          }
        }
      }
    }
  ''';

  static const String getPublicProfile = r'''
    query GetPublicProfile($id: UUID!) {
      profilesCollection(filter: { id: { eq: $id } }) {
        edges {
          node {
            id
            full_name
            username
            bio
            avatar_urls
            is_private
            allow_anonymous_questions
            public_profile_enabled
            public_cta_text
            fav_color
            question_placeholder
            show_social_icons
            status_text
            public_font_family
            is_verified
            backgroundcolor
            followersCount: followsByFollowingId(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            followingCount: followsByFollowerId(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            answersCount: answersCollection(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            updated_at
          }
        }
      }
    }
  ''';

  static const String getPublicProfileByUsername = r'''
    query GetPublicProfileByUsername($username: String!) {
      profilesCollection(filter: { username: { eq: $username } }) {
        edges {
          node {
            id
            full_name
            username
            bio
            avatar_urls
            is_private
            allow_anonymous_questions
            public_profile_enabled
            public_cta_text
            fav_color
            question_placeholder
            show_social_icons
            status_text
            public_font_family
            is_verified
            backgroundcolor
            followersCount: followsByFollowingId(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            followingCount: followsByFollowerId(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            answersCount: answersCollection(first: 1000) {
              edges {
                node {
                  id
                }
              }
            }
            updated_at
          }
        }
      }
    }
  ''';

  static const String checkIsFollowing = r'''
    query CheckIsFollowing($followerId: UUID!, $followingId: UUID!) {
      followsCollection(
        filter: { follower_id: { eq: $followerId }, following_id: { eq: $followingId } }
        first: 1
      ) {
        edges {
          node {
            id
          }
        }
      }
    }
  ''';

  static const String checkHasRequestedFollow = r'''
    query CheckHasRequestedFollow($requesterId: UUID!, $targetId: UUID!) {
      follow_requestsCollection(
        filter: {
          requester_id: { eq: $requesterId }
          target_id: { eq: $targetId }
          status: { eq: "pending" }
        }
        first: 1
      ) {
        edges {
          node {
            id
          }
        }
      }
    }
  ''';

  static const String getUserAnswers = r'''
    query GetUserAnswers($userId: UUID!) {
      answersCollection(
        filter: { user_id: { eq: $userId } }
        orderBy: [{ created_at: DescNullsLast }]
        first: 50
      ) {
        edges {
          node {
            id
            user_id
            answer_text
            likes_count
            comments_count
            shares_count
            created_at
            questions {
              id
              question_text
              is_anonymous
              sender_id
              profiles {
                id
                username
                avatar_urls
              }
            }
          }
        }
      }
      answererProfile: profilesCollection(filter: { id: { eq: $userId } }) {
        edges {
          node {
            id
            username
            avatar_urls
          }
        }
      }
    }
  ''';

  static const String getFollowers = r'''
    query GetFollowers($userId: UUID!, $limit: Int!, $offset: Int!) {
      followsCollection(
        filter: { following_id: { eq: $userId } }
        orderBy: [{ created_at: DescNullsLast }]
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            created_at
            follower {
              id
              username
              avatar_urls
              bio
            }
          }
        }
      }
    }
  ''';

  static const String getFollowing = r'''
    query GetFollowing($userId: UUID!, $limit: Int!, $offset: Int!) {
      followsCollection(
        filter: { follower_id: { eq: $userId } }
        orderBy: [{ created_at: DescNullsLast }]
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            created_at
            following {
              id
              username
              avatar_urls
              bio
            }
          }
        }
      }
    }
  ''';
}
