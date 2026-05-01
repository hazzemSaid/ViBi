import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibi/core/constants/question_filter_enum.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/presentation/helpers/user_identity_helpers.dart';

/**
 * Determines if a question status indicates archived state.
 *
 * Takes:
 * - status string from question entity.
 *
 * Returns:
 * - true if status is 'archive' or 'archived' (case-insensitive, trimmed).
 *
 * Used for:
 * - Filtering archived questions from display lists.
 */
bool isArchivedStatus(String status) {
  final normalized = status.trim().toLowerCase();
  return normalized == 'archive' || normalized == 'archived';
}

/**
 * Determines if a question status indicates non-answered state.
 *
 * Takes:
 * - status string from question entity.
 *
 * Returns:
 * - true if status is not 'answered' and not 'deleted' (case-insensitive, trimmed).
 *
 * Used for:
 * - Filtering active questions that need user action.
 */
bool isNotAnsweredStatus(String status) {
  final normalized = status.trim().toLowerCase();
  return normalized != 'answered' && normalized != 'deleted';
}

/**
 * Applies current tab filter to the provided question list.
 *
 * Takes:
 * - full question list.
 * - selected QuestionFilter value.
 *
 * Returns:
 * - Filtered list based on selected QuestionFilter.
 *
 * Used for:
 * - Driving displayed items in inbox list view based on user selection.
 */
List<InboxQuestion> filterQuestions(
  List<InboxQuestion> questions,
  QuestionFilter selectedFilter,
) {
  switch (selectedFilter) {
    case QuestionFilter.all:
      return questions
          .where(
            (q) => isNotAnsweredStatus(q.status) && !isArchivedStatus(q.status),
          )
          .toList();
    case QuestionFilter.fromUsers:
      return questions
          .where(
            (q) =>
                q.isFromUser &&
                isNotAnsweredStatus(q.status) &&
                !isArchivedStatus(q.status),
          )
          .toList();
    case QuestionFilter.anonymous:
      return questions
          .where(
            (q) =>
                q.isAnonymous &&
                isNotAnsweredStatus(q.status) &&
                !isArchivedStatus(q.status),
          )
          .toList();
    case QuestionFilter.archived:
      return questions.where((q) => isArchivedStatus(q.status)).toList();
  }
}

/**
 * Computes displayed count for top badge (placeholder for extensibility).
 *
 * Takes:
 * - fallback integer count.
 *
 * Returns:
 * - Integer to render in header counter (currently returns fallback).
 *
 * Used for:
 * - Future extensibility for filtered count logic in header.
 */
int filterQuestionsCount(int fallback) {
  return fallback;
}

/**
 * Converts absolute creation time into compact relative label.
 *
 * Takes:
 * - question creation DateTime.
 *
 * Returns:
 * - Human-readable age string (e.g., "5m ago", "2h ago", "3d ago").
 *
 * Used for:
 * - Metadata labels in question card headers showing time since creation.
 */
String getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  } else {
    final months = (difference.inDays / 30).floor();
    return '${months}mo ago';
  }
}

/**
 * Picks a stable accent color based on card index seed.
 *
 * Takes:
 * - integer seed (typically list index).
 *
 * Returns:
 * - Color from predefined accent palette (pink, purple, blue, green, orange).
 *
 * Used for:
 * - Visual variety across question cards with consistent coloring.
 */
Color colorForQuestion(int seed) {
  final palette = <Color>[
    const Color(0xFFFF6B9D),
    const Color(0xFFB06EFF),
    const Color(0xFF4ECDC4),
    const Color(0xFF95E1D3),
    const Color(0xFFFFB347),
  ];
  return palette[seed % palette.length];
}

/**
 * Generates shareable profile URL for current authenticated user.
 *
 * Takes:
 * - no arguments (reads from Supabase auth and .env).
 *
 * Returns:
 * - Profile URL string (e.g., "https://vibi.social/u/username").
 *
 * Used for:
 * - Populating share card and clipboard copy functionality.
 */
String get shareProfileUrl {
  final username = resolveCurrentUsername();
  final shareBaseUrl = dotenv.env['SHARE_BASE_URL'] ?? 'https://vibi.social';
  return '$shareBaseUrl/u/$username';
}

/**
 * Copies public profile link to clipboard and confirms via snackbar.
 *
 * Takes:
 * - build context for showing snackbar.
 *
 * Returns:
 * - Future completing after clipboard update and feedback.
 *
 * Used for:
 * - Share card quick-copy action to help users share profile.
 */
Future<void> copyProfileLink(BuildContext context) async {
  final link = shareProfileUrl;
  await Clipboard.setData(ClipboardData(text: link));
  if (!context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Profile link copied')));
}
