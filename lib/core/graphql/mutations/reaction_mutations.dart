class ReactionMutations {
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
}
