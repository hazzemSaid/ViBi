import 'package:dartz/dartz.dart';
import 'package:vibi/features/follow/domain/entities/following_user.dart';
import 'package:vibi/features/follow/domain/repositories/follow_repository.dart';

class GetFollowingUseCase {
  final FollowRepository followRepository;

  GetFollowingUseCase(this.followRepository);

  Future<Either<String, List<FollowingUser>>> call(String userId) async {
    return followRepository.getFollowing(userId);
  }
}
