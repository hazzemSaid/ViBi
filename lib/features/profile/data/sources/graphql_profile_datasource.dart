import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/mutations/graphql_mutations.dart';
import 'package:vibi/features/profile/data/models/answered_question_model.dart';
import 'package:vibi/features/profile/data/models/follower_user_model.dart';
import 'package:vibi/features/profile/data/models/following_user_model.dart';
import 'package:vibi/features/profile/data/models/public_profile_model.dart';
import 'package:vibi/features/profile/data/models/user_profile_model.dart';

/// GraphQL-based Profile Data Source
/// Uses GraphQL mutations instead of REST for profile updates
/// Benefits:
/// - Eliminates N+1 queries
/// - Single network request for all data
/// - Better performance and reduced latency
class GraphQLProfileDataSource {
  final SupabaseClient _client;

  static const Set<String> _allowedPublicThemeKeys = {
    'tellonym_dark',
    'minimal_dark',
    'clean_light',
    'noir_dark',
    'ocean_dark',
    'forest_dark',
    'sunset_dark',
    'violet_dark',
    'amber_dark',
  };

  GraphQLProfileDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Lazy getter for GraphQL client
  GraphQLClient get _graphqlClient => GraphQLConfig.client;

  Either<String, List<String>> _parseAvatarUrls(dynamic value) {
    if (value == null) return right(const <String>[]);
    if (value is List) {
      return right(value.map((e) => e.toString()).toList());
    }
    if (value is String) return right(<String>[value]);
    return left('Invalid avatar URLs format received from server.');
  }

  String _normalizePublicThemeKey(String? themeKey) {
    if (themeKey == null || themeKey.isEmpty) {
      return 'tellonym_dark';
    }
    if (_allowedPublicThemeKeys.contains(themeKey)) {
      return themeKey;
    }
    return 'tellonym_dark';
  }

  /// Fetch user profile using GraphQL query
  Future<Either<String, UserProfileModel?>> fetchProfile(String uid) async {
    const query = r'''
      query GetProfile($id: UUID!) {
        profilesCollection(filter: { id: { eq: $id } }) {
          edges {
            node {
              id
              full_name
              username
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
              followersCount: followsByFollowingId(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              followingCount: followsByFollowerId(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              answersCount: answersCollection(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              updated_at
              created_at
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(document: gql(query), variables: {'id': uid}),
    );

    if (result.hasException) {
      return left(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    final edges = result.data?['profilesCollection']?['edges'] as List? ?? [];
    if (edges.isEmpty) {
      return left('Profile not found.');
    }

    final node = edges.first['node'] as Map<String, dynamic>;
    return right(UserProfileModel.fromGraphQL(node));
  }

  /// Update user profile using GraphQL mutation
  Future<void> updateProfile(UserProfileModel profile) async {
    final result = await _graphqlClient.mutate(
      MutationOptions(
        document: gql(GraphQLMutations.updateProfile),
        variables: {
          'userId': profile.uid,
          'username': profile.username,
          'fullName': profile.name,
          'bio': profile.bio,
          'avatarUrls': profile.avatarUrls,
          'isPrivate': profile.isPrivate,
          'allowAnonymousQuestions': profile.allowAnonymousQuestions,
          'publicProfileEnabled': profile.publicProfileEnabled,
          'publicThemeKey': _normalizePublicThemeKey(profile.publicThemeKey),
          'publicCtaText': profile.publicCtaText,
          'linkButtonStyle': profile.linkButtonStyle,
          'favColor': profile.favColor,
          'questionPlaceholder': profile.questionPlaceholder,
          'showSocialIcons': profile.showSocialIcons,
          'statusText': profile.statusText,
          'publicFontFamily': profile.publicFontFamily,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    final records = result.data?['updateprofilesCollection']?['records'];
    if (records == null || (records as List).isEmpty) {
      throw Exception('Profile update failed: No rows affected');
    }
  }

  /// Upload profile image to storage
  Future<String> uploadProfileImage(String uid, File image) async {
    try {
      final fileExt = image.path.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_$timestamp.$fileExt';
      final filePath = '$uid/$fileName';

      await _client.storage
          .from('avatars')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage.from('avatars').getPublicUrl(filePath);
    } catch (error) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(error));
    }
  }

  /// Upload avatar image and persist its URL into avatar_urls using GraphQL.
  Future<List<String>> uploadAndSaveAvatar(
    String uid,
    File image,
    List<String> currentAvatarUrls,
  ) async {
    final uploadedUrl = await uploadProfileImage(uid, image);
    final updatedUrls = <String>[
      ...currentAvatarUrls.where((e) => e.isNotEmpty),
      uploadedUrl,
    ];

    const mutation = r'''
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

    final result = await _graphqlClient.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'userId': uid,
          'avatarUrls': updatedUrls,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    return updatedUrls;
  }

