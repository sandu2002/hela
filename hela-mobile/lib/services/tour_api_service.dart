import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/services/ai_service.dart';
import 'package:hela/services/place_service.dart';

/// Top-level facade coordinating Place discovery (OSM/curated) and AI tour generation (Gemini).
class TourApiService {
  final PlaceService _placeService;
  final AIService _aiService;

  static final TourApiService _instance = TourApiService._internal();
  factory TourApiService() => _instance;

  TourApiService._internal()
    : _placeService = PlaceService(),
      _aiService = AIService();

  TourApiService.withServices({
    required this._placeService,
    required this._aiService,
  });

  /// Phase 1: Discovers candidate destinations based on user preferences.
  Future<List<Destination>> discoverDestinations(
    TourPreferences preferences,
  ) async {
    // 1. Query candidate places from OpenStreetMap & curated database
    final basePlaces = await _placeService.getPlacesForPreferences(preferences);

    // 2. Use Gemini AI to score, rank, and describe why each matches
    final enrichedPlaces = await _aiService.discoverDestinations(
      preferences: preferences,
      candidateDestinations: basePlaces,
    );

    return enrichedPlaces;
  }

  /// Phase 2: Generates a day-by-day itinerary plan from selected destinations.
  Future<TourPlan> generateItinerary({
    required TourPreferences preferences,
    required List<Destination> selectedDestinations,
  }) async {
    return _aiService.generateTourPlan(
      preferences: preferences,
      selectedDestinations: selectedDestinations,
    );
  }

  /// Phase 3: Customizes an itinerary through conversational prompts.
  Future<TourPlan> customizeItinerary({
    required TourPlan currentPlan,
    required String userPrompt,
  }) async {
    return _aiService.customizeTourPlan(
      currentPlan: currentPlan,
      userRequest: userPrompt,
    );
  }
}
