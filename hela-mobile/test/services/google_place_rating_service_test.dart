import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/services/google_place_rating_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GooglePlaceRatingService.clearMemoryCache();
    SharedPreferences.setMockInitialValues({});
  });

  group('GooglePlaceRatingService parsers & formatters', () {
    test('formats large review counts compactly', () {
      expect(GooglePlaceRatingService.formatReviewCount(477), '477');
      expect(GooglePlaceRatingService.formatReviewCount(1000), '1k');
      expect(GooglePlaceRatingService.formatReviewCount(11240), '11.2k');
      expect(GooglePlaceRatingService.formatReviewCount(1500000), '1.5M');
    });

    test('parses Google Places API (New) searchText payload', () {
      final parsed = GooglePlaceRatingService.parseGooglePlacesNewResponse(
        {
          'places': [
            {
              'displayName': {'text': 'Unawatuna Beach'},
              'rating': 4.5,
              'userRatingCount': 11240,
              'googleMapsUri': 'https://maps.google.com/?cid=123',
              'currentOpeningHours': {'openNow': true},
            },
          ],
        },
        queryKey: 'unawatuna',
        fallbackName: 'Unawatuna Beach',
      );

      expect(parsed, isNotNull);
      expect(parsed!.rating, 4.5);
      expect(parsed.userRatingCount, 11240);
      expect(parsed.cardBadgeText, '4.5 • 11.2k');
      expect(parsed.detailRatingCaption, 'Google Rating • 11.2k');
      expect(parsed.openNow, isTrue);
      expect(parsed.source, 'Google Places');
    });

    test('parses Google Places Legacy Text Search payload', () {
      final parsed = GooglePlaceRatingService.parseGooglePlacesLegacyResponse(
        {
          'results': [
            {
              'name': 'Mirissa Beach',
              'rating': 4.6,
              'user_ratings_total': 2530,
              'opening_hours': {'open_now': true},
            },
          ],
        },
        queryKey: 'mirissa',
        fallbackName: 'Mirissa Beach',
      );

      expect(parsed, isNotNull);
      expect(parsed!.rating, 4.6);
      expect(parsed.cardBadgeText, '4.6 • 2.5k');
    });

    test('parses fenced JSON and rejects out-of-range AI ratings', () {
      final valid = GooglePlaceRatingService.parseAiSearchRatingResponse(
        '```json\n{"rating": 4.7, "reviewCount": "24.3k", "openNow": true}\n```',
        queryKey: 'sigiriya',
        placeName: 'Sigiriya Rock Fortress',
        source: 'Google Web',
      );
      expect(valid, isNotNull);
      expect(valid!.cardBadgeText, '4.7 • 24.3k');

      final invalid = GooglePlaceRatingService.parseAiSearchRatingResponse(
        '{"rating": 9.8, "reviewCount": "100"}',
        queryKey: 'bad',
        placeName: 'Invalid Place',
        source: 'Google Web',
      );
      expect(invalid, isNull);
    });
  });

  group('GooglePlaceRatingService live fetch & caching', () {
    test(
      'fetches from Google Places New when API key is configured and caches result',
      () async {
        int httpCalls = 0;
        final mockClient = MockClient((request) async {
          httpCalls++;
          if (request.url.toString().contains('places.googleapis.com')) {
            return http.Response(
              jsonEncode({
                'places': [
                  {
                    'displayName': {'text': 'Unawatuna Beach'},
                    'rating': 4.5,
                    'userRatingCount': 11420,
                    'currentOpeningHours': {'openNow': true},
                  },
                ],
              }),
              200,
            );
          }
          return http.Response('Not found', 404);
        });

        final service = GooglePlaceRatingService(
          client: mockClient,
          googlePlacesApiKey: 'AIzaTestPlacesKey',
        );

        final first = await service.fetchPlaceRating(
          cacheKey: 'unawatuna',
          queryName: 'Unawatuna Beach',
          regionHint: 'Galle',
        );

        expect(first, isNotNull);
        expect(first!.cardBadgeText, '4.5 • 11.4k');
        expect(first.source, 'Google Places');
        expect(httpCalls, 1);

        // Second call hits in-memory/SharedPreferences cache without HTTP
        final second = await service.fetchPlaceRating(
          cacheKey: 'unawatuna',
          queryName: 'Unawatuna Beach',
        );
        expect(second!.cardBadgeText, '4.5 • 11.4k');
        expect(httpCalls, 1);
      },
    );

    test(
      'falls back cleanly to Google Search Grounding then OpenRouter Web Lookup',
      () async {
        final calledUrls = <String>[];
        final mockClient = MockClient((request) async {
          final url = request.url.toString();
          calledUrls.add(url);
          if (url.contains('api/destinations/live-rating')) {
            return http.Response('unavailable', 503);
          }
          if (url.contains('generativelanguage.googleapis.com')) {
            return http.Response('quota exceeded', 429);
          }
          if (url.contains('openrouter.ai')) {
            return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {
                      'content': '{"rating": 4.6, "reviewCount": "2.5k"}',
                    },
                  },
                ],
              }),
              200,
            );
          }
          return http.Response('error', 400);
        });

        final service = GooglePlaceRatingService(
          client: mockClient,
          geminiApiKey: 'test-gemini-key',
          deepseekApiKey: 'sk-or-test-key',
          deepseekBaseUrl: 'https://openrouter.ai/api/v1',
          deepseekModel: 'deepseek/deepseek-v4.1-flash',
        );

        final result = await service.fetchPlaceRating(
          cacheKey: 'mirissa',
          queryName: 'Mirissa Beach',
        );

        expect(result, isNotNull);
        expect(result!.rating, 4.6);
        expect(result.cardBadgeText, '4.6 • 2.5k');
        expect(result.source, 'Google Web');
        expect(
          calledUrls.any(
            (u) => u.contains('generativelanguage.googleapis.com'),
          ),
          isTrue,
        );
        expect(calledUrls.any((u) => u.contains('openrouter.ai')), isTrue);
      },
    );
  });
}
