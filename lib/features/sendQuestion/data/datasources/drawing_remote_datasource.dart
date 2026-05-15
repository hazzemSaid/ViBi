import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/**
 * Data source for handling remote operations related to drawing questions.
 *
 * This includes uploading drawing binaries to Supabase Storage and
 * creating the corresponding database records.
 */
class DrawingRemoteDataSource {
  final SupabaseClient _client;
  const DrawingRemoteDataSource(this._client);

  static const _bucket = 'drawings';

  /**
   * Uploads a drawing PNG to storage and creates a new question record.
   *
   * Returns the public URL of the uploaded drawing.
   */
  Future<String> uploadAndSend({
    required String recipientId,
    required Uint8List pngBytes,
    required bool isAnonymous,
    String? senderId,
  }) async {
    // 1. Upload PNG to Storage
    final fileName = '${const Uuid().v4()}.png';
    final storagePath = isAnonymous
        ? 'anon/$fileName'
        : '${senderId ?? 'anon'}/$fileName';

    await _client.storage
        .from(_bucket)
        .uploadBinary(
          storagePath,
          pngBytes,
          fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: false,
          ),
        );

    final drawingUrl = _client.storage.from(_bucket).getPublicUrl(storagePath);

    // 2. Insert into questions
    final questionRow = await _client
        .from('questions')
        .insert({
          'recipient_id': recipientId,
          'sender_id': senderId,
          'is_anonymous': isAnonymous,
          'question_text': '[drawing]', // NOT NULL placeholder
          'question_type': 'drawing',
          'status': 'pending',
        })
        .select('id')
        .single();

    final questionId = questionRow['id'] as String;

    // 3. Insert into question_media
    await _client.from('question_media').insert({
      'question_id': questionId,
      'media_url': drawingUrl,
      'media_type': 'drawing',
    });

    return drawingUrl;
  }
}
