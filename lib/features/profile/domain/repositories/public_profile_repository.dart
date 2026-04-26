import 'package:vibi/features/inbox/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';

abstract class PublicProfileRepository {
  Future<PublicProfile?> getPublicProfile(String userId, String? currentUserId);
  Future<PublicProfile?> getPublicProfileByUsername(
    String username,
    String? currentUserId,
  );
  Future<List<AnsweredQuestion>> getUserAnswers(String userId);
}
