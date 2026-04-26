/**
 * Available filters for pending inbox questions.
 *
 * Takes:
 * - enum selection from tabs.
 *
 * Returns:
 * - Filter mode applied to pending question list.
 *
 * Used for:
 * - Segmenting all, anonymous, and friend/user questions.
 */
enum QuestionFilter { all, fromUsers, anonymous, archived }
