class AppCaching {
  /// Default cache extent for scroll views (e.g., GlobalFeed)
  static const double feedCacheExtent = 1500.0;

  /// Number of items to fetch per page in feeds
  static const int feedPageLimit = 20;

  /// Timeout for network requests to be considered cached or stale
  static const Duration queryTimeout = Duration(seconds: 20);
}
