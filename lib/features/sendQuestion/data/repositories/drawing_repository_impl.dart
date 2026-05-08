import 'dart:typed_data';
import '../../domain/repositories/drawing_repository.dart';
import '../datasources/drawing_remote_datasource.dart';

/**
 * Implementation of [IDrawingRepository] that uses [DrawingRemoteDataSource].
 */
class DrawingRepositoryImpl implements IDrawingRepository {
  final DrawingRemoteDataSource _dataSource;

  const DrawingRepositoryImpl(this._dataSource);

  @override
  Future<String> sendDrawingQuestion({
    required String recipientId,
    required Uint8List pngBytes,
    required bool isAnonymous,
    String? senderId,
  }) {
    return _dataSource.uploadAndSend(
      recipientId: recipientId,
      pngBytes: pngBytes,
      isAnonymous: isAnonymous,
      senderId: senderId,
    );
  }
}
