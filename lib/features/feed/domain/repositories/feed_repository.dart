import 'package:vibi/features/feed/domain/entities/feed_item.dart';

abstract class FeedRepository {
  // Get user's profile feed (answers they posted)
  Future<List<FeedItem>> getProfileFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  // Get global feed (all recent answers)
  Future<List<FeedItem>> getGlobalFeed({int limit = 20, int offset = 0});

  // Get following feed (answers from users they follow)
  Future<List<FeedItem>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  // Get all feed items for a user (filtered by feed_type)
  Future<List<FeedItem>> getUserFeed(
    String userId,
    String feedType, {
    int limit = 20,
    int offset = 0,
  });
}
