/**
 * Contains GraphQL query definitions for the inbox feature.
 */
class InboxQueries {
  /**
   * Operation name for fetching pending questions.
   */
  static const String getPendingQuestionsOpName = 'GetPendingQuestions';

  /**
   * Query to fetch questions for a specific user filtered by status, with pagination support.
   * Includes details about the question and the sender's profile.
   */
  static const String getPendingQuestions = r'''
    query GetPendingQuestions($currentUserId: UUID!, $limit: Int!, $offset: Int!, $statuses: [String!]!) {
      questionsCollection(
        filter: {
          recipient_id: { eq: $currentUserId }
          status: { in: $statuses }
        }
        orderBy: [{ created_at: DescNullsLast }]
        first: $limit
        offset: $offset
      ) {
        edges {
          node {
            id
            recipient_id
            sender_id
            question_text
            question_type
            media_rec_id
            is_anonymous
            status
            created_at
            profiles {
              username
              avatar_urls
            }
          }
        }
      }
    }
  ''';
}

