abstract class QuestionRepository {
  Future<void> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
    String? senderId,
  });
}
