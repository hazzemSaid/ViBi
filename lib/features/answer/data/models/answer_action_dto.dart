class AnswerActionDto {
  final String questionId;
  final String userId;
  final String action;
  final String? answerText;

  const AnswerActionDto({
    required this.questionId,
    required this.userId,
    required this.action,
    this.answerText,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userId': userId,
      'action': action,
      'answerText': answerText,
    };
  }
}
