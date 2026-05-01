import 'package:dartz/dartz.dart';

abstract class QuestionRepository {
  Future<Either<String, void>> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
    String? senderId,
  });
}
