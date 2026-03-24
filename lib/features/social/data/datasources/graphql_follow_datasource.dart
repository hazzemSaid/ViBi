import 'package:supabase_flutter/supabase_flutter.dart';

class GraphQLFollowDataSource {
  final SupabaseClient _client;

  GraphQLFollowDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Follow a user (for public profiles)
  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _client.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });

      // Update follower counts
      await _updateFollowerCounts(followingId, true);
      await _updateFollowingCounts(followerId, true);
    } catch (e) {
      print('Follow user error: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);

      // Update follower counts
      await _updateFollowerCounts(followingId, false);
      await _updateFollowingCounts(followerId, false);
    } catch (e) {
      print('Unfollow user error: $e');
      rethrow;
    }
  }

  /// Remove a follower (when someone follows you and you want to remove them)
  Future<void> removeFollower(String currentUserId, String followerId) async {
    try {
      // Delete the follow relationship where followerId follows currentUserId
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', currentUserId);

      // Update follower counts
      await _updateFollowerCounts(
        currentUserId,
        false,
      ); // Decrease current user's followers
      await _updateFollowingCounts(
        followerId,
        false,
      ); // Decrease follower's following count
    } catch (e) {
      print('Remove follower error: $e');
      rethrow;
    }
  }

  /// Request to follow a private profile
  Future<void> requestFollow(String requesterId, String targetId) async {
    try {
      // Check if request already exists
      final existing = await _client
          .from('follow_requests')
          .select()
          .eq('requester_id', requesterId)
          .eq('target_id', targetId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Follow request already sent');
      }

      await _client.from('follow_requests').insert({
        'requester_id': requesterId,
        'target_id': targetId,
        'status': 'pending',
      });
    } catch (e) {
      print('Request follow error: $e');
      rethrow;
    }
  }

  /// Respond to a follow request
  Future<void> respondToRequest(
    String requestId,
    bool accept,
    String targetId,
    String requesterId,
  ) async {
    try {
      if (accept) {
        // Update request status
        await _client
            .from('follow_requests')
            .update({'status': 'accepted'})
            .eq('id', requestId);

        // Create follow relationship
        await _client.from('follows').insert({
          'follower_id': requesterId,
          'following_id': targetId,
        });

        // Update follower counts
        await _updateFollowerCounts(targetId, true);
        await _updateFollowingCounts(requesterId, true);
      } else {
        // Update request status to rejected
        await _client
            .from('follow_requests')
            .update({'status': 'rejected'})
            .eq('id', requestId);
      }
    } catch (e) {
      print('Respond to request error: $e');
      rethrow;
    }
  }

  /// Check if user is following another user
  Future<bool> isFollowing(String followerId, String followingId) async {
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

  Future<void> _updateFollowerCounts(String userId, bool increment) async {
    try {
      // Fetch current count
      final profile = await _client
          .from('profiles')
          .select('followers_count')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        final currentCount = profile['followers_count'] as int? ?? 0;
        final newCount = increment
            ? currentCount + 1
            : (currentCount > 0 ? currentCount - 1 : 0);

        await _client
            .from('profiles')
            .update({'followers_count': newCount})
            .eq('id', userId);
      }
    } catch (e) {
      print('Update follower counts error: $e');
    }
  }

  Future<void> _updateFollowingCounts(String userId, bool increment) async {
    try {
      // Fetch current count
      final profile = await _client
          .from('profiles')
          .select('following_count')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        final currentCount = profile['following_count'] as int? ?? 0;
        final newCount = increment
            ? currentCount + 1
            : (currentCount > 0 ? currentCount - 1 : 0);

        await _client
            .from('profiles')
            .update({'following_count': newCount})
            .eq('id', userId);
      }
    } catch (e) {
      print('Update following counts error: $e');
    }
  }
}
