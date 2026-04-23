import 'package:flutter/material.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';
import 'package:vibi/features/recommendation/presentation/widgets/saved_films_banner.dart';
import 'package:vibi/features/recommendation/presentation/widgets/top_pick_card.dart';
import 'package:vibi/features/recommendation/presentation/widgets/trending_card.dart';

/// Displays the entire Trending section, including the Saved Films banner, 
/// the horizontal Top Trending list, and the vertical Top Picks list.
/// It uses mocked dummy data.
class TrendingView extends StatelessWidget {
  const TrendingView({
    super.key,
    required this.selectedMedia,
    required this.isSending,
    required this.onMediaSelected,
  });

  /// Handled from the parent state. Represents the currently selected recommendation.
  final TmdbMedia? selectedMedia;
  
  /// Prevents taps when currently sending the recommendation.
  final bool isSending;
  
  /// Callback to alert the parent context that a media item was selected.
  final ValueChanged<TmdbMedia> onMediaSelected;

  static const _trendingMedia = [
    TmdbMedia(tmdbId: 693134, mediaType: 'movie', title: 'Dune: Part Two', releaseDate: '2024-02-27', posterPath: '/8b8R8l88zzIOMH0A9A2QzENw2Lz.jpg'),
    TmdbMedia(tmdbId: 872585, mediaType: 'movie', title: 'Oppenheimer', releaseDate: '2023-07-19', posterPath: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg'),
    TmdbMedia(tmdbId: 346698, mediaType: 'movie', title: 'Barbie', releaseDate: '2023-07-19', posterPath: '/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg'),
  ];

  static const _topPicks = [
    TmdbMedia(tmdbId: 545611, mediaType: 'movie', title: 'Everything Everywhere All at Once', releaseDate: '2022-03-24', posterPath: '/w3LxiVYdWWRvEVdn5RYq6jIqkb1.jpg'),
    TmdbMedia(tmdbId: 157336, mediaType: 'movie', title: 'Interstellar', releaseDate: '2014-11-05', posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg'),
    TmdbMedia(tmdbId: 414906, mediaType: 'movie', title: 'The Batman', releaseDate: '2022-03-01', posterPath: '/74xTEgt7R36Fpooo50r9T25onhq.jpg'),
    TmdbMedia(tmdbId: 324857, mediaType: 'movie', title: 'Spider-Man: Across the Spider-Verse', releaseDate: '2023-05-31', posterPath: '/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Saved Films Banner
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SavedFilmsBanner(),
        ),
        const SizedBox(height: 24),
        
        // Trending Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFA78BFA), size: 20),
              SizedBox(width: 8),
              Text(
                'Trending',
                style: TextStyle(
                  color: Color(0xFFF5F6F8),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 228,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _trendingMedia.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final media = _trendingMedia[index];
              final isSelected = selectedMedia?.tmdbId == media.tmdbId && selectedMedia?.mediaType == media.mediaType;
              return TrendingCard(
                media: media,
                isSelected: isSelected,
                onTap: isSending ? null : () => onMediaSelected(media),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        
        // Top Picks Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Top Picks',
            style: TextStyle(
              color: Color(0xFFF5F6F8),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._topPicks.map((media) {
          final isSelected = selectedMedia?.tmdbId == media.tmdbId && selectedMedia?.mediaType == media.mediaType;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
            child: TopPickCard(
              media: media,
              isSelected: isSelected,
              onTap: isSending ? null : () => onMediaSelected(media),
            ),
          );
        }),
      ],
    );
  }
}
