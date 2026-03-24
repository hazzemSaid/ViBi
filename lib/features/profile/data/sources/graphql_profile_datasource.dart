import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  GraphQLProfileDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Lazy getter for GraphQL client
  GraphQLClient get _graphqlClient => GraphQLConfig.client;

  /// Fetch user profile using GraphQL query
  Future<UserProfileModel?> fetchProfile(String uid) async {
    const query = r'''
      query GetProfile($id: UUID!) {
        profilesCollection(filter: { id: { eq: $id } }) {
          edges {
            node {
              id
              full_name
              username
              bio
              avatar_url
              is_private
              allow_anonymous_questions
              public_profile_enabled
              public_theme_key
              public_cta_text
              updated_at
              created_at
              followers_count
              following_count
              answers_count
            }
          }
        }
      }
    ''';

    final result = await _graphqlClient.query(
      QueryOptions(document: gql(query), variables: {'id': uid}),
    );

    if (result.hasException) {
      print('GraphQL fetch profile error: ${result.exception}');
      return _fetchProfileViaRest(uid);
    }

    if (result.data == null) return _fetchProfileViaRest(uid);

    final edges = result.data!['profilesCollection']['edges'] as List?;
    if (edges == null || edges.isEmpty) {
      return _fetchProfileViaRest(uid);
    }

    final node = edges.first['node'] as Map<String, dynamic>;
    print('GraphQL fetch profile success: ${node}');
    return UserProfileModel.fromGraphQL(node);
  }

  Future<UserProfileModel?> _fetchProfileViaRest(String uid) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response != null) {
        return UserProfileModel.fromMap(Map<String, dynamic>.from(response));
      }

      // First-login safety net: if profile row does not exist yet, create it for current user.
      final currentUser = _client.auth.currentUser;
      if (currentUser?.id == uid) {
        await _client.from('profiles').insert({
          'id': uid,
          'username': currentUser?.userMetadata?['username'],
          'full_name':
              currentUser?.userMetadata?['full_name'] ??
              currentUser?.userMetadata?['name'],
          'avatar_url': currentUser?.userMetadata?['avatar_url'],
          'updated_at': DateTime.now().toIso8601String(),
        });

        final created = await _client
            .from('profiles')
            .select()
            .eq('id', uid)
            .maybeSingle();
        if (created != null) {
          return UserProfileModel.fromMap(Map<String, dynamic>.from(created));
        }
      }

      return null;
    } catch (e) {
      print('REST fallback fetch profile error: $e');
      return null;
    }
  }

  /// Update user profile using GraphQL mutation
  Future<void> updateProfile(UserProfileModel profile) async {
    print('=== GRAPHQL UPDATE PROFILE ===');
    print('User ID: ${profile.uid}');

    final result = await _graphqlClient.mutate(
      MutationOptions(
        document: gql(GraphQLMutations.updateProfile),
        variables: {
          'userId': profile.uid,
          'username': profile.username,
          'fullName': profile.name,
          'bio': profile.bio,
          'avatarUrl': profile.profileImageUrl,
          'isPrivate': profile.isPrivate,
          'allowAnonymousQuestions': profile.allowAnonymousQuestions,
          'publicProfileEnabled': profile.publicProfileEnabled,
          'publicThemeKey': profile.publicThemeKey,
          'publicCtaText': profile.publicCtaText,
        },
      ),
    );

    print('GraphQL response: ${result.data}');

    if (result.hasException) {
      print('GraphQL update profile error: ${result.exception}');
      throw Exception(
        'Failed to update profile: ${result.exception.toString()}',
      );
    }

    if (result.data == null) {
      throw Exception('Profile update failed: No response from server');
    }

    final records = result.data!['updateprofilesCollection']['records'];
    if (records == null || (records as List).isEmpty) {
      throw Exception('Profile update failed: No rows affected');
    }

    print('Profile updated successfully via GraphQL');
    print('==============================');
  }

  /// Upload profile image to storage
  Future<String> uploadProfileImage(String uid, File image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = 'avatar.$fileExt';
      final filePath = '$uid/$fileName';

      print('=== UPLOAD IMAGE DEBUG ===');
      print('File path: $filePath');
      print('File exists: ${image.existsSync()}');
      print('File size: ${image.lengthSync()} bytes');

      await _client.storage
          .from('avatars')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = _client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('Upload success, URL: $publicUrl');
      print('==========================');
      return publicUrl;
    } catch (e) {
      print('=== IMAGE UPLOAD ERROR ===');
      print('Error: $e');
      print('==========================');
      rethrow;
    }
  }

  /// Fetch public profile with follow status
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
              avatar_url
              is_private
              allow_anonymous_questions
              public_profile_enabled
              public_theme_key
              public_cta_text
              followers_count
              following_count
              answers_count
              updated_at
            }
          }
        }
      }
    ''';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL get public profile error: ${result.exception}');
        return _getPublicProfileViaRest(userId, currentUserId);
      }

      final edges = result.data?['profilesCollection']?['edges'] as List? ?? [];
      if (edges.isEmpty) return null;

      final node = edges.first['node'] as Map<String, dynamic>;

      return await _buildPublicProfileFromNode(
        node: node,
        currentUserId: currentUserId,
      );
    } catch (e) {
      print('Get public profile exception: $e');
      return _getPublicProfileViaRest(userId, currentUserId);
    }
  }

  /// Fetch public profile by username slug with follow status
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
              avatar_url
              is_private
              allow_anonymous_questions
              public_profile_enabled
              public_theme_key
              public_cta_text
              followers_count
              following_count
              answers_count
              updated_at
            }
          }
        }
      }
    ''';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'username': username},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL get public profile by username error: ${result.exception}');
        return _getPublicProfileByUsernameViaRest(username, currentUserId);
      }

      final edges = result.data?['profilesCollection']?['edges'] as List? ?? [];
      if (edges.isEmpty) return null;

      final node = edges.first['node'] as Map<String, dynamic>;
      return await _buildPublicProfileFromNode(
        node: node,
        currentUserId: currentUserId,
      );
    } catch (e) {
      print('Get public profile by username exception: $e');
      return _getPublicProfileByUsernameViaRest(username, currentUserId);
    }
  }

  Future<PublicProfileModel?> _getPublicProfileViaRest(
    String userId,
    String? currentUserId,
  ) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return await _buildPublicProfileFromNode(
        node: Map<String, dynamic>.from(response),
        currentUserId: currentUserId,
      );
    } catch (e) {
      print('REST get public profile error: $e');
      return null;
    }
  }

  Future<PublicProfileModel?> _getPublicProfileByUsernameViaRest(
    String username,
    String? currentUserId,
  ) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) return null;

      return await _buildPublicProfileFromNode(
        node: Map<String, dynamic>.from(response),
        currentUserId: currentUserId,
      );
    } catch (e) {
      print('REST get public profile by username error: $e');
      return null;
    }
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
    try {
      final result = await _client
          .from('follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      print('Check is following error: $e');
      return false;
    }
  }

  Future<bool> _checkHasRequestedFollow(
    String requesterId,
    String targetId,
  ) async {
    try {
      final result = await _client
          .from('follow_requests')
          .select()
          .eq('requester_id', requesterId)
          .eq('target_id', targetId)
          .eq('status', 'pending')
          .maybeSingle();
      return result != null;
    } catch (e) {
      print('Check follow request error: $e');
      return false;
    }
  }

  /// Get user's answered questions
  Future<List<AnsweredQuestionModel>> getUserAnswers(String userId) async {
    // Fetch all answers with related question and sender/answerer profile data via GraphQL
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
                  avatar_url
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
              avatar_url
            }
          }
        }
      }
    ''';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL get user answers error: ${result.exception}');
        return _getUserAnswersViaRest(userId);
      }

      // Extract answerer profile
      String? answererUsername;
      String? answererAvatarUrl;
      final answererEdges =
          result.data?['answererProfile']?['edges'] as List? ?? [];
      if (answererEdges.isNotEmpty) {
        final answererNode =
            answererEdges.first['node'] as Map<String, dynamic>;
        answererUsername = answererNode['username'] as String?;
        answererAvatarUrl = answererNode['avatar_url'] as String?;
      }

      final edges = result.data?['answersCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        final question = node['questions'] as Map<String, dynamic>?;

        String? senderUsername;
        String? senderAvatarUrl;

        if (question != null && !(question['is_anonymous'] as bool? ?? false)) {
          final senderProfile = question['profiles'] as Map<String, dynamic>?;
          if (senderProfile != null) {
            senderUsername = senderProfile['username'] as String?;
            senderAvatarUrl = senderProfile['avatar_url'] as String?;
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
          senderAvatarUrl: senderAvatarUrl,
          answererUsername: answererUsername,
          answererAvatarUrl: answererAvatarUrl,
        );
      }).toList();
    } catch (e) {
      print('Get user answers exception: $e');
      return _getUserAnswersViaRest(userId);
    }
  }

  Future<List<AnsweredQuestionModel>> _getUserAnswersViaRest(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('answers')
          .select('*, questions(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map(
            (row) =>
                AnsweredQuestionModel.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList();
    } catch (e) {
      print('REST get user answers error: $e');
      return [];
    }
  }

  /// Get user's followers list using GraphQL
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
                avatar_url
                bio
                followers_count
              }
            }
          }
        }
      }
    ''';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId, 'limit': limit, 'offset': offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL get followers error: ${result.exception}');
        return [];
      }

      final edges = result.data?['followsCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        final profileData = node['follower'] as Map<String, dynamic>? ?? {};
        return FollowerUserModel(
          id: profileData['id'] as String? ?? '',
          username: profileData['username'] as String?,
          fullName: profileData['full_name'] as String?,
          avatarUrl: profileData['avatar_url'] as String?,
          bio: profileData['bio'] as String?,
          followersCount: profileData['followers_count'] as int? ?? 0,
          followedAt: DateTime.parse(node['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      print('Get followers exception: $e');
      return [];
    }
  }

  /// Get user's following list using GraphQL
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
                avatar_url
                bio
                followers_count
              }
            }
          }
        }
      }
    ''';

    try {
      final result = await _graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {'userId': userId, 'limit': limit, 'offset': offset},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('GraphQL get following error: ${result.exception}');
        return [];
      }

      final edges = result.data?['followsCollection']?['edges'] as List? ?? [];

      return edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        final profileData = node['following'] as Map<String, dynamic>? ?? {};
        return FollowingUserModel(
          id: profileData['id'] as String? ?? '',
          username: profileData['username'] as String?,
          fullName: profileData['full_name'] as String?,
          avatarUrl: profileData['avatar_url'] as String?,
          bio: profileData['bio'] as String?,
          followersCount: profileData['followers_count'] as int? ?? 0,
          followedAt: DateTime.parse(node['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      print('Get following exception: $e');
      return [];
    }
  }
}
