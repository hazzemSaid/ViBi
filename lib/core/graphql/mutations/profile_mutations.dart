class ProfileMutations {
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
      $publicCtaText: String
      $favColor: String
      $questionPlaceholder: String
      $showSocialIcons: Boolean
      $statusText: String
      $publicFontFamily: String
      $backgroundcolor: String
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
          public_cta_text: $publicCtaText
          fav_color: $favColor
          question_placeholder: $questionPlaceholder
          show_social_icons: $showSocialIcons
          status_text: $statusText
          public_font_family: $publicFontFamily
          backgroundcolor: $backgroundcolor
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
          public_cta_text
          fav_color
          question_placeholder
          show_social_icons
          status_text
          public_font_family
          backgroundcolor
          is_verified
          updated_at
          created_at
        }
      }
    }
  ''';

  static const String updateAvatarUrls = r'''
    mutation UpdateAvatarUrls($userId: UUID!, $avatarUrls: [String!], $updatedAt: Datetime!) {
      updateprofilesCollection(
        filter: { id: { eq: $userId } }
        set: { avatar_urls: $avatarUrls, updated_at: $updatedAt }
      ) {
        records {
          id
        }
      }
    }
  ''';
}
