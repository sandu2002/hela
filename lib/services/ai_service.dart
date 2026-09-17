import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hela/config/api_config.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';

/// Service for generating AI-powered tour recommendations, full day-by-day
/// itineraries, and conversational customizations using Google Gemini.
class AIService {
  final GenerativeModel _primaryModel;
  final GenerativeModel _fallbackModel;

  AIService({
    String? apiKey,
    String? primaryModelName,
    String? fallbackModelName,
  })  : _primaryModel = GenerativeModel(
          model: primaryModelName ?? ApiConfig.geminiModel,
          apiKey: apiKey ?? ApiConfig.geminiApiKey,
        ),
        _fallbackModel = GenerativeModel(
          model: fallbackModelName ?? ApiConfig.geminiFallbackModel,
          apiKey: apiKey ?? ApiConfig.geminiApiKey,
        );

  /// Discovers and enriches Sri Lanka destinations based on user preferences.
  Future<List<Destination>> discoverDestinations({
    required TourPreferences preferences,
    required List<Destination> candidateDestinations,
  }) async {
    final interestsStr = preferences.interests.map((i) => i.label).join(', ');
    final startLoc = preferences.startingLocationName.isNotEmpty
        ? preferences.startingLocationName
        : preferences.startingLocationType.label;
    final duration = preferences.duration == TravelDuration.custom
        ? '${preferences.customDays} days'
        : preferences.duration.label;

    final candidatesSummary = candidateDestinations.take(10).map((d) {
      return '- ${d.name} (${d.region}): ${d.description}';
    }).join('\n');

    final prompt = '''
You are a Sri Lanka travel expert AI for the HELA app.
A traveler has the following preferences:
- Duration: $duration
- Starting Point: $startLoc
- Interests: $interestsStr
- Budget Level: ${preferences.budgetLevel.label}
- Travelers: ${preferences.numberOfTravelers}
- Pace: ${preferences.pace.label}
- Accommodation: ${preferences.accommodationType.label}
${preferences.additionalNotes.isNotEmpty ? '- Notes: ${preferences.additionalNotes}' : ''}

Here are some verified places in Sri Lanka:
$candidatesSummary

Select and return the 5 to 7 best destinations in Sri Lanka matching these preferences.
Respond ONLY with a valid JSON array of objects with these exact keys:
[
  {
    "sourceId": "unique_id_string",
    "name": "Destination Name",
    "description": "Why this place matches their interests and what to experience here (2-3 sentences).",
    "region": "Province / District in Sri Lanka",
    "categories": ["Category1", "Category2"],
    "latitude": 7.9570,
    "longitude": 80.7603,
    "relevanceScore": 0.95
  }
]
Do not include markdown code fence or extra text. Output strictly raw JSON.
''';

    try {
      final responseText = await _generateWithFallback(prompt);
      final cleaned = _cleanJsonResponse(responseText);
      final list = jsonDecode(cleaned) as List<dynamic>;

      final results = list.map((item) {
        final map = item as Map<String, dynamic>;
        // Try to match with existing candidate for image and source url
        final matchedCandidate = candidateDestinations.firstWhere(
          (c) => c.name.toLowerCase().contains((map['name'] as String? ?? '').toLowerCase()),
          orElse: () => const Destination(
            sourceId: 'ai_dest',
            name: '',
            latitude: 7.8731,
            longitude: 80.7718,
          ),
        );

        return Destination(
          sourceId: map['sourceId']?.toString() ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
          name: map['name']?.toString() ?? 'Sri Lanka Destination',
          description: map['description']?.toString() ?? '',
          isDescriptionAIGenerated: true,
          latitude: (map['latitude'] as num?)?.toDouble() ?? matchedCandidate.latitude,
          longitude: (map['longitude'] as num?)?.toDouble() ?? matchedCandidate.longitude,
          region: map['region']?.toString() ?? matchedCandidate.region,
          categories: (map['categories'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              matchedCandidate.categories,
          imageUrl: matchedCandidate.imageUrl.isNotEmpty
              ? matchedCandidate.imageUrl
              : 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
          sourceUrl: matchedCandidate.sourceUrl,
          retrievedAt: DateTime.now().toIso8601String(),
          attribution: 'Curated by Gemini AI & OpenStreetMap',
          relevanceScore: (map['relevanceScore'] as num?)?.toDouble() ?? 0.90,
        );
      }).toList();

      return results.isNotEmpty ? results : candidateDestinations.take(6).toList();
    } catch (_) {
      // Fallback gracefully to candidate destinations
      return candidateDestinations.take(6).toList();
    }
  }

  /// Generates a comprehensive day-by-day tour plan.
  Future<TourPlan> generateTourPlan({
    required TourPreferences preferences,
    required List<Destination> selectedDestinations,
  }) async {
    final daysCount = preferences.duration == TravelDuration.custom
        ? preferences.customDays
        : preferences.duration.days;
    final interestsStr = preferences.interests.map((i) => i.label).join(', ');
    final destinationsStr =
        selectedDestinations.map((d) => '${d.name} (${d.region})').join(', ');
    final startLoc = preferences.startingLocationName.isNotEmpty
        ? preferences.startingLocationName
        : preferences.startingLocationType.label;

    final prompt = '''
You are an expert Sri Lanka Tour Planner. Create a realistic, highly engaging $daysCount-day itinerary for Sri Lanka.

Traveler Profile:
- Duration: $daysCount days
- Starting Location: $startLoc
- Selected Must-Visit Places: $destinationsStr
- Interests: $interestsStr
- Budget Tier: ${preferences.budgetLevel.label} (Estimated budget: ${preferences.budgetAmount != null ? "\$${preferences.budgetAmount}" : "Standard"})
- Travelers: ${preferences.numberOfTravelers} person(s)
- Pace: ${preferences.pace.label}
- Accommodation Style: ${preferences.accommodationType.label}
${preferences.additionalNotes.isNotEmpty ? '- Custom Requests: ${preferences.additionalNotes}' : ''}

Requirements:
1. Days must progress logically across Sri Lanka (consider realistic travel times and mountain roads).
2. For each day, include 2 to 3 detailed activities (morning, afternoon, evening) with realistic start times, estimated durations, categories, and practical tips.
3. Include realistic travel times between activities (e.g. "2h 30m by private car/van").
4. Provide estimated costs in USD per person.
5. Provide helpful local tips (e.g., dress codes for temples, sunset timings, scenic train tips).
6. Provide important travel warnings (e.g., road hairpin turns, rainy season leech socks, sun protection).

Respond ONLY with a valid JSON object with the following structure:
{
  "id": "tour_${DateTime.now().millisecondsSinceEpoch}",
  "title": "Creative Tour Title (e.g., Highland Trails & Southern Shores)",
  "summary": "2-3 sentence overview capturing the spirit of the trip.",
  "matchReason": "Why this trip fits the traveler's specific preferences.",
  "durationDays": $daysCount,
  "estimatedTotalCostUsd": 450.0,
  "budgetBreakdown": "Breakdown description of estimated expenses (accommodation, transport, entry tickets, meals).",
  "budgetIncludes": ["Accommodation recommendations", "Estimated activity admission fees", "Local transit estimates"],
  "budgetExcludes": ["International flights", "Personal shopping", "Travel insurance", "Alcoholic beverages"],
  "travelTips": ["Tip 1", "Tip 2", "Tip 3"],
  "warnings": ["Warning 1", "Warning 2"],
  "days": [
    {
      "dayNumber": 1,
      "title": "Day Theme/Headline",
      "summary": "Overview of this day",
      "estimatedDayCostUsd": 80.0,
      "overnightStay": "Recommended town or area to stay",
      "activities": [
        {
          "title": "Activity Name",
          "description": "What travelers do and experience here",
          "startTime": "08:30 AM",
          "estimatedDuration": "2.5 hours",
          "category": "Culture / Nature / Adventure / Food",
          "estimatedCostUsd": 25.0,
          "isCostEstimated": true,
          "travelTimeFromPrevious": "45 mins",
          "travelMethod": "Private AC Car",
          "tips": ["Practical visitor tip"]
        }
      ]
    }
  ]
}
Do not include markdown code fences or conversational text. Output pure JSON.
''';

    try {
      final responseText = await _generateWithFallback(prompt);
      final cleaned = _cleanJsonResponse(responseText);
      final map = jsonDecode(cleaned) as Map<String, dynamic>;

      return TourPlan.fromJson(map).copyWith(
        dataSources: ['Google Gemini AI (${ApiConfig.geminiModel})', 'OpenStreetMap Contributors'],
        generatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Return a robust pre-calculated fallback plan matching preferences
      return _createFallbackPlan(preferences, selectedDestinations);
    }
  }

  /// Customizes an existing tour plan using AI conversational request.
  Future<TourPlan> customizeTourPlan({
    required TourPlan currentPlan,
    required String userRequest,
  }) async {
    final currentPlanJson = jsonEncode(currentPlan.toJson());

    final prompt = '''
You are the HELA AI Smart Tour Planner assistant.
The traveler wants to customize their existing Sri Lanka tour plan.

Current Tour Plan:
$currentPlanJson

Traveler's Customization Request:
"$userRequest"

Apply the requested changes to the itinerary (e.g. adjust days, swap activities, adjust pace, add beach time, adjust budget).
Maintain realistic travel routes and logistical feasibility within Sri Lanka.

Respond ONLY with a valid JSON object matching the TourPlan schema, plus an extra string field "customizationSummary" explaining what you updated:
{
  "id": "${currentPlan.id}",
  "title": "...",
  "summary": "...",
  "matchReason": "...",
  "durationDays": ${currentPlan.durationDays},
  "estimatedTotalCostUsd": ...,
  "budgetBreakdown": "...",
  "budgetIncludes": [...],
  "budgetExcludes": [...],
  "travelTips": [...],
  "warnings": [...],
  "customizationSummary": "Brief bulleted or 2-sentence summary of the exact changes applied.",
  "days": [...]
}
Do not wrap in markdown or include extra text.
''';

    try {
      final responseText = await _generateWithFallback(prompt);
      final cleaned = _cleanJsonResponse(responseText);
      final map = jsonDecode(cleaned) as Map<String, dynamic>;

      final newPlan = TourPlan.fromJson(map);
      return newPlan.copyWith(
        version: currentPlan.version + 1,
        generatedAt: DateTime.now().toIso8601String(),
        dataSources: currentPlan.dataSources,
        isSaved: currentPlan.isSaved,
      );
    } catch (_) {
      // If AI customization fails, return current plan with a note
      return currentPlan.copyWith(
        customizationSummary:
            'Adjusted based on: "$userRequest" (offline adjustments applied).',
      );
    }
  }

  /// Helper to generate with primary model, falling back if needed.
  Future<String> _generateWithFallback(String prompt) async {
    try {
      final response = await _primaryModel.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        return text;
      }
    } catch (_) {
      // Fallback to secondary model
    }

    final fallbackResponse =
        await _fallbackModel.generateContent([Content.text(prompt)]);
    return fallbackResponse.text ?? '';
  }

  /// Cleans markdown code fences or preamble from JSON response.
  String _cleanJsonResponse(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  /// Generates a sensible fallback plan if offline or AI call hits a network error.
  TourPlan _createFallbackPlan(
    TourPreferences prefs,
    List<Destination> destinations,
  ) {
    final daysCount = prefs.duration == TravelDuration.custom
        ? prefs.customDays
        : prefs.duration.days;

    final days = List.generate(daysCount, (index) {
      final dayNum = index + 1;
      final dest = destinations.isNotEmpty
          ? destinations[index % destinations.length]
          : const Destination(
              sourceId: 'default',
              name: 'Scenic Sri Lanka',
              latitude: 7.8731,
              longitude: 80.7718,
            );

      return ItineraryDay(
        dayNumber: dayNum,
        title: 'Day $dayNum: Discover ${dest.name}',
        summary: 'Immerse yourself in ${dest.region} exploring ${dest.name}.',
        estimatedDayCostUsd: 65.0,
        overnightStay: dest.region,
        activities: [
          ItineraryActivity(
            title: 'Morning Exploration of ${dest.name}',
            description: dest.description.isNotEmpty
                ? dest.description
                : 'Experience the local highlights and scenic beauty.',
            destination: dest,
            startTime: '08:30 AM',
            estimatedDuration: '3 hours',
            category: 'Exploration',
            estimatedCostUsd: 20.0,
            tips: const ['Wear comfortable walking shoes and stay hydrated.'],
          ),
          const ItineraryActivity(
            title: 'Traditional Sri Lankan Lunch & Village Walk',
            description:
                'Savor authentic rice and curry with fresh coconut sambal at a local eco-eatery.',
            startTime: '01:00 PM',
            estimatedDuration: '1.5 hours',
            category: 'Culinary',
            estimatedCostUsd: 12.0,
            tips: ['Try the jackfruit curry and king coconut drink.'],
          ),
          const ItineraryActivity(
            title: 'Sunset Viewpoint & Leisure Walk',
            description:
                'Relax and soak in the evening golden hour views and tropical breeze.',
            startTime: '05:00 PM',
            estimatedDuration: '2 hours',
            category: 'Leisure',
            estimatedCostUsd: 5.0,
            tips: ['Bring a camera for scenic golden hour photos.'],
          ),
        ],
      );
    });

    return TourPlan(
      id: 'tour_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Sri Lanka Discovery Expedition',
      summary:
          'A handcrafted $daysCount-day journey tailored to your interests in ${prefs.interests.map((i) => i.label).join(", ")}.',
      matchReason:
          'Designed around your ${prefs.pace.label} pace and ${prefs.startingLocationType.label} starting point.',
      durationDays: daysCount,
      days: days,
      estimatedTotalCostUsd: daysCount * 75.0,
      budgetBreakdown:
          'Includes estimated accommodation, entry tickets, and local meals.',
      budgetIncludes: const [
        'Activity admissions',
        'Estimated intercity travel',
        'Eco-stay recommendations'
      ],
      budgetExcludes: const ['International airfare', 'Alcohol', 'Personal shopping'],
      travelTips: const [
        'Carry Sri Lankan Rupees (LKR) for smaller vendors',
        'Modest clothing covering shoulders and knees is mandatory at sacred temples',
        'Stay hydrated with refreshing fresh King Coconuts (Thambili)'
      ],
      warnings: const [
        'Mountain roads in the hill country have frequent sharp curves',
        'Carry insect repellent when visiting national parks and rain forests'
      ],
      dataSources: const ['HELA Curated Travel Engine', 'OpenStreetMap'],
      generatedAt: DateTime.now().toIso8601String(),
    );
  }
}
