class SocialLinksMutations {
  static const String addSocialLink = r'''
    mutation AddSocialLink(
      $userId: UUID!
      $platform: String!
      $url: String!
      $title: String
      $displayLabel: String
      $displayOrder: Int!
    ) {
      insertIntosocial_linksCollection(
        objects: [{
          user_id: $userId
          platform: $platform
          url: $url
          title: $title
          display_label: $displayLabel
          display_order: $displayOrder
          is_active: true
        }]
      ) {
        records {
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
  ''';

  static const String updateSocialLink = r'''
    mutation UpdateSocialLink(
      $id: UUID!
      $platform: String!
      $url: String!
      $title: String
      $displayLabel: String
      $displayOrder: Int!
      $isActive: Boolean!
    ) {
      updatesocial_linksCollection(
        set: {
          platform: $platform
          url: $url
          title: $title
          display_label: $displayLabel
          display_order: $displayOrder
          is_active: $isActive
        }
        filter: { id: { eq: $id } }
      ) {
        records {
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
  ''';

  static const String deleteSocialLink = r'''
    mutation DeleteSocialLink($id: UUID!) {
      deleteFromsocial_linksCollection(filter: { id: { eq: $id } }) {
        affectedCount
      }
    }
  ''';
}
