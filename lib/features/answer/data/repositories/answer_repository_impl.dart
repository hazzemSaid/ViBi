import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/answer/data/datasources/answer_datasource.dart';
import 'package:vibi/features/answer/data/models/answer_action_dto.dart';
import 'package:vibi/features/answer/domain/repositories/answer_repository.dart';

class AnswerRepositoryImpl implements AnswerRepository {
  final AnswerDataSource _dataSource;

  AnswerRepositoryImpl(this._dataSource);

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  Future<Either<String, Unit>> answerQuestion({
    required String questionId,
    required String answerText,
  }) async {
    return _dataSource.handleQuestionAction(
      AnswerActionDto(
        questionId: questionId,
        userId: _currentUserId,
        action: 'answer',
        answerText: answerText,
      ),
    );
  }

  @override
  Future<Either<String, Unit>> deleteQuestion({
    required String questionId,
  }) async {
    return _dataSource.handleQuestionAction(
      AnswerActionDto(
        questionId: questionId,
        userId: _currentUserId,
        action: 'delete',
      ),
    );
  }

  @override
  Future<Either<String, Unit>> archiveQuestion({
    required String questionId,
  }) async {
    return _dataSource.handleQuestionAction(
      AnswerActionDto(
        questionId: questionId,
        userId: _currentUserId,
        action: 'archive',
      ),
    );
  }

  @override
  Future<Either<String, Unit>> unarchiveQuestion({
    required String questionId,
  }) async {
    return _dataSource.handleQuestionAction(
      AnswerActionDto(
        questionId: questionId,
        userId: _currentUserId,
        action: 'unarchive',
      ),
    );
  }
}
