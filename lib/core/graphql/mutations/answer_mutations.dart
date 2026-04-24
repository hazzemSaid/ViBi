class AnswerMutations {
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
}
