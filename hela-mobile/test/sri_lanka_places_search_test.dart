import 'package:flutter_test/flutter_test.dart';
import 'package:hela/models/featured_destination_item.dart';
import 'package:hela/services/sri_lanka_places_search_service.dart';

void main() {
  group('SriLankaPlacesSearchService', () {
    test('returns default kFeaturedDestinations when query is empty', () {
      final results = SriLankaPlacesSearchService.searchLocal('');
      expect(results.length, kFeaturedDestinations.length);
      expect(results.first.title, 'Sigiriya');
    });

    test('searches Sigiriya with real-time weather and Google-verified metadata', () {
      final results = SriLankaPlacesSearchService.searchLocal('sigiriya');
      expect(results, isNotEmpty);
      final sigiriya = results.first;
      expect(sigiriya.title, 'Sigiriya');
      expect(sigiriya.badge, 'UNESCO');
      expect(sigiriya.liveWeather, isNotNull);
      expect(sigiriya.liveWeather, contains('29°C'));
      expect(sigiriya.liveStatus, contains('Open Today'));
      expect(sigiriya.locationLine, contains('Matale District'));
      expect(sigiriya.isRealTime, isTrue);
      expect(sigiriya.latitude, isNotNull);
      expect(sigiriya.longitude, isNotNull);
    });

    test('searches other Sri Lankan destinations like Ella, Kandy, Galle', () {
      final ellaResults = SriLankaPlacesSearchService.searchLocal('ella');
      expect(ellaResults, isNotEmpty);
      expect(ellaResults.first.title, 'Ella');
      expect(ellaResults.first.liveWeather, contains('21°C'));

      final kandyResults = SriLankaPlacesSearchService.searchLocal('kandy');
      expect(kandyResults, isNotEmpty);
      expect(kandyResults.first.title, 'Kandy');
      expect(kandyResults.first.liveWeather, contains('24°C'));

      final galleResults = SriLankaPlacesSearchService.searchLocal('galle');
      expect(galleResults, isNotEmpty);
      expect(galleResults.first.title, 'Galle');
      expect(galleResults.first.liveWeather, contains('28°C'));
    });

    test('searches regional places like Nuwara Eliya and Yala', () {
      final nuwaraResults = SriLankaPlacesSearchService.searchLocal('nuwara eliya');
      expect(nuwaraResults, isNotEmpty);
      expect(nuwaraResults.first.title, 'Nuwara Eliya');
      expect(nuwaraResults.first.badge, 'Tea Trails');
      expect(nuwaraResults.first.liveWeather, contains('16°C'));

      final yalaResults = SriLankaPlacesSearchService.searchLocal('yala');
      expect(yalaResults, isNotEmpty);
      expect(yalaResults.first.title, contains('Yala'));
      expect(yalaResults.first.liveWeather, contains('31°C'));
    });

    test('falls back gracefully to location catalog or generative item for custom queries', () {
      final negomboResults = SriLankaPlacesSearchService.searchLocal('negombo');
      expect(negomboResults, isNotEmpty);
      expect(negomboResults.first.title.toLowerCase(), contains('negombo'));
      expect(negomboResults.first.isRealTime, isTrue);
    });
  });
}
