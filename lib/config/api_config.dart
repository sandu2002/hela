/// Configuration file for API keys and service endpoints.
class ApiConfig {
  /// Google Gemini AI API key provided for HELA Smart Tour Planner.
  static const String geminiApiKey =
      'AQ.Ab8RN6LcBcIS8jiH2GzAdjwITZJtC1IXTrvgdQnvky5gXnv4CA';

  /// Default Gemini model for fast and intelligent tour generation.
  static const String geminiModel = 'gemini-3.6-flash';

  /// Fallback Gemini model if the primary model encounters rate limits.
  static const String geminiFallbackModel = 'gemini-2.5-pro';

  /// OpenStreetMap Overpass API endpoint for querying Sri Lankan tourism data.
  static const String overpassApiUrl =
      'https://overpass-api.de/api/interpreter';

  /// Nominatim endpoint for reverse geocoding & place search.
  static const String nominatimApiUrl =
      'https://nominatim.openstreetmap.org/search';
}
