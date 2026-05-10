import 'dart:typed_data';

/**
 * Repository interface for managing drawing-related operations.
 */
abstract class DrawingRepository {
  /// Uploads PNG bytes to Supabase Storage and inserts a question row.
  /// Returns the public URL of the uploaded drawing.
  Future<String> sendDrawingQuestion({
    required String recipientId,
    required Uint8List pngBytes,
    required bool isAnonymous,
    String? senderId,
  });
}
