class SocialLinksQueries {
  static const String getSocialLinks = r'''
    query GetSocialLinks($userId: UUID!) {
      social_linksCollection(
        filter: { user_id: { eq: $userId } }
        orderBy: [{ display_order: AscNullsLast }]
      ) {
        edges {
          node {
            id
            user_id
            platform
            url
            title
            display_label
            display_order
            is_active
            created_at
            updated_at
          }
        }
      }
    }
  ''';
}
