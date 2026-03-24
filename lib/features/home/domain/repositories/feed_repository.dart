import 'package:vibi/features/home/domain/entities/feed_item.dart';

abstract class FeedRepository {
  Future<List<FeedItem>> getGlobalFeed({int limit = 20, int offset = 0});
  Future<List<FeedItem>> getFollowingFeed(
    String userId, {
    int limit = 20,
    int offset = 0,
  });
}
