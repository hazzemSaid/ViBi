class StoryMutations {
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
