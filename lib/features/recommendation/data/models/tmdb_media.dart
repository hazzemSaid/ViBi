class TmdbMedia {
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;

  const TmdbMedia({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
  });

  String get posterUrl {
    final path = posterPath?.trim() ?? '';
    if (path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w342$path';
  }

  String get year {
    final date = releaseDate?.trim() ?? '';
    if (date.isEmpty) return '';
    return date.split('-').first;
  }

  factory TmdbMedia.fromJson(Map<String, dynamic> json) {
    return TmdbMedia(
      tmdbId: _asInt(json['id']) ?? 0,
      mediaType: (json['media_type'] as String? ?? '').trim().toLowerCase(),
      title: ((json['title'] ?? json['name']) as String? ?? '').trim(),
      posterPath: (json['poster_path'] as String?)?.trim(),
      overview: (json['overview'] as String?)?.trim(),
      releaseDate: ((json['release_date'] ?? json['first_air_date']) as String?)
          ?.trim(),
      voteAverage: _asDouble(json['vote_average']),
    );
  }

  factory TmdbMedia.fromSupabaseMap(Map<String, dynamic> map) {
    return TmdbMedia(
      tmdbId: _asInt(map['tmdb_id']) ?? 0,
      mediaType: (map['media_type'] as String? ?? '').trim().toLowerCase(),
      title: (map['title'] as String? ?? '').trim(),
      posterPath: (map['poster_path'] as String?)?.trim(),
      overview: (map['overview'] as String?)?.trim(),
      releaseDate: (map['release_date'] as String?)?.trim(),
      voteAverage: _asDouble(map['vote_average']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
