/// Configuration file for API keys and service endpoints.
class ApiConfig {
  /// Google Gemini AI API key for HELA Smart Tour Planner & Ask HELA Chat.
  /// Loaded at build/run time via `--dart-define-from-file=dart_defines.json`
  /// or `--dart-define=GEMINI_API_KEY=...` (kept out of source control).
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Default Gemini model for fast intelligent chat & tour generation (free tier).
  static const String geminiModel = 'gemini-3.6-flash';

  /// Fallback Gemini model if the primary model encounters high demand / rate limits.
  static const String geminiFallbackModel = 'gemini-3.5-flash';

  /// Ultra-fast lightweight fallback Gemini model.
  static const String geminiLiteFallbackModel = 'gemini-3.5-flash-lite';

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
