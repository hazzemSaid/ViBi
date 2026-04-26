import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

/**
 * Determines whether a question should use the recommendation composer.
 *
 * Takes:
 * - questionType string from the inbox or answer flow.
 *
 * Returns:
 * - true when the type is recommendation, ignoring case and whitespace.
 *
 * Used for:
 * - Switching between text and recommendation-specific UI.
 */
bool isRecommendationQuestion(String questionType) {
  return questionType.trim().toLowerCase() == 'recommendation';
}

/**
 * Builds a recommendation media object from question data.
 *
 * Takes:
 * - mediaRec: optional media model already attached to the question.
 * - questionText: fallback text used as the display title.
 *
 * Returns:
 * - TmdbMedia ready for the shared recommendation card.
 *
 * Used for:
 * - Rendering recommendation questions consistently in inbox and answer flows.
 */
TmdbMedia buildRecommendationMedia(TmdbMedia? mediaRec, String questionText) {
  final trimmedQuestionText = questionText.trim();

  return mediaRec ??
      TmdbMedia(
        tmdbId: 0,
        mediaType: 'movie',
        title: trimmedQuestionText.isEmpty
            ? 'Movie Recommendation'
            : trimmedQuestionText,
      );
}