import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:hela/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Live rating and review metadata for a Sri Lankan destination retrieved
/// from Google (Places API, Google Search grounding, or Google web lookup).
class GooglePlaceLiveDetails {
  final String queryKey;
  final String placeName;
  final double rating;
  final int? userRatingCount;
  final String? reviewCountLabel;
  final bool? openNow;
  final String? googleMapsUri;
  final String source;
  final DateTime updatedAt;

  const GooglePlaceLiveDetails({
    required this.queryKey,
    required this.placeName,
    required this.rating,
    this.userRatingCount,
    this.reviewCountLabel,
    this.openNow,
    this.googleMapsUri,
    required this.source,
    required this.updatedAt,
  });

  /// Single-decimal rating text (e.g. `"4.5"`).
  String get formattedRating => rating.toStringAsFixed(1);

  /// Compact review count badge (e.g. `"11.2k"` or `"477"`), if known.
  String? get compactReviewCount {
    if (userRatingCount != null && userRatingCount! > 0) {
      return GooglePlaceRatingService.formatReviewCount(userRatingCount!);
    }
    final clean = reviewCountLabel?.trim();
    return (clean != null && clean.isNotEmpty) ? clean : null;
  }

  /// Compact string rendered in the top-left badge of destination cards.
  String get cardBadgeText {
    final count = compactReviewCount;
    if (count != null) {
      return '$formattedRating • $count';
    }
    return '$formattedRating • Google';
  }

  /// Subtitle caption shown under the rating pill inside [PlaceDetailsPage].
  String get detailRatingCaption {
    final count = compactReviewCount;
    if (count != null) {
      return 'Google Rating • $count';
    }
    return 'Google Live Rating';
  }

  bool isFresh(Duration ttl) => DateTime.now().difference(updatedAt) < ttl;

