import 'package:vibi/features/home/data/models/feed_item_model.dart';

/// Abstract interface for feed data sources
/// Allows switching between REST (Supabase) and GraphQL implementations
abstract class FeedDataSource {
  Future<List<FeedItemModel>> getGlobalFeed({int limit = 20, int offset = 0});

  Future<List<FeedItemModel>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  });
}
