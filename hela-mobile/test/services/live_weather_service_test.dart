import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hela/services/live_weather_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveWeatherService parsers', () {
    test('parses Google Weather API currentConditions response', () {
      final payload = {
        'temperature': {'degrees': 26.8, 'unit': 'CELSIUS'},
        'weatherCondition': {
          'description': {'text': 'Partly Cloudy', 'languageCode': 'en'},
        },
      };

      final parsed = LiveWeatherService.parseGoogleWeatherResponse(
        payload,
        locationName: 'Kandy',
        latitude: 7.2906,
        longitude: 80.6337,
      );

      expect(parsed, isNotNull);
      expect(parsed!.temperatureC, closeTo(26.8, 0.01));
      expect(parsed.locationName, 'Kandy');
      expect(parsed.condition, 'Partly Cloudy');
      expect(parsed.source, 'Google Weather');
      expect(parsed.formattedLabel, '27°C Kandy');
    });

    test('parses Gemini Google Search grounding JSON response', () {
      final payload = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '```json\n{"tempC": 29.4, "condition": "Sunny"}\n```'},
              ],
            },
          },
        ],
      };

      final parsed = LiveWeatherService.parseGeminiSearchWeatherResponse(
        payload,
        locationName: 'Colombo',
      );

      expect(parsed, isNotNull);
      expect(parsed!.temperatureC, closeTo(29.4, 0.01));
      expect(parsed.locationName, 'Colombo');
      expect(parsed.condition, 'Sunny');
      expect(parsed.source, 'Google Search');
      expect(parsed.formattedLabel, '29°C Colombo');
    });

    test('parses Gemini Google Search grounding prose fallback', () {
      final payload = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'The current temperature in Galle is 28.6°C right now.'},
              ],
            },
          },
        ],
      };

      final parsed = LiveWeatherService.parseGeminiSearchWeatherResponse(
        payload,
        locationName: 'Galle',
      );

      expect(parsed, isNotNull);
      expect(parsed!.temperatureC, closeTo(28.6, 0.01));
      expect(parsed.formattedLabel, '29°C Galle');
    });

    test('parses Open-Meteo current weather response', () {
      final payload = {
        'current': {'temperature_2m': 22.3, 'weather_code': 3},
      };

      final parsed = LiveWeatherService.parseOpenMeteoResponse(
        payload,
        locationName: 'Nuwara Eliya',
      );

      expect(parsed, isNotNull);
      expect(parsed!.temperatureC, closeTo(22.3, 0.01));
      expect(parsed.condition, 'Partly Cloudy');
      expect(parsed.formattedLabel, '22°C Nuwara Eliya');
    });

    test('extracts normalized city name from Nominatim and Google Geocoding', () {
      final nominatimCity = LiveWeatherService.parseNominatimCityName({
        'address': {'city': 'Kandy Municipal Council', 'country': 'Sri Lanka'},
      });
      expect(nominatimCity, 'Kandy');

      final googleCity = LiveWeatherService.parseGoogleGeocodingCityName({
        'results': [
          {
            'address_components': [
              {
                'long_name': 'Colombo',
                'types': ['locality', 'political'],
              },
            ],
          },
        ],
      });
      expect(googleCity, 'Colombo');
    });
  });

  group('LiveWeatherService end-to-end flow', () {
    test('resolves GPS location, reverse-geocodes city, and fetches Google Search temp', () async {
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('nominatim.openstreetmap.org/reverse')) {
          return http.Response(
            jsonEncode({
              'address': {'city': 'Colombo', 'country': 'Sri Lanka'},
            }),
            200,
          );
        }
        if (url.contains('generativelanguage.googleapis.com')) {
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': '{"tempC": 30.2, "condition": "Humid & Clear"}'},
                    ],
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final fakePosition = Position(
        longitude: 79.8612,
        latitude: 6.9271,
        timestamp: DateTime(2026, 11, 24),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      );

      final service = LiveWeatherService(
        client: mockClient,
        positionProvider: () async => fakePosition,
      );

      final result = await service.fetchLiveWeather();

      expect(result, isNotNull);
      expect(result!.locationName, 'Colombo');
      expect(result.temperatureC, closeTo(30.2, 0.01));
      expect(result.source, 'Google Search');
      expect(result.formattedLabel, '30°C Colombo');

      final cached = await service.loadCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.formattedLabel, '30°C Colombo');
    });

    test('falls back to Open-Meteo when Gemini Google Search is rate-limited', () async {
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('nominatim.openstreetmap.org/reverse')) {
          return http.Response(
            jsonEncode({
              'address': {'town': 'Ella', 'country': 'Sri Lanka'},
            }),
            200,
          );
        }
        if (url.contains('generativelanguage.googleapis.com')) {
          return http.Response('{"error":{"code":429}}', 429);
        }
        if (url.contains('api.open-meteo.com')) {
          return http.Response(
            jsonEncode({
              'current': {'temperature_2m': 21.6, 'weather_code': 61},
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final fakePosition = Position(
        longitude: 81.0466,
        latitude: 6.8667,
        timestamp: DateTime(2026, 11, 24),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      );

      final service = LiveWeatherService(
        client: mockClient,
        positionProvider: () async => fakePosition,
      );

      final result = await service.fetchLiveWeather();

      expect(result, isNotNull);
      expect(result!.locationName, 'Ella');
      expect(result.temperatureC, closeTo(21.6, 0.01));
      expect(result.condition, 'Rain Showers');
      expect(result.formattedLabel, '22°C Ella');
    });
  });
}
