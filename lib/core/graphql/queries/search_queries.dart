class SearchQueries {
  static const String searchUsers = r'''
    query SearchUsers($query: String!) {
      profilesCollection(
        filter: {
          or: [
            { username: { ilike: $query } }
            { full_name: { ilike: $query } }
          ]
        }
        first: 50
      ) {
        edges {
          node {
            id
            full_name
            username
            bio
            avatar_urls
            followersCount: followsByFollowingId {
              totalCount
            }
            answersCount: answersCollection {
              totalCount
            }
            is_private
          }
        }
      }
    }
  ''';

  static const String searchContent = r'''
    query SearchContent($query: String!) {
      answersCollection(
        filter: {
          or: [
            { answer_text: { ilike: $query } }
          ]
        }
        orderBy: [{ created_at: DescNullsLast }]
        first: 50
      ) {
        edges {
          node {
            id
            user_id
            answer_text
            likes_count
            created_at
            questions {
              question_text
              is_anonymous
            }
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
