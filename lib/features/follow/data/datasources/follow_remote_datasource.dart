import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/queries/profile_queries.dart';
import 'package:vibi/features/follow/data/models/follower_user_model.dart';
import 'package:vibi/features/follow/data/models/following_user_model.dart';
import 'package:vibi/features/follow/data/datasources/follow_datasource.dart';

class FollowRemoteDatasource implements FollowDataSource {
  final SupabaseClient _client;
  final ferry.Client _ferryClient;

  FollowRemoteDatasource({SupabaseClient? client, ferry.Client? ferryClient})
    : _client = client ?? Supabase.instance.client,
      _ferryClient = ferryClient ?? GraphQLConfig.ferryClient;

  /// Follow a user (for public profiles)
  @override
  Future<Either<String, void>> followUser(
    String followerId,
    String followingId,
  ) async {
    try {
      await _client.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
      return right(null);
    } catch (e) {
      print('Follow user error: $e');
      return left('Failed to follow user');
    }
  }

  /// Unfollow a user
  @override
  Future<Either<String, void>> unfollowUser(
    String followerId,
    String followingId,
  ) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      return right(null);
    } catch (e) {
      print('Unfollow user error: $e');
      return left('Failed to unfollow user');
    }
  }

  /// Remove a follower (when someone follows you and you want to remove them)
  @override
  Future<Either<String, void>> removeFollower(
    String currentUserId,
    String followerId,
  ) async {
    try {
      // Delete the follow relationship where followerId follows currentUserId
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', currentUserId);
      return right(null);
    } catch (e) {
      print('Remove follower error: $e');
      return left('Failed to remove follower');
    }
  }

  /** Checks whether one user follows another user. */
  @override
  Future<Either<String, bool>> isFollowing(
    String followerId,
    String followingId,
  ) async {
    try {
      final result = await _client
          .from('follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();
      return right(result != null);
    } catch (e) {
      print('Check is following error: $e');
      return left('Failed to check if following');
    }
  }

  /// Get user's following list using GraphQL.
  @override
  Future<Either<String, List<FollowingUserModel>>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await GraphQLConfig.ferryQuery(
      'GetFollowing',
      document: ProfileQueries.getFollowing,
      variables: {'userId': userId, 'limit': limit, 'offset': offset},
      clientOverride: _ferryClient,
    );

    if (result.hasErrors) {
      return left(SupabaseErrorHandler.getErrorMessage(result));
    }

    final edges = result.data?['followsCollection']?['edges'] as List? ?? [];

    return right(
      edges.map((edge) {
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
      }).toList(),
    );
  }

  /// Get user's followers list using GraphQL.
  @override
  Future<Either<String, List<FollowerUserModel>>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await GraphQLConfig.ferryQuery(
      'GetFollowers',
      document: ProfileQueries.getFollowers,
      variables: {'userId': userId, 'limit': limit, 'offset': offset},
      clientOverride: _ferryClient,
    );

    if (result.hasErrors) {
      return left(SupabaseErrorHandler.getErrorMessage(result));
    }

    final edges = result.data?['followsCollection']?['edges'] as List? ?? [];

    return right(
      edges.map((edge) {
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
      }).toList(),
    );
  }

  Either<String, List<String>> _parseAvatarUrls(dynamic value) {
    if (value == null) return right(const <String>[]);
    if (value is List) {
      return right(value.map((e) => e.toString()).toList());
    }
    if (value is String) return right(<String>[value]);
    return left('Invalid avatar URLs format received from server.');
  }
}
