import 'dart:typed_data';
import '../repositories/drawing_repository.dart';

/**
 * Use case for sending a drawing question.
 */
class SendDrawingQuestion {
  final DrawingRepository _repository;

  const SendDrawingQuestion(this._repository);

  Future<String> call({
    required String recipientId,
    required Uint8List pngBytes,
    required bool isAnonymous,
    String? senderId,
  }) {
    return _repository.sendDrawingQuestion(
      recipientId: recipientId,
      pngBytes: pngBytes,
      isAnonymous: isAnonymous,
      senderId: senderId,
    );
  }
}
