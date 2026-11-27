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

  /// Ask HELA chat endpoint on the backend (DeepSeek primary + Gemini fallback).
  static const String askHelaChatUrl = '$helaBackendUrl/api/tours/chat';

  // ── DeepSeek / OpenAI-Compatible Free Provider (Ask HELA primary) ───────
  /// Optional DeepSeek / OpenRouter (`sk-or-...`) / NVIDIA NIM (`nvapi-...`) key
  /// loaded via `--dart-define-from-file=dart_defines.json` for direct fallback
  /// when [helaBackendUrl] is unreachable. Keep keys on the backend in production.
  static const String deepseekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
  );

  /// Optional OpenRouter API key alias (`OPENROUTER_API_KEY`).
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
  );

  /// Optional custom OpenAI-compatible base URL (e.g. `https://openrouter.ai/api/v1`,
  /// `https://integrate.api.nvidia.com/v1`, `https://api.deepseek.com/v1`,
  /// or local Ollama `http://10.0.2.2:11434/v1`).
  static const String deepseekBaseUrl = String.fromEnvironment(
    'DEEPSEEK_BASE_URL',
  );

  /// Optional override model slug (e.g. `deepseek/deepseek-v4.1-flash`,
  /// `openrouter/free`, `deepseek-ai/deepseek-r1`, `deepseek-chat`).
  static const String deepseekModel = String.fromEnvironment('DEEPSEEK_MODEL');

  /// OpenRouter free fallback slug used when DeepSeek paid slugs require credits.
  static const String deepseekFallbackModel = String.fromEnvironment(
    'DEEPSEEK_FALLBACK_MODEL',
    defaultValue: 'openrouter/free',
  );

  /// Active API key for DeepSeek-compatible direct fallback, preferring
  /// `DEEPSEEK_API_KEY` and falling back to `OPENROUTER_API_KEY`.
  static String get effectiveDeepseekApiKey => deepseekApiKey.trim().isNotEmpty
      ? deepseekApiKey.trim()
      : openRouterApiKey.trim();

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

  /// Optional Google Places API key (`GOOGLE_PLACES_API_KEY` via `--dart-define`).
  /// Falls back to [googleWeatherApiKey] when the same Google Cloud API key is used.
  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );

  /// Effective Google Places API key if configured.
  static String get effectiveGooglePlacesApiKey =>
      googlePlacesApiKey.trim().isNotEmpty
      ? googlePlacesApiKey.trim()
      : googleWeatherApiKey.trim();

  /// Google Places API (New) Text Search endpoint for live destination ratings & reviews.
  static const String googlePlacesSearchTextUrl =
      'https://places.googleapis.com/v1/places:searchText';

  /// Google Places Legacy Text Search fallback endpoint.
  static const String googlePlacesLegacyTextSearchUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';

  /// HELA backend endpoint for cached live Google destination ratings.
  static const String destinationLiveRatingUrl =
      '$helaBackendUrl/api/destinations/live-rating';

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
