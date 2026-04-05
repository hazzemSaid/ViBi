/// GraphQL mutations for creating, updating, and deleting data
class GraphQLMutations {
  /// Create a new answer
  static const String createAnswer = r'''
    mutation CreateAnswer($questionId: UUID!, $userId: UUID!, $answerText: String!) {
      insertIntoAnswersCollection(
        objects: [{
          question_id: $questionId
          user_id: $userId
          answer_text: $answerText
        }]
      ) {
        records {
          id
          answer_text
          created_at
        }
      }
    }
  ''';

  /// Update an answer
  static const String updateAnswer = r'''
    mutation UpdateAnswer($answerId: UUID!, $answerText: String!) {
      updateAnswersCollection(
        filter: { id: { eq: $answerId } }
        set: { answer_text: $answerText }
      ) {
        records {
          id
          answer_text
          updated_at
        }
      }
    }
  ''';

  /// Delete an answer
  static const String deleteAnswer = r'''
    mutation DeleteAnswer($answerId: UUID!) {
      deleteFromAnswersCollection(
        filter: { id: { eq: $answerId } }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// Like an answer
  static const String likeAnswer = r'''
    mutation LikeAnswer($userId: UUID!, $answerId: UUID!) {
      insertIntoLikesCollection(
        objects: [{
          user_id: $userId
          likeable_type: "answer"
          likeable_id: $answerId
        }]
      ) {
        records {
          id
          created_at
        }
      }
    }
  ''';

  /// Unlike an answer
  static const String unlikeAnswer = r'''
    mutation UnlikeAnswer($userId: UUID!, $answerId: UUID!) {
      deleteFromLikesCollection(
        filter: {
          user_id: { eq: $userId }
          likeable_type: { eq: "answer" }
          likeable_id: { eq: $answerId }
        }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// Add a comment
  static const String createComment = r'''
    mutation CreateComment($answerId: UUID!, $userId: UUID!, $body: String!) {
      insertIntoCommentsCollection(
        objects: [{
          answer_id: $answerId
          user_id: $userId
          body: $body
        }]
      ) {
        records {
          id
          body
          created_at
          profiles {
            username
            avatar_urls
          }
        }
      }
    }
  ''';

  /// Upsert a reaction on an answer
  static const String upsertReaction = r'''
    mutation UpsertReaction($answerId: UUID!, $userId: UUID!, $reaction: String!) {
      insertIntoReactionsCollection(
        objects: [{
          answer_id: $answerId
          user_id: $userId
          reaction: $reaction
        }]
        onConflict: {
          constraint: reactions_answer_id_user_id_key
          updateColumns: [reaction]
        }
      ) {
        records {
          id
          answer_id
          user_id
          reaction
          created_at
        }
      }
    }
  ''';

  /// Remove reaction from an answer
  static const String deleteReaction = r'''
    mutation DeleteReaction($answerId: UUID!, $userId: UUID!) {
      deleteFromReactionsCollection(
        filter: {
          answer_id: { eq: $answerId }
          user_id: { eq: $userId }
        }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// Delete a comment
  static const String deleteComment = r'''
    mutation DeleteComment($commentId: UUID!) {
      deleteFromCommentsCollection(
        filter: { id: { eq: $commentId } }
      ) {
        records {
          id
        }
      }
    }
  ''';

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

  /// Remove a follower (when someone follows you and you want to remove them)
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

  /// Update profile
  static const String updateProfile = r'''
    mutation UpdateProfile(
      $userId: UUID!
      $username: String
      $fullName: String
      $bio: String
      $avatarUrls: [String]
      $isPrivate: Boolean
      $allowAnonymousQuestions: Boolean
      $publicProfileEnabled: Boolean
      $publicThemeKey: String
      $publicCtaText: String
      $linkButtonStyle: String
      $favColor: String
      $questionPlaceholder: String
      $showSocialIcons: Boolean
      $statusText: String
      $publicFontFamily: String
    ) {
      updateprofilesCollection(
        filter: { id: { eq: $userId } }
        set: {
          username: $username
          full_name: $fullName
          bio: $bio
          avatar_urls: $avatarUrls
          is_private: $isPrivate
          allow_anonymous_questions: $allowAnonymousQuestions
          public_profile_enabled: $publicProfileEnabled
          public_theme_key: $publicThemeKey
          public_cta_text: $publicCtaText
          link_button_style: $linkButtonStyle
          fav_color: $favColor
          question_placeholder: $questionPlaceholder
          show_social_icons: $showSocialIcons
          status_text: $statusText
          public_font_family: $publicFontFamily
        }
      ) {
        records {
          id
          username
          full_name
          bio
          avatar_urls
          is_private
          allow_anonymous_questions
          public_profile_enabled
          public_theme_key
          public_cta_text
          link_button_style
          fav_color
          question_placeholder
          show_social_icons
          status_text
          public_font_family
          is_verified
          updated_at
        }
      }
    }
  ''';

  /// Mark notification as read
  static const String markNotificationRead = r'''
    mutation MarkNotificationRead($notificationId: UUID!) {
      updateNotificationsCollection(
        filter: { id: { eq: $notificationId } }
        set: { is_read: true }
      ) {
        records {
          id
          is_read
        }
      }
    }
  ''';

  /// Mark all notifications as read
  static const String markAllNotificationsRead = r'''
    mutation MarkAllNotificationsRead($userId: UUID!) {
      updateNotificationsCollection(
        filter: { 
          user_id: { eq: $userId }
          is_read: { eq: false }
        }
        set: { is_read: true }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// Create a story
  static const String createStory = r'''
    mutation CreateStory(
      $userId: UUID!
      $mediaUrl: String!
      $mediaType: String!
      $thumbnailUrl: String
      $duration: Int
    ) {
      insertIntoStoriesCollection(
        objects: [{
          user_id: $userId
          media_url: $mediaUrl
          media_type: $mediaType
          thumbnail_url: $thumbnailUrl
          duration: $duration
        }]
      ) {
        records {
          id
          media_url
          media_type
          created_at
          expires_at
        }
      }
    }
  ''';

  /// Delete a story
  static const String deleteStory = r'''
    mutation DeleteStory($storyId: UUID!) {
      deleteFromStoriesCollection(
        filter: { id: { eq: $storyId } }
      ) {
        records {
          id
        }
      }
    }
  ''';

  /// View a story
  static const String viewStory = r'''
    mutation ViewStory($storyId: UUID!, $viewerId: UUID!) {
      insertIntoStory_viewsCollection(
        objects: [{
          story_id: $storyId
          viewer_id: $viewerId
        }]
      ) {
        records {
          id
          viewed_at
        }
      }
    }
  ''';
}
