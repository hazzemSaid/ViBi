import 'package:dartz/dartz.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/domain/repositories/feed_repository.dart';

class GetGlobalFeedUseCase {
  final FeedRepository _repository;

  const GetGlobalFeedUseCase(this._repository);

  Future<Either<String, List<FeedItem>>> call({
    required int limit,
    required int offset,
  }) {
    return _repository.getGlobalFeed(limit: limit, offset: offset);
  }
}
