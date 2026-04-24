class InboxQueries {
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
