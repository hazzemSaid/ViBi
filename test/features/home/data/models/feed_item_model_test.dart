import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/home/data/models/feed_item_model.dart';

void main() {
  group('FeedItemModel', () {
    test('fromGraphQL maps recommendation metadata when available', () {
      final model = FeedItemModel.fromGraphQL({
        'id': 'feed-1',
        'user_id': 'user-1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'answers': {
          'id': 'answer-1',
          'user_id': 'user-1',
          'answer_text': 'Watch this one!',
          'likes_count': 2,
          'comments_count': 1,
          'shares_count': 0,
          'created_at': '2026-01-01T00:00:00.000Z',
          'profiles': {
            'username': 'author',
            'avatar_urls': ['https://cdn.test/author.png'],
          },
          'questions': {
            'question_text': 'The Matrix',
            'question_type': 'recommendation',
            'is_anonymous': false,
            'sender_id': 'sender-1',
            'media_recommendations': {
              'tmdb_id': 603,
              'media_type': 'movie',
              'title': 'The Matrix',
              'poster_path': '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
              'overview':
                  'A computer hacker learns about the true nature of reality.',
              'release_date': '1999-03-30',
              'vote_average': 8.2,
            },
            'profiles': {
              'username': 'asker',
              'avatar_urls': ['https://cdn.test/asker.png'],
            },
          },
        },
      });

      expect(model.questionType, 'recommendation');
      expect(model.mediaRec, isNotNull);
      expect(model.mediaRec?.tmdbId, 603);
      expect(model.mediaRec?.mediaType, 'movie');
      expect(model.mediaRec?.title, 'The Matrix');
    });

    test('fromGraphQL falls back to text question type', () {
      final model = FeedItemModel.fromGraphQL({
        'id': 'feed-2',
        'user_id': 'user-1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'answers': {
          'id': 'answer-2',
          'user_id': 'user-1',
          'answer_text': 'Plain answer',
          'likes_count': 0,
          'comments_count': 0,
          'shares_count': 0,
          'created_at': '2026-01-01T00:00:00.000Z',
          'profiles': {
            'username': 'author',
            'avatar_urls': ['https://cdn.test/author.png'],
          },
          'questions': {
            'question_text': 'A simple question',
            'is_anonymous': true,
          },
        },
      });

      expect(model.questionType, 'text');
      expect(model.mediaRec, isNull);
      expect(model.questionText, 'A simple question');
    });
  });
}
