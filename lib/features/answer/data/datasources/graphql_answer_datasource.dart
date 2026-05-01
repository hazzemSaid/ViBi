import 'package:dartz/dartz.dart';
import 'package:ferry/ferry.dart' as ferry;
import 'package:flutter/foundation.dart';
import 'package:vibi/core/errors/errors_handel.dart';
import 'package:vibi/core/graphql/graphql_config.dart';
import 'package:vibi/core/graphql/mutations/inbox_mutations.dart';
import 'package:vibi/features/answer/data/datasources/answer_datasource.dart';
import 'package:vibi/features/answer/data/models/answer_action_dto.dart';

class GraphQLAnswerDataSource implements AnswerDataSource {
  final ferry.Client _ferryClient;

  GraphQLAnswerDataSource({ferry.Client? graphQLClient})
      : _ferryClient = graphQLClient ?? GraphQLConfig.ferryClient;

  @override
  Future<Either<String, Unit>> handleQuestionAction(AnswerActionDto dto) async {
    try {
      if (kDebugMode) {
        debugPrint('DEBUG: Starting ${dto.action} via RPC: ${dto.questionId}');
      }

      final result = await GraphQLConfig.ferryMutate(
        InboxMutations.handleQuestionActionOpName,
        document: InboxMutations.handleQuestionAction,
        variables: dto.toMap(),
        clientOverride: _ferryClient,
      );

      if (result.hasErrors) {
        if (kDebugMode) {
          debugPrint('DEBUG: RPC ${dto.action} failed: ${result.graphqlErrors}');
        }
        return left(SupabaseErrorHandler.getErrorMessage(result));
      }

      if (kDebugMode) {
        debugPrint('DEBUG: ${dto.action} completed successfully via RPC');
      }
      return right(unit);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG: Exception in ${dto.action} RPC: $e');
      }
      return left('Failed to ${dto.action} question: $e');
    }
  }
}