  Map<String, dynamic> toJson() => {
    'queryKey': queryKey,
    'placeName': placeName,
    'rating': rating,
    'userRatingCount': userRatingCount,
    'reviewCountLabel': reviewCountLabel,
    'openNow': openNow,
    'googleMapsUri': googleMapsUri,
    'source': source,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory GooglePlaceLiveDetails.fromJson(Map<String, dynamic> json) {
    final parsedRating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    return GooglePlaceLiveDetails(
      queryKey: (json['queryKey'] as String?) ?? '',
      placeName: (json['placeName'] as String?) ?? '',
      rating: parsedRating,
      userRatingCount: (json['userRatingCount'] as num?)?.toInt(),
      reviewCountLabel: json['reviewCountLabel'] as String?,
      openNow: json['openNow'] as bool?,
      googleMapsUri: json['googleMapsUri'] as String?,
      source: (json['source'] as String?) ?? 'Cache',
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Fetches real-time Google ratings and review counts for destinations using:
/// 1. Google Places API (New / Legacy) when [ApiConfig.effectiveGooglePlacesApiKey] is configured
/// 2. HELA backend proxy (`/api/destinations/live-rating`) when reachable
/// 3. Gemini REST API with `google_search` grounding via [ApiConfig.geminiApiKey]
/// 4. OpenRouter web-grounded Google Maps/Search lookup via [ApiConfig.effectiveDeepseekApiKey]
///
/// Results are cached in memory and persisted to [SharedPreferences] for 6 hours.
class GooglePlaceRatingService {
  static const String _prefsKey = 'hela_google_place_ratings_v1';
  static const Duration cacheTtl = Duration(hours: 6);
  static const Duration _httpTimeout = Duration(seconds: 12);

  static final Map<String, GooglePlaceLiveDetails> _memoryCache = {};
  static final Map<String, Future<GooglePlaceLiveDetails?>> _inFlight = {};
  static DateTime? _geminiCooldownUntil;
  static DateTime? _backendCooldownUntil;

  final http.Client _client;
  final bool _hasCustomClient;
  final String _googlePlacesApiKey;
  final String _geminiApiKey;
  final String _deepseekApiKey;
  final String _deepseekBaseUrl;
  final String _deepseekModel;
  final String _backendUrl;

  GooglePlaceRatingService({
    http.Client? client,
    String? googlePlacesApiKey,
    String? geminiApiKey,
    String? deepseekApiKey,
    String? deepseekBaseUrl,
    String? deepseekModel,
    String? backendUrl,
  }) : _client = client ?? http.Client(),
       _hasCustomClient = client != null,
       _googlePlacesApiKey =
           (googlePlacesApiKey ?? ApiConfig.effectiveGooglePlacesApiKey).trim(),
       _geminiApiKey = (geminiApiKey ?? ApiConfig.geminiApiKey).trim(),
       _deepseekApiKey = (deepseekApiKey ?? ApiConfig.effectiveDeepseekApiKey)
           .trim(),
       _deepseekBaseUrl = (deepseekBaseUrl ?? ApiConfig.deepseekBaseUrl).trim(),
       _deepseekModel = (deepseekModel ?? ApiConfig.deepseekModel).trim(),
       _backendUrl = (backendUrl ?? ApiConfig.destinationLiveRatingUrl).trim();

  static bool get _isWidgetTest => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  /// Normalizes a destination id/name into a stable cache key.
  static String normalizeKey(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Formats an integer review count into compact form (e.g. `11240 -> 11.2k`).
  static String formatReviewCount(int count) {
    if (count >= 1000000) {
      final m = (count / 1000000).toStringAsFixed(1);
      return '${m.endsWith('.0') ? m.substring(0, m.length - 2) : m}M';
    }
    if (count >= 1000) {
      final k = (count / 1000).toStringAsFixed(1);
      return '${k.endsWith('.0') ? k.substring(0, k.length - 2) : k}k';
    }
    return count.toString();
  }

  /// Clears in-memory cache and cooldown markers (intended for tests / manual reset).
  @visibleForTesting
  static void clearMemoryCache() {
    _memoryCache.clear();
    _inFlight.clear();
    _geminiCooldownUntil = null;
    _backendCooldownUntil = null;
  }

  /// Returns a fresh cached entry synchronously if present in memory.
  GooglePlaceLiveDetails? getCachedSync(String key) {
    final normalized = normalizeKey(key);
    final entry = _memoryCache[normalized];
    if (entry != null && entry.isFresh(cacheTtl)) {
      return entry;
    }
    return null;
  }

  /// Loads cached live Google ratings from [SharedPreferences] into memory.
  Future<Map<String, GooglePlaceLiveDetails>> loadCachedRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) {
        return Map.unmodifiable(_memoryCache);
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final parsed = GooglePlaceLiveDetails.fromJson(value);
          if (parsed.rating >= 1.0 &&
              parsed.rating <= 5.0 &&
              parsed.isFresh(cacheTtl)) {
            _memoryCache[normalizeKey(key)] = parsed;
          }
        }
      });
    } catch (e) {
      debugPrint('[GooglePlaceRating] Cache read error: $e');
    }
    return Map.unmodifiable(_memoryCache);
  }

  Future<void> _saveToCache(String key, GooglePlaceLiveDetails details) async {
    final normalized = normalizeKey(key);
    _memoryCache[normalized] = details;
    final nameKey = normalizeKey(details.placeName);
    if (nameKey.isNotEmpty) {
      _memoryCache[nameKey] = details;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final serializable = <String, dynamic>{};
      _memoryCache.forEach((k, v) {
        if (v.isFresh(cacheTtl)) {
          serializable[k] = v.toJson();
        }
      });
      await prefs.setString(_prefsKey, jsonEncode(serializable));
    } catch (e) {
      debugPrint('[GooglePlaceRating] Cache write error: $e');
    }
  }

  /// Fetches real-time Google rating & review count for a single destination.
  Future<GooglePlaceLiveDetails?> fetchPlaceRating({
    required String cacheKey,
    required String queryName,
    String? regionHint,
    double? latitude,
    double? longitude,
    bool forceRefresh = false,
  }) {
    final normalized = normalizeKey(cacheKey);
    if (!forceRefresh) {
      final cached = getCachedSync(normalized) ?? getCachedSync(queryName);
      if (cached != null) return Future.value(cached);
    }

    if (!_hasCustomClient && _isWidgetTest) {
      return Future.value(null);
    }

    final existing = _inFlight[normalized];
    if (existing != null && !forceRefresh) {
      return existing;
    }

    final future = _executeFetch(
      normalizedKey: normalized,
      queryName: queryName,
      regionHint: regionHint,
      latitude: latitude,
      longitude: longitude,
    );

    _inFlight[normalized] = future;
    future.whenComplete(() {
      if (identical(_inFlight[normalized], future)) {
        _inFlight.remove(normalized);
      }
    });
    return future;
  }

