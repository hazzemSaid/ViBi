import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/feed/presentation/view/cubit/feed_cubit.dart';
import 'package:vibi/features/feed/presentation/view/cubit/feed_state.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

import 'post_item/action_row.dart';
import 'post_item/answer_author_row.dart';
import 'post_item/sender_row.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final feedCubit = context.read<GlobalFeedCubit>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final padding = isTablet ? 16.0 : 20.0;
    final bodyFontSize = isTablet ? 20.0 : 12.0;

    return BlocSelector<GlobalFeedCubit, FeedState, _PostBodyData>(
      selector: (state) {
        final source = state is FeedLoaded
            ? (feedCubit.getItemById(item.id) ?? item)
            : item;
        return _PostBodyData.fromFeedItem(source);
      },
      builder: (context, currentItem) {
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnswerAuthorRow(
                answerAuthorUsername: currentItem.answerAuthorUsername,
                answerAuthorAvatarUrl: currentItem.answerAuthorAvatarUrl,
              ),
              const SizedBox(height: 12),
              _RecommendQuestionCard(
                isAnonymous: currentItem.isAnonymous,
                displayName: currentItem.displayName,
                displayAvatar: currentItem.displayAvatar,
                mediaRec: currentItem.mediaRec,
              ),
              const SizedBox(height: 16),
              Text(
                currentItem.answerText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: bodyFontSize,
                ),
              ),
              const SizedBox(height: 20),
              ActionRow(
                answerId: currentItem.id,
                fallbackAnswerText: currentItem.answerText,
                fallbackQuestionText: currentItem.questionText,
                fallbackUsername: currentItem.answerAuthorUsername,
                fallbackIsAnonymous: currentItem.isAnonymous,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendQuestionCard extends StatelessWidget {
  const _RecommendQuestionCard({
    required this.isAnonymous,
    required this.displayName,
    required this.displayAvatar,
    required this.mediaRec,
  });

  final bool isAnonymous;
  final String displayName;
  final String? displayAvatar;
  final TmdbMedia? mediaRec;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SenderRow(
                  isAnonymous: isAnonymous,
                  displayName: displayName,
                  displayAvatar: displayAvatar,
                ),
                const SizedBox(height: 12),
                Text(
                  'RECOMMENDATION',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (mediaRec != null) _PosterSection(media: mediaRec!),
        ],
      ),
    );
  }
}

class _PosterSection extends StatelessWidget {
  const _PosterSection({required this.media});
  final TmdbMedia media;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          media.posterUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: media.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const ColoredBox(color: Color(0xFF1A1B21)),
                  errorWidget: (context, url, error) =>
                      const ColoredBox(color: Color(0xFF1A1B21)),
                )
              : const ColoredBox(color: Color(0xFF1A1B21)),
          // Gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.82),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          // Bottom meta
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (media.year.isNotEmpty ||
                          media.voteAverage != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            if (media.year.isNotEmpty) ...[
                              Text(
                                media.year,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (media.voteAverage != null)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                            if (media.voteAverage != null) ...[
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                media.voteAverage!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    media.mediaType == 'tv' ? 'TV Series' : 'Movie',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostBodyData extends Equatable {
  const _PostBodyData({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.answerAuthorUsername,
    required this.answerAuthorAvatarUrl,
    required this.questionText,
    required this.questionType,
    required this.mediaRec,
    required this.answerText,
    required this.isAnonymous,
  });

  factory _PostBodyData.fromFeedItem(FeedItem item) {
    return _PostBodyData(
      id: item.id,
      username: item.username,
      avatarUrl: item.avatarUrl,
      answerAuthorUsername: item.answerAuthorUsername,
      answerAuthorAvatarUrl: item.answerAuthorAvatarUrl,
      questionText: item.questionText,
      questionType: item.questionType,
      mediaRec: item.mediaRec,
      answerText: item.answerText,
      isAnonymous: item.isAnonymous,
    );
  }

  final String id;
  final String username;
  final String? avatarUrl;
  final String answerAuthorUsername;
  final String? answerAuthorAvatarUrl;
  final String questionText;
  final String questionType;
  final TmdbMedia? mediaRec;
  final String answerText;
  final bool isAnonymous;

  String get displayName => isAnonymous ? 'Anonymous User' : username;
  String? get displayAvatar => isAnonymous ? null : avatarUrl;

  @override
  List<Object?> get props => [
    id,
    username,
    avatarUrl,
    answerAuthorUsername,
    answerAuthorAvatarUrl,
    questionText,
    questionType,
    mediaRec,
    answerText,
    isAnonymous,
  ];
}
