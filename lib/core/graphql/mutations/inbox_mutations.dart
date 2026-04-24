class InboxMutations {
  static const String handleQuestionAction = r'''
    mutation HandleQuestionAction(
      $questionId: UUID!
      $userId: UUID!
      $action: String!
      $answerText: String
    ) {
      handle_question_action(
        p_question_id: $questionId
        p_user_id: $userId
        p_action: $action
        p_answer_text: $answerText
      )
    }
  ''';
}
