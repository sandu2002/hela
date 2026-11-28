import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hela/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Resolved geographic coordinates and human-readable locality name.
class ResolvedLocation {
  final double latitude;
  final double longitude;
  final String cityName;
  final bool isFromDeviceGps;

  const ResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.isFromDeviceGps,
  });
}

/// Live weather reading paired with the user's detected location.
class LiveWeatherData {
  final double temperatureC;
  final String locationName;
  final String? condition;
  final double? latitude;
  final double? longitude;
  final String source;
  final DateTime updatedAt;

  const LiveWeatherData({
    required this.temperatureC,
    required this.locationName,
    this.condition,
    this.latitude,
    this.longitude,
    required this.source,
    required this.updatedAt,
  });

  /// Compact display string matching the Ask HELA header badge (e.g. `27°C Kandy`).
  String get formattedLabel => '${temperatureC.round()}°C $locationName';

  Map<String, dynamic> toJson() => {
    'temperatureC': temperatureC,
    'locationName': locationName,
    'condition': condition,
    'latitude': latitude,
    'longitude': longitude,
    'source': source,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LiveWeatherData.fromJson(Map<String, dynamic> json) {
    return LiveWeatherData(
      temperatureC: (json['temperatureC'] as num).toDouble(),
      locationName: (json['locationName'] as String?) ?? 'Kandy',
      condition: json['condition'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      source: (json['source'] as String?) ?? 'Cache',
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Fetches the user's current location and continuous live temperature updates
/// from Google (Google Weather API / Gemini with Google Search grounding),
/// with automatic resilience fallback to real-time meteorological telemetry.
class LiveWeatherService {
  static const String _cachePrefsKey = 'hela_live_weather_cache_v1';
  static const Duration _httpTimeout = Duration(seconds: 8);

  final http.Client _client;
  final bool _hasCustomClient;
  final Future<Position?> Function()? positionProvider;

  LiveWeatherService({http.Client? client, this.positionProvider})
    : _client = client ?? http.Client(),
      _hasCustomClient = client != null;

  /// Loads the most recently cached live weather reading if available.
  Future<LiveWeatherData?> loadCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachePrefsKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return LiveWeatherData.fromJson(decoded);
    } catch (e) {
      debugPrint('[LiveWeather] Cache read error: $e');
      return null;
    }
  }

  /// Persists the latest live weather reading locally.
  Future<void> _saveCachedWeather(LiveWeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachePrefsKey, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('[LiveWeather] Cache write error: $e');
    }
  }

  /// Resolves the user's current location and fetches live temperature from Google.
  Future<LiveWeatherData?> fetchLiveWeather({
    String fallbackLocationName = 'Kandy',
    bool requestPermissionIfNeeded = true,
  }) async {
    final location = await resolveUserLocation(
      fallbackLocationName: fallbackLocationName,
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );

    LiveWeatherData? result;

    // 1. Primary: Google Maps Platform Weather API (when Google Weather key is configured)
    if (ApiConfig.googleWeatherApiKey.trim().isNotEmpty) {
      result = await fetchFromGoogleWeatherApi(
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.cityName,
      );
    }

    // 2. Primary via Gemini Key: Google Search Grounding via Gemini REST API
    result ??= await fetchFromGoogleSearchGrounding(
      latitude: location.latitude,
      longitude: location.longitude,
      locationName: location.cityName,
    );

    // 3. Resilient live fallback: Open-Meteo real-time coordinates weather
    result ??= await fetchFromOpenMeteo(
      latitude: location.latitude,
      longitude: location.longitude,
      locationName: location.cityName,
    );

    if (result != null) {
      await _saveCachedWeather(result);
    }

    return result;
  }

  /// Resolves the user's live location using device GPS first, then IP geolocation,
  /// and finally the provided [fallbackLocationName].
  Future<ResolvedLocation> resolveUserLocation({
    String fallbackLocationName = 'Kandy',
    bool requestPermissionIfNeeded = true,
  }) async {
    final position = positionProvider != null
        ? await positionProvider!()
        : await _getDevicePosition(
            requestPermissionIfNeeded: requestPermissionIfNeeded,
          );

    if (position != null) {
      final city = await reverseGeocodeCity(
        position.latitude,
        position.longitude,
      );
      return ResolvedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: city ?? _normalizeCityLabel(fallbackLocationName),
        isFromDeviceGps: true,
      );
    }

    // Secondary fallback: approximate IP geolocation (useful on emulators/desktop or denied GPS)
    final ipLoc = await _fetchIpLocation();
    if (ipLoc != null) {
      return ipLoc;
    }

    // Final fallback to user's profile city or Kandy
    final cleanFallback = _normalizeCityLabel(fallbackLocationName);
    final coords = _knownCityCoordinates(cleanFallback);
    return ResolvedLocation(
      latitude: coords.$1,
      longitude: coords.$2,
      cityName: cleanFallback,
      isFromDeviceGps: false,
    );
  }

  Future<Position?> _getDevicePosition({
    required bool requestPermissionIfNeeded,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await Geolocator.getLastKnownPosition();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied &&
          requestPermissionIfNeeded) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (e) {
      debugPrint('[LiveWeather] GPS position error: $e');
      return null;
    }
  }

  /// Reverse-geocodes [latitude] and [longitude] into a concise city/town name.
  Future<String?> reverseGeocodeCity(double latitude, double longitude) async {
    // Try Google Geocoding API if configured
    if (ApiConfig.googleWeatherApiKey.trim().isNotEmpty) {
      final googleCity = await _reverseGeocodeWithGoogle(latitude, longitude);
      if (googleCity != null && googleCity.isNotEmpty) {
        return googleCity;
      }
    }

    // OpenStreetMap Nominatim reverse geocoding
    try {
      final uri = Uri.parse(
        '${ApiConfig.nominatimReverseApiUrl}?lat=$latitude&lon=$longitude&format=json&addressdetails=1&zoom=12',
      );
      final response = await _client
          .get(
            uri,
            headers: {
              'User-Agent': 'HelaTravelPlanner/1.0 (contact@hela.travel)',
            },
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return parseNominatimCityName(data);
      }
    } catch (e) {
      debugPrint('[LiveWeather] Nominatim reverse geocode error: $e');
    }
    return null;
  }

  Future<String?> _reverseGeocodeWithGoogle(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.googleGeocodingApiUrl}?latlng=$latitude,$longitude&key=${Uri.encodeComponent(ApiConfig.googleWeatherApiKey)}',
      );
      final response = await _client.get(uri).timeout(_httpTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return parseGoogleGeocodingCityName(data);
      }
    } catch (e) {
      debugPrint('[LiveWeather] Google reverse geocode error: $e');
    }
    return null;
  }

  Future<ResolvedLocation?> _fetchIpLocation() async {
    try {
      final uri = Uri.parse('https://ipwho.is/');
      final response = await _client.get(uri).timeout(_httpTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final lat = (data['latitude'] as num?)?.toDouble();
          final lon = (data['longitude'] as num?)?.toDouble();
          final city = (data['city'] as String?)?.trim();
          if (lat != null && lon != null && city != null && city.isNotEmpty) {
            return ResolvedLocation(
              latitude: lat,
              longitude: lon,
              cityName: city,
              isFromDeviceGps: false,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[LiveWeather] IP geolocation fallback error: $e');
    }
    return null;
  }

  /// Fetches live conditions from the Google Maps Platform Weather API.
  Future<LiveWeatherData?> fetchFromGoogleWeatherApi({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.googleWeatherApiUrl}?key=${Uri.encodeComponent(ApiConfig.googleWeatherApiKey)}'
        '&location.latitude=$latitude&location.longitude=$longitude&unitsSystem=METRIC',
      );
      final response = await _client.get(uri).timeout(_httpTimeout);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return parseGoogleWeatherResponse(
        data,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('[LiveWeather] Google Weather API error: $e');
      return null;
    }
  }

  /// Fetches current live temperature via Gemini REST API grounded with Google Search (`google_search` tool).
  Future<LiveWeatherData?> fetchFromGoogleSearchGrounding({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    if (!_hasCustomClient && ApiConfig.geminiApiKey.trim().isEmpty) return null;
    final models = [
      ApiConfig.geminiModel,
      ApiConfig.geminiFallbackModel,
      ApiConfig.geminiLiteFallbackModel,
    ];

    final prompt =
        'Check Google Weather for the current live outdoor temperature right now at '
        '$locationName (coordinates $latitude, $longitude). '
        'Reply ONLY with raw JSON in this exact format: '
        '{"tempC": 27.0, "condition": "Partly Cloudy"}';

    for (final model in models) {
      try {
        final uri = Uri.parse(
          '${ApiConfig.geminiRestBaseUrl}/$model:generateContent?key=${Uri.encodeComponent(ApiConfig.geminiApiKey)}',
        );
        final payload = jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'tools': [
            {'google_search': {}},
          ],
        });

        final response = await _client
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: payload,
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode != 200) {
          debugPrint(
            '[LiveWeather] Gemini Google Search ($model) HTTP ${response.statusCode}',
          );
          continue;
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = parseGeminiSearchWeatherResponse(
          data,
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
        );
        if (parsed != null) return parsed;
      } catch (e) {
        debugPrint('[LiveWeather] Gemini Google Search ($model) error: $e');
      }
    }
    return null;
  }

  /// Fetches live temperature from Open-Meteo as a zero-key meteorological fallback.
  Future<LiveWeatherData?> fetchFromOpenMeteo({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code',
      );
      final response = await _client.get(uri).timeout(_httpTimeout);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return parseOpenMeteoResponse(
        data,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('[LiveWeather] Open-Meteo fallback error: $e');
      return null;
    }
  }

  /// Parses a Google Weather API (`currentConditions:lookup`) JSON payload.
  static LiveWeatherData? parseGoogleWeatherResponse(
    Map<String, dynamic> data, {
    required String locationName,
    double? latitude,
    double? longitude,
  }) {
    final tempObj = data['temperature'] as Map<String, dynamic>?;
    final degrees = (tempObj?['degrees'] as num?)?.toDouble();
    if (degrees == null) return null;

    final conditionObj = data['weatherCondition'] as Map<String, dynamic>?;
    final descObj = conditionObj?['description'] as Map<String, dynamic>?;
    final condition = (descObj?['text'] as String?)?.trim();

    return LiveWeatherData(
      temperatureC: degrees,
      locationName: locationName,
      condition: condition,
      latitude: latitude,
      longitude: longitude,
      source: 'Google Weather',
      updatedAt: DateTime.now(),
    );
  }

  /// Parses a Gemini `generateContent` response grounded with `google_search`.
  static LiveWeatherData? parseGeminiSearchWeatherResponse(
    Map<String, dynamic> data, {
    required String locationName,
    double? latitude,
    double? longitude,
  }) {
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;

    final rawText = parts
        .map((p) => (p as Map<String, dynamic>)['text']?.toString() ?? '')
        .join(' ')
        .trim();
    if (rawText.isEmpty) return null;

    var cleaned = rawText;
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    // Try strict JSON decode first
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch != null) {
      try {
        final decoded = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        final temp = (decoded['tempC'] as num?)?.toDouble();
        if (temp != null && temp > -50 && temp < 65) {
          return LiveWeatherData(
            temperatureC: temp,
            locationName: locationName,
            condition: (decoded['condition'] as String?)?.trim(),
            latitude: latitude,
            longitude: longitude,
            source: 'Google Search',
            updatedAt: DateTime.now(),
          );
        }
      } catch (_) {
        // Fall through to regex extraction
      }
    }

    // Regex fallback if model included prose around temperature
    final tempMatch = RegExp(
      r'(-?\d+(?:\.\d+)?)\s*°?\s*[Cc]',
    ).firstMatch(rawText);
    if (tempMatch != null) {
      final temp = double.tryParse(tempMatch.group(1)!);
      if (temp != null && temp > -50 && temp < 65) {
        return LiveWeatherData(
          temperatureC: temp,
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
          source: 'Google Search',
          updatedAt: DateTime.now(),
        );
      }
    }

    return null;
  }

  /// Parses an Open-Meteo `/v1/forecast?current=temperature_2m` JSON payload.
  static LiveWeatherData? parseOpenMeteoResponse(
    Map<String, dynamic> data, {
    required String locationName,
    double? latitude,
    double? longitude,
  }) {
    final current = data['current'] as Map<String, dynamic>?;
    final temp = (current?['temperature_2m'] as num?)?.toDouble();
    if (temp == null) return null;

    final code = (current?['weather_code'] as num?)?.toInt();
    return LiveWeatherData(
      temperatureC: temp,
      locationName: locationName,
      condition: code != null ? _wmoCodeToCondition(code) : null,
      latitude: latitude,
      longitude: longitude,
      source: 'Live Weather',
      updatedAt: DateTime.now(),
    );
  }

  /// Extracts a clean locality name from an OpenStreetMap Nominatim reverse payload.
  static String? parseNominatimCityName(Map<String, dynamic> data) {
    final address = data['address'] as Map<String, dynamic>?;
    if (address != null) {
      const priorityKeys = [
        'city',
        'town',
        'village',
        'suburb',
        'municipality',
        'county',
        'state_district',
        'state',
      ];
      for (final key in priorityKeys) {
        final value = (address[key] as String?)?.trim();
        if (value != null && value.isNotEmpty) {
          return _normalizeCityLabel(value);
        }
      }
    }
    final name = (data['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) {
      return _normalizeCityLabel(name);
    }
    return null;
  }

  /// Extracts a clean locality name from a Google Geocoding API JSON payload.
  static String? parseGoogleGeocodingCityName(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    for (final result in results) {
      final components =
          (result as Map<String, dynamic>)['address_components']
              as List<dynamic>?;
      if (components == null) continue;

      for (final targetType in const [
        'locality',
        'administrative_area_level_2',
        'sublocality_level_1',
        'administrative_area_level_1',
      ]) {
        for (final comp in components) {
          final types = (comp['types'] as List<dynamic>? ?? []).cast<String>();
          if (types.contains(targetType)) {
            final name = (comp['long_name'] as String?)?.trim();
            if (name != null && name.isNotEmpty) {
              return _normalizeCityLabel(name);
            }
          }
        }
      }
    }
    return null;
  }

  static String _normalizeCityLabel(String raw) {
    var clean = raw.split(',').first.trim();
    clean = clean.replaceAll(RegExp(r'\s+District$', caseSensitive: false), '');
    clean = clean.replaceAll(
      RegExp(r'\s+Municipal Council$', caseSensitive: false),
      '',
    );
    return clean.isEmpty ? 'Kandy' : clean;
  }

  static (double, double) _knownCityCoordinates(String cityName) {
    switch (cityName.toLowerCase()) {
      case 'colombo':
        return (6.9271, 79.8612);
      case 'galle':
        return (6.0535, 80.2210);
      case 'ella':
        return (6.8667, 81.0466);
      case 'nuwara eliya':
        return (6.9497, 80.7891);
      case 'negombo':
        return (7.2008, 79.8737);
      case 'jaffna':
        return (9.6615, 80.0255);
      case 'trincomalee':
        return (8.5874, 81.2152);
      case 'anuradhapura':
        return (8.3114, 80.4037);
      case 'matara':
        return (5.9549, 80.5550);
      case 'kandy':
      default:
        return (7.2906, 80.6337);
    }
  }

  static String _wmoCodeToCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Misty / Foggy';
    if (code <= 67) return 'Rain Showers';
    if (code <= 82) return 'Tropical Rain';
    return 'Thunderstorms';
  }
}