  /// Upload one of up to three public profile images for web layout.
  Future<String> uploadPublicProfileImage(
    String uid,
    File image,
    int slot,
  ) async {
    if (slot < 1 || slot > 3) {
      throw ArgumentError('slot must be between 1 and 3');
    }

    try {
      final fileExt = image.path.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_image_${slot}_$timestamp.$fileExt';
      final filePath = '$uid/public_profile/$fileName';

      await _client.storage
          .from('avatars')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage.from('avatars').getPublicUrl(filePath);
    } catch (error) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(error));
    }
  }

  /// Fetch public profile with follow status.
  Future<PublicProfileModel?> getPublicProfile(
    String userId,
    String? currentUserId,
  ) async {
    const query = r'''
      query GetPublicProfile($id: UUID!) {
        profilesCollection(filter: { id: { eq: $id } }) {
          edges {
            node {
              id
              full_name
              username
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
              followersCount: followsByFollowingId(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              followingCount: followsByFollowerId(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              answersCount: answersCollection(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              updated_at
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'id': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    final edges = result.data?['profilesCollection']?['edges'] as List? ?? [];
    if (edges.isEmpty) return null;

    final node = edges.first['node'] as Map<String, dynamic>;
    return _buildPublicProfileFromNode(
      node: node,
      currentUserId: currentUserId,
    );
  }

  /// Fetch public profile by username slug with follow status.
  Future<PublicProfileModel?> getPublicProfileByUsername(
    String username,
    String? currentUserId,
  ) async {
    const query = r'''
      query GetPublicProfileByUsername($username: String!) {
        profilesCollection(filter: { username: { eq: $username } }) {
          edges {
            node {
              id
              full_name
              username
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
              followersCount: followsByFollowingId(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              followingCount: followsByFollowerId(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              answersCount: answersCollection(first: 1000) {
                edges {
                  node {
                    id
                  }
                }
              }
              updated_at
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'username': username},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    final edges = result.data?['profilesCollection']?['edges'] as List? ?? [];
    if (edges.isEmpty) return null;

    final node = edges.first['node'] as Map<String, dynamic>;
    return _buildPublicProfileFromNode(
      node: node,
      currentUserId: currentUserId,
    );
  }

  Future<PublicProfileModel> _buildPublicProfileFromNode({
    required Map<String, dynamic> node,
    required String? currentUserId,
  }) async {
    final targetUserId = node['id'] as String;
    bool isFollowing = false;
    bool hasRequestedFollow = false;

    if (currentUserId != null && currentUserId != targetUserId) {
      isFollowing = await _checkIsFollowing(currentUserId, targetUserId);
      if (!isFollowing) {
        hasRequestedFollow = await _checkHasRequestedFollow(
          currentUserId,
          targetUserId,
        );
      }
    }

    return PublicProfileModel.fromGraphQL(
      node,
      isFollowing: isFollowing,
      hasRequestedFollow: hasRequestedFollow,
    );
  }

  Future<bool> _checkIsFollowing(String followerId, String followingId) async {
    const query = r'''
      query CheckIsFollowing($followerId: UUID!, $followingId: UUID!) {
        followsCollection(
          filter: { follower_id: { eq: $followerId }, following_id: { eq: $followingId } }
          first: 1
        ) {
          edges {
            node {
              id
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'followerId': followerId, 'followingId': followingId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      return false;
    }

    final edges = result.data?['followsCollection']?['edges'] as List? ?? [];
    return edges.isNotEmpty;
  }

  Future<bool> _checkHasRequestedFollow(
    String requesterId,
    String targetId,
  ) async {
    const query = r'''
      query CheckHasRequestedFollow($requesterId: UUID!, $targetId: UUID!) {
        follow_requestsCollection(
          filter: {
            requester_id: { eq: $requesterId }
            target_id: { eq: $targetId }
            status: { eq: "pending" }
          }
          first: 1
        ) {
          edges {
            node {
              id
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'requesterId': requesterId, 'targetId': targetId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      return false;
    }

    final edges =
        result.data?['follow_requestsCollection']?['edges'] as List? ?? [];
    return edges.isNotEmpty;
  }

  /// Get user's answered questions.
  Future<List<AnsweredQuestionModel>> getUserAnswers(String userId) async {
    const query = r'''
      query GetUserAnswers($userId: UUID!) {
        answersCollection(
          filter: { user_id: { eq: $userId } }
          orderBy: [{ created_at: DescNullsLast }]
          first: 50
        ) {
          edges {
            node {
              id
              user_id
              answer_text
              likes_count
              comments_count
              shares_count
              created_at
              questions {
                id
                question_text
                is_anonymous
                sender_id
                profiles {
                  id
                  username
                  avatar_urls
                }
              }
            }
          }
        }
        answererProfile: profilesCollection(filter: { id: { eq: $userId } }) {
          edges {
            node {
              id
              username
              avatar_urls
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    String? answererUsername;
    List<String> answererAvatarUrls = const <String>[];
    final answererEdges =
        result.data?['answererProfile']?['edges'] as List? ?? [];
    if (answererEdges.isNotEmpty) {
      final answererNode = answererEdges.first['node'] as Map<String, dynamic>;
      answererUsername = answererNode['username'] as String?;
      answererAvatarUrls = _parseAvatarUrls(
        answererNode['avatar_urls'],
      ).getOrElse(() => const <String>[]);
    }

    final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

    return edges.map((edge) {
      final node = edge['node'] as Map<String, dynamic>;
      final question = node['questions'] as Map<String, dynamic>?;

      String? senderUsername;
      List<String> senderAvatarUrls = const <String>[];

      if (question != null && !(question['is_anonymous'] as bool? ?? false)) {
        final senderProfile = question['profiles'] as Map<String, dynamic>?;
        if (senderProfile != null) {
          senderUsername = senderProfile['username'] as String?;
          senderAvatarUrls = _parseAvatarUrls(
            senderProfile['avatar_urls'],
          ).getOrElse(() => const <String>[]);
        }
      }

      return AnsweredQuestionModel(
        id: node['id'] as String,
        userId: node['user_id'] as String,
        questionText: question?['question_text'] as String? ?? '',
        answerText: node['answer_text'] as String? ?? '',
        likesCount: node['likes_count'] as int? ?? 0,
        commentsCount: node['comments_count'] as int? ?? 0,
        sharesCount: node['shares_count'] as int? ?? 0,
        createdAt: node['created_at'] != null
            ? DateTime.parse(node['created_at'] as String)
            : DateTime.now(),
        isAnonymous: question?['is_anonymous'] as bool? ?? false,
        senderUsername: senderUsername,
        senderAvatarUrl: senderAvatarUrls.isNotEmpty
            ? senderAvatarUrls.first
            : null,
        answererUsername: answererUsername,
        answererAvatarUrl: answererAvatarUrls.isNotEmpty
            ? answererAvatarUrls.first
            : null,
      );
    }).toList();
  }

  /// Get user's followers list using GraphQL.
  Future<List<FollowerUserModel>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    const query = r'''
      query GetFollowers($userId: UUID!, $limit: Int!, $offset: Int!) {
        followsCollection(
          filter: { following_id: { eq: $userId } }
          orderBy: [{ created_at: DescNullsLast }]
          first: $limit
          offset: $offset
        ) {
          edges {
            node {
              id
              created_at
              follower {
                id
                username
                avatar_urls
                bio
              }
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'userId': userId, 'limit': limit, 'offset': offset},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    final edges = result.data?['followsCollection']?['edges'] as List? ?? [];

    return edges.map((edge) {
      final node = edge['node'] as Map<String, dynamic>;
      final profileData = node['follower'] as Map<String, dynamic>? ?? {};
      final avatarUrls = _parseAvatarUrls(
        profileData['avatar_urls'],
      ).getOrElse(() => const <String>[]);
      return FollowerUserModel(
        id: profileData['id'] as String? ?? '',
        username: profileData['username'] as String?,
        fullName: profileData['full_name'] as String?,
        avatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
        bio: profileData['bio'] as String?,
        followersCount: 0,
        followedAt: DateTime.parse(node['created_at'] as String),
      );
    }).toList();
  }

  /// Get user's following list using GraphQL.
  Future<List<FollowingUserModel>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    const query = r'''
      query GetFollowing($userId: UUID!, $limit: Int!, $offset: Int!) {
        followsCollection(
          filter: { follower_id: { eq: $userId } }
          orderBy: [{ created_at: DescNullsLast }]
          first: $limit
          offset: $offset
        ) {
          edges {
            node {
              id
              created_at
              following {
                id
                username
                avatar_urls
                bio
              }
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(
        document: gql(query),
        variables: {'userId': userId, 'limit': limit, 'offset': offset},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(SupabaseErrorHandler.getErrorMessage(result.exception));
    }

    final edges = result.data?['followsCollection']?['edges'] as List? ?? [];

    return edges.map((edge) {
      final node = edge['node'] as Map<String, dynamic>;
      final profileData = node['following'] as Map<String, dynamic>? ?? {};
      final avatarUrls = _parseAvatarUrls(
        profileData['avatar_urls'],
      ).getOrElse(() => const <String>[]);
      return FollowingUserModel(
        id: profileData['id'] as String? ?? '',
        username: profileData['username'] as String?,
        fullName: profileData['full_name'] as String?,
        avatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
        bio: profileData['bio'] as String?,
        followersCount: 0,
        followedAt: DateTime.parse(node['created_at'] as String),
      );
    }).toList();
  }
}
