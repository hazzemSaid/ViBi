class SocialMutations {
  /// Follow a user
  static const String followUser = r'''
    mutation FollowUser($followerId: UUID!, $followingId: UUID!) {
      insertIntoFollowsCollection(
        objects: [{
          follower_id: $followerId
          following_id: $followingId
        }]
      ) {
        records {
          id
          created_at
        }
      }
    }
  ''';

  /// Unfollow a user
  static const String unfollowUser = r'''
    mutation UnfollowUser($followerId: UUID!, $followingId: UUID!) {
      deleteFromFollowsCollection(
        filter: {
          follower_id: { eq: $followerId }
          following_id: { eq: $followingId }
        }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// Remove a follower
  static const String removeFollower = r'''
    mutation RemoveFollower($followerId: UUID!, $followingId: UUID!) {
      deleteFromFollowsCollection(
        filter: {
          follower_id: { eq: $followerId }
          following_id: { eq: $followingId }
        }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// Bookmark an answer
  static const String bookmarkAnswer = r'''
    mutation BookmarkAnswer($userId: UUID!, $answerId: UUID!) {
      insertIntoBookmarksCollection(
        objects: [{
          user_id: $userId
          answer_id: $answerId
        }]
      ) {
        records {
          id
          created_at
        }
      }
    }
  ''';

  /// Remove bookmark
  static const String removeBookmark = r'''
    mutation RemoveBookmark($userId: UUID!, $answerId: UUID!) {
      deleteFromBookmarksCollection(
        filter: {
          user_id: { eq: $userId }
          answer_id: { eq: $answerId }
        }
      ) {
        records {
          id
        }
      }
    }
  ''';
}
