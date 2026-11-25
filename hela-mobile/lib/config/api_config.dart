/// Configuration file for API keys and service endpoints.
class ApiConfig {
  /// Google Gemini AI API key — only used by [LiveWeatherService] for
  /// the Google Search grounding weather query. AI tour/chat generation
  /// routes through the HELA backend so this key is NOT used for those.
  /// Loaded at build/run time via `--dart-define-from-file=dart_defines.json`.
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // ── HELA Backend (proxies Gemini so the key stays server-side) ──────────
  /// HELA backend base URL.  Override with `--dart-define=HELA_BACKEND_URL=...`
  /// for staging / production.  Defaults to localhost for local dev.
  static const String helaBackendUrl = String.fromEnvironment(
    'HELA_BACKEND_URL',
    defaultValue: 'http://10.0.2.2:5000', // Android emulator loopback
  );

  /// Endpoint that proxies Gemini on the backend.
  static const String tourGenerateUrl = '$helaBackendUrl/api/tours/generate';

  // ── Verified Gemini model identifiers (server-side use only) ───────────
  /// Primary Gemini model — verified as of 2026-11.
  static const String geminiModel = 'gemini-3.5-flash-lite';

  /// Fallback Gemini model.
  static const String geminiFallbackModel = 'gemini-3.1-flash-lite';

  /// Lightweight fallback Gemini model.
  static const String geminiLiteFallbackModel = 'gemini-2.5-flash';

  /// OpenStreetMap Overpass API endpoint for querying Sri Lankan tourism data.
  static const String overpassApiUrl =
      'https://overpass-api.de/api/interpreter';

  /// Nominatim endpoint for reverse geocoding & place search.
  static const String nominatimApiUrl =
      'https://nominatim.openstreetmap.org/search';

  /// Nominatim reverse-geocoding endpoint for resolving GPS coordinates to city names.
  static const String nominatimReverseApiUrl =
      'https://nominatim.openstreetmap.org/reverse';

  /// Optional Google Maps Platform / Google Weather API key (`AIza...`).
  /// When provided, [LiveWeatherService] uses Google Weather API and Google Geocoding API directly;
  /// otherwise it uses Google Gemini with Google Search grounding (`geminiApiKey`) and live fallback.
  static const String googleWeatherApiKey = '';

  /// Google Maps Platform Weather API current conditions endpoint.
  static const String googleWeatherApiUrl =
      'https://weather.googleapis.com/v1/currentConditions:lookup';

  /// Google Maps Platform Geocoding API endpoint.
  static const String googleGeocodingApiUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Google Gemini REST API base URL (used for Google Search grounded weather queries).
  static const String geminiRestBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
}