  /// Fetches live Google ratings for multiple visible destinations using a
  /// bounded concurrency pool so cards update progressively without flooding APIs.
  Future<Map<String, GooglePlaceLiveDetails>> fetchRatingsForBatch(
    List<({String cacheKey, String queryName, String? regionHint})> items, {
    int concurrency = 3,
    bool forceRefresh = false,
    void Function(String cacheKey, GooglePlaceLiveDetails details)?
    onEachLoaded,
  }) async {
    if (items.isEmpty) return const {};
    if (!_hasCustomClient && _isWidgetTest) return const {};

    final results = <String, GooglePlaceLiveDetails>{};
    final queue = List.of(items);

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final item = queue.removeAt(0);
        final details = await fetchPlaceRating(
          cacheKey: item.cacheKey,
          queryName: item.queryName,
          regionHint: item.regionHint,
          forceRefresh: forceRefresh,
        );
        if (details != null) {
          results[item.cacheKey] = details;
          onEachLoaded?.call(item.cacheKey, details);
        }
      }
    }

    final workerCount = concurrency.clamp(1, queue.length);
    await Future.wait(List.generate(workerCount, (_) => worker()));
    return results;
  }

  Future<GooglePlaceLiveDetails?> _executeFetch({
    required String normalizedKey,
    required String queryName,
    String? regionHint,
    double? latitude,
    double? longitude,
  }) async {
    GooglePlaceLiveDetails? result;

    // 1. Direct Official Google Places API (New -> Legacy) when API key exists
    if (_googlePlacesApiKey.isNotEmpty) {
      result = await _fetchFromGooglePlacesNew(
        queryKey: normalizedKey,
        queryName: queryName,
        regionHint: regionHint,
        latitude: latitude,
        longitude: longitude,
      );
      result ??= await _fetchFromGooglePlacesLegacy(
        queryKey: normalizedKey,
        queryName: queryName,
        regionHint: regionHint,
      );
    }

    // 2. HELA Backend Proxy (uses server Google Places / Gemini Grounding keys)
    if (result == null &&
        _backendUrl.isNotEmpty &&
        (_backendCooldownUntil == null ||
            DateTime.now().isAfter(_backendCooldownUntil!))) {
      result = await _fetchFromBackendProxy(
        queryKey: normalizedKey,
        queryName: queryName,
        regionHint: regionHint,
        latitude: latitude,
        longitude: longitude,
      );
    }

    // 3. Direct Gemini Google Search Grounding (`google_search` tool)
    if (result == null &&
        _geminiApiKey.isNotEmpty &&
        (_geminiCooldownUntil == null ||
            DateTime.now().isAfter(_geminiCooldownUntil!))) {
      result = await _fetchFromGeminiGoogleSearch(
        queryKey: normalizedKey,
        queryName: queryName,
        regionHint: regionHint,
      );
    }

    // 4. OpenRouter Web-Grounded Google Maps/Search Lookup
    if (result == null && _deepseekApiKey.isNotEmpty) {
      result = await _fetchFromOpenRouterWebSearch(
        queryKey: normalizedKey,
        queryName: queryName,
        regionHint: regionHint,
      );
    }

    if (result != null) {
      await _saveToCache(normalizedKey, result);
    }
    return result;
  }

  String _composeSearchQuery(String queryName, String? regionHint) {
    final hint = (regionHint ?? '').replaceAll('•', ' ').trim();
    if (hint.isNotEmpty && !queryName.toLowerCase().contains('sri lanka')) {
      return '$queryName, $hint, Sri Lanka';
    }
    return queryName.toLowerCase().contains('sri lanka')
        ? queryName
        : '$queryName, Sri Lanka';
  }

  Future<GooglePlaceLiveDetails?> _fetchFromGooglePlacesNew({
    required String queryKey,
    required String queryName,
    String? regionHint,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        'textQuery': _composeSearchQuery(queryName, regionHint),
        'maxResultCount': 1,
        'languageCode': 'en',
      };
      if (latitude != null && longitude != null) {
        body['locationBias'] = {
          'circle': {
            'center': {'latitude': latitude, 'longitude': longitude},
            'radius': 15000.0,
          },
        };
      }

      final response = await _client
          .post(
            Uri.parse(ApiConfig.googlePlacesSearchTextUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': _googlePlacesApiKey,
              'X-Goog-FieldMask':
                  'places.displayName,places.rating,places.userRatingCount,places.googleMapsUri,places.currentOpeningHours.openNow',
            },
            body: jsonEncode(body),
          )
          .timeout(_httpTimeout);

      if (response.statusCode != 200) {
        debugPrint(
          '[GooglePlaceRating] Places New HTTP ${response.statusCode}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return parseGooglePlacesNewResponse(
        data,
        queryKey: queryKey,
        fallbackName: queryName,
      );
    } catch (e) {
      debugPrint('[GooglePlaceRating] Places New error: $e');
      return null;
    }
  }

  Future<GooglePlaceLiveDetails?> _fetchFromGooglePlacesLegacy({
    required String queryKey,
    required String queryName,
    String? regionHint,
  }) async {
    try {
      final q = Uri.encodeComponent(_composeSearchQuery(queryName, regionHint));
      final uri = Uri.parse(
        '${ApiConfig.googlePlacesLegacyTextSearchUrl}?query=$q&key=${Uri.encodeComponent(_googlePlacesApiKey)}',
      );
      final response = await _client.get(uri).timeout(_httpTimeout);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return parseGooglePlacesLegacyResponse(
        data,
        queryKey: queryKey,
        fallbackName: queryName,
      );
    } catch (e) {
      debugPrint('[GooglePlaceRating] Places Legacy error: $e');
      return null;
    }
  }

  Future<GooglePlaceLiveDetails?> _fetchFromBackendProxy({
    required String queryKey,
    required String queryName,
    String? regionHint,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_backendUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': queryName,
              'region': ?regionHint,
              'latitude': ?latitude,
              'longitude': ?longitude,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rating = (data['rating'] as num?)?.toDouble();
      if (rating == null || rating < 1.0 || rating > 5.0) return null;

      return GooglePlaceLiveDetails(
        queryKey: queryKey,
        placeName: (data['name'] as String?)?.trim().isNotEmpty == true
            ? (data['name'] as String).trim()
            : queryName,
        rating: double.parse(rating.toStringAsFixed(1)),
        userRatingCount: (data['userRatingCount'] as num?)?.toInt(),
        reviewCountLabel: (data['reviewCount'] as String?)?.trim(),
        openNow: data['openNow'] as bool?,
        googleMapsUri: data['googleMapsUri'] as String?,
        source: (data['source'] as String?) ?? 'Google Places',
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      // Avoid retrying dead local emulator backend on every card
      if (!_hasCustomClient) {
        _backendCooldownUntil = DateTime.now().add(const Duration(minutes: 5));
      }
      return null;
    }
  }

  Future<GooglePlaceLiveDetails?> _fetchFromGeminiGoogleSearch({
    required String queryKey,
    required String queryName,
    String? regionHint,
  }) async {
    final fullQuery = _composeSearchQuery(queryName, regionHint);
    final models = [ApiConfig.geminiModel, ApiConfig.geminiFallbackModel];
    final prompt =
        'Search Google for the exact current Google Maps / Google star rating '
        '(1.0 to 5.0, 1 decimal) and total Google review count (like "11.2k" or "840") '
        'for "$fullQuery". '
        'Only report figures backed by Google Maps / Google Search results. '
        'Reply ONLY with raw JSON: '
        '{"rating": 4.5, "reviewCount": "11.2k", "openNow": true}';

    for (final model in models) {
      try {
        final uri = Uri.parse(
          '${ApiConfig.geminiRestBaseUrl}/$model:generateContent?key=${Uri.encodeComponent(_geminiApiKey)}',
        );
        final response = await _client
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
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
              }),
            )
            .timeout(_httpTimeout);

        if (response.statusCode == 429) {
          _geminiCooldownUntil = DateTime.now().add(
            const Duration(minutes: 10),
          );
          return null;
        }
        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        final parts =
            (candidates?.firstOrNull?['content']
                    as Map<String, dynamic>?)?['parts']
                as List<dynamic>?;
        final rawText = parts
            ?.map((p) => (p as Map<String, dynamic>)['text']?.toString() ?? '')
            .join(' ')
            .trim();
        if (rawText == null || rawText.isEmpty) continue;

        final parsed = parseAiSearchRatingResponse(
          rawText,
          queryKey: queryKey,
          placeName: queryName,
          source: 'Google Search',
        );
        if (parsed != null) return parsed;
      } catch (e) {
        debugPrint('[GooglePlaceRating] Gemini search ($model) error: $e');
      }
    }
    return null;
  }

  Future<GooglePlaceLiveDetails?> _fetchFromOpenRouterWebSearch({
    required String queryKey,
    required String queryName,
    String? regionHint,
  }) async {
    final fullQuery = _composeSearchQuery(queryName, regionHint);
    final baseUrl = _deepseekBaseUrl.isNotEmpty
        ? _deepseekBaseUrl.replaceAll(RegExp(r'/+$'), '')
        : 'https://openrouter.ai/api/v1';
    final models = [
      if (_deepseekModel.isNotEmpty) _deepseekModel,
      if (!baseUrl.contains('openrouter.ai') ||
          _deepseekModel != 'deepseek/deepseek-v4.1-flash')
        'deepseek/deepseek-v4.1-flash',
      ApiConfig.deepseekFallbackModel,
    ];

    final prompt =
        'Look up the current live Google Maps / Google Search star rating '
        '(number 1.0-5.0, 1 decimal) and total Google review count (like "11.2k" or "477") '
        'for "$fullQuery". Use only Google review ratings from search results '
        '(do not use TripAdvisor or Booking.com). If no Google rating is found, set rating to null. '
        'Reply ONLY with raw JSON: '
        '{"rating": 4.5, "reviewCount": "11.2k", "openNow": true}';

    for (final model in models) {
      if (model.trim().isEmpty) continue;
      try {
        final payload = <String, dynamic>{
          'model': model,
          'temperature': 0.1,
          'max_tokens': 160,
          if (baseUrl.contains('openrouter.ai'))
            'plugins': [
              {'id': 'web', 'max_results': 5},
            ],
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        };

        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_deepseekApiKey',
          if (baseUrl.contains('openrouter.ai')) ...{
            'HTTP-Referer': 'https://hela.travel',
            'X-Title': 'HELA Sri Lanka Travel Companion',
          },
        };

        final response = await _client
            .post(
              Uri.parse('$baseUrl/chat/completions'),
              headers: headers,
              body: jsonEncode(payload),
            )
            .timeout(_httpTimeout);

        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawText =
            (data['choices'] as List<dynamic>?)
                ?.firstOrNull?['message']?['content']
                ?.toString() ??
            '';
        if (rawText.trim().isEmpty) continue;

        final parsed = parseAiSearchRatingResponse(
          rawText,
          queryKey: queryKey,
          placeName: queryName,
          source: 'Google Web',
        );
        if (parsed != null) return parsed;
      } catch (e) {
        debugPrint('[GooglePlaceRating] OpenRouter web lookup ($model): $e');
      }
    }
    return null;
  }

  /// Parses Google Places API (New) `places:searchText` JSON payload.
  static GooglePlaceLiveDetails? parseGooglePlacesNewResponse(
    Map<String, dynamic> data, {
    required String queryKey,
    required String fallbackName,
  }) {
    final places = data['places'] as List<dynamic>?;
    if (places == null || places.isEmpty) return null;

    final place = places.first as Map<String, dynamic>;
    final rating = (place['rating'] as num?)?.toDouble();
    if (rating == null || rating < 1.0 || rating > 5.0) return null;

    final displayNameObj = place['displayName'] as Map<String, dynamic>?;
    final displayName =
        (displayNameObj?['text'] as String?)?.trim() ?? fallbackName;
    final count = (place['userRatingCount'] as num?)?.toInt();
    final hours = place['currentOpeningHours'] as Map<String, dynamic>?;
    final openNow = hours?['openNow'] as bool?;
    final mapsUri = place['googleMapsUri'] as String?;

    return GooglePlaceLiveDetails(
      queryKey: queryKey,
      placeName: displayName,
      rating: double.parse(rating.toStringAsFixed(1)),
      userRatingCount: count,
      reviewCountLabel: count != null && count > 0
          ? formatReviewCount(count)
          : null,
      openNow: openNow,
      googleMapsUri: mapsUri,
      source: 'Google Places',
      updatedAt: DateTime.now(),
    );
  }

  /// Parses Legacy Google Places Text Search API JSON payload.
  static GooglePlaceLiveDetails? parseGooglePlacesLegacyResponse(
    Map<String, dynamic> data, {
    required String queryKey,
    required String fallbackName,
  }) {
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final place = results.first as Map<String, dynamic>;
    final rating = (place['rating'] as num?)?.toDouble();
    if (rating == null || rating < 1.0 || rating > 5.0) return null;

    final count = (place['user_ratings_total'] as num?)?.toInt();
    final hours = place['opening_hours'] as Map<String, dynamic>?;
    final openNow = hours?['open_now'] as bool?;

    return GooglePlaceLiveDetails(
      queryKey: queryKey,
      placeName: (place['name'] as String?)?.trim() ?? fallbackName,
      rating: double.parse(rating.toStringAsFixed(1)),
      userRatingCount: count,
      reviewCountLabel: count != null && count > 0
          ? formatReviewCount(count)
          : null,
      openNow: openNow,
      source: 'Google Places',
      updatedAt: DateTime.now(),
    );
  }

  /// Parses raw text / fenced JSON returned by Gemini Google Search or OpenRouter Web lookup.
  static GooglePlaceLiveDetails? parseAiSearchRatingResponse(
    String rawText, {
    required String queryKey,
    required String placeName,
    required String source,
  }) {
    var cleaned = rawText
        .replaceAll(
          RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false),
          '',
        )
        .trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch == null) return null;

    try {
      final decoded = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      final rawRating = decoded['rating'];
      final double? rating = rawRating is num
          ? rawRating.toDouble()
          : double.tryParse(rawRating?.toString() ?? '');
      if (rating == null || rating < 1.0 || rating > 5.0) return null;

      int? userRatingCount;
      String? reviewCountLabel;
      final rawCount = decoded['reviewCount'] ?? decoded['userRatingCount'];
      if (rawCount is num) {
        userRatingCount = rawCount.toInt();
        if (userRatingCount > 0) {
          reviewCountLabel = formatReviewCount(userRatingCount);
        }
      } else if (rawCount is String) {
        final trimmedCount = rawCount.trim();
        if (trimmedCount.isNotEmpty &&
            trimmedCount.toLowerCase() != 'null' &&
            trimmedCount.toLowerCase() != 'n/a') {
          final numericOnly = int.tryParse(
            trimmedCount.replaceAll(RegExp(r'[^0-9]'), ''),
          );
          if (trimmedCount.toLowerCase().endsWith('k') ||
              trimmedCount.toLowerCase().endsWith('m')) {
            reviewCountLabel = trimmedCount;
          } else if (numericOnly != null && numericOnly > 0) {
            userRatingCount = numericOnly;
            reviewCountLabel = formatReviewCount(numericOnly);
          } else {
            reviewCountLabel = trimmedCount;
          }
        }
      }

      return GooglePlaceLiveDetails(
        queryKey: queryKey,
        placeName: placeName,
        rating: double.parse(rating.toStringAsFixed(1)),
        userRatingCount: userRatingCount,
        reviewCountLabel: reviewCountLabel,
        openNow: decoded['openNow'] is bool ? decoded['openNow'] as bool : null,
        source: source,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
