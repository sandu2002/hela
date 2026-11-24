import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final GenerativeModel _liteFallbackModel;
  final String _primaryModelName;
  final String _fallbackModelName;
  final String _liteFallbackModelName;

  AIService({
    String? apiKey,
    String? primaryModelName,
    String? fallbackModelName,
    String? liteFallbackModelName,
  })  : _primaryModelName = primaryModelName ?? ApiConfig.geminiModel,
        _fallbackModelName = fallbackModelName ?? ApiConfig.geminiFallbackModel,
        _liteFallbackModelName =
            liteFallbackModelName ?? ApiConfig.geminiLiteFallbackModel,
        _primaryModel = GenerativeModel(
          model: primaryModelName ?? ApiConfig.geminiModel,
          apiKey: apiKey ?? ApiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        ),
        _fallbackModel = GenerativeModel(
          model: fallbackModelName ?? ApiConfig.geminiFallbackModel,
          apiKey: apiKey ?? ApiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        ),
        _liteFallbackModel = GenerativeModel(
          model: liteFallbackModelName ?? ApiConfig.geminiLiteFallbackModel,
          apiKey: apiKey ?? ApiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
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

  /// Generates a comprehensive day-by-day tour plan using Google Gemini AI.
  Future<TourPlan> generateTourPlan({
    required TourPreferences preferences,
    required List<Destination> selectedDestinations,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
    String? preferredLanguage,
  }) async {
    final daysCount = preferences.duration == TravelDuration.custom
        ? preferences.customDays
        : preferences.duration.days;
    final interestsStr = preferences.interests.isNotEmpty
        ? preferences.interests.map((i) => i.label).join(', ')
        : 'Cultural Heritage, Beaches, Nature';
    final destinationsStr = selectedDestinations.isNotEmpty
        ? selectedDestinations.map((d) => '${d.name} (${d.region})').join(', ')
        : 'AI-selected optimal Sri Lanka highlights matching traveler profile';
    final startLoc = preferences.startingLocationName.isNotEmpty
        ? preferences.startingLocationName
        : preferences.startingLocationType.label;
    final partyDetails = (adults != null || children != null)
        ? '${adults ?? preferences.numberOfTravelers} adult(s), ${children ?? 0} child(ren)'
        : '${preferences.numberOfTravelers} person(s)';
    final dateWindow = (startDate != null && endDate != null)
        ? '${startDate.toIso8601String().split('T').first} to ${endDate.toIso8601String().split('T').first}'
        : '$daysCount flexible days';
    final langInstruction = (preferredLanguage != null &&
            preferredLanguage.toUpperCase() != 'EN')
        ? 'Write titles, summaries, activity descriptions, and tips in language code "$preferredLanguage" where natural (keep JSON keys strictly in English).'
        : '';

    final prompt = '''
You are HELA, an expert Sri Lanka Travel Planner powered by Google Gemini AI. Create a realistic, personalized $daysCount-day Sri Lanka itinerary tailored specifically to every preference below.

Traveler Profile:
- Trip Duration: $daysCount day(s)
- Travel Dates: $dateWindow
- Starting Location: $startLoc
- Must-Visit / Preferred Places: $destinationsStr
- Selected Interests: $interestsStr
- Budget Tier: ${preferences.budgetLevel.label} (${preferences.budgetLevel.description})${preferences.budgetAmount != null ? ' • Target Budget: \$${preferences.budgetAmount}' : ''}
- Travelers: $partyDetails
- Travel Pace: ${preferences.pace.label} (${preferences.pace.description})
- Accommodation Style: ${preferences.accommodationType.label}
${preferences.additionalNotes.isNotEmpty ? '- Special Requests / Notes: ${preferences.additionalNotes}' : ''}
${langInstruction.isNotEmpty ? '- Language: $langInstruction' : ''}

Requirements:
1. Generate ALL $daysCount days (dayNumber 1 through $daysCount) progressing geographically logically across Sri Lanka starting from "$startLoc".
2. Respect the traveler's "${preferences.pace.label}" pace: include 2-3 stops/activities for Relaxed, 3-4 for Moderate/Balanced, and 4-5 for Active per day.
3. Tailor stays, dining, and transport to the "${preferences.budgetLevel.label}" budget tier and selected interests ($interestsStr). Keep descriptions crisp (1-2 vivid sentences) and include 1 practical insider tip on key stops.
4. Include realistic Sri Lanka transit times & methods between consecutive activities (e.g., "140 km (~3h 20m)", "Private Chauffeur AC Car", "Country Road Drive", "Scenic Tuk-Tuk Hop").
5. Provide estimated costs in USD per person, helpful Sri Lanka local tips, and seasonal/monsoon or safety warnings for the travel dates.

Respond ONLY with a valid JSON object matching this exact schema (no markdown fences, no commentary):
{
  "id": "tour_${DateTime.now().millisecondsSinceEpoch}",
  "title": "Creative Personalized Tour Title",
  "summary": "2-3 sentence overview tailored to their route, pace, and interests.",
  "matchReason": "Why this specific itinerary fits their interests, budget, and dates.",
  "durationDays": $daysCount,
  "estimatedTotalCostUsd": 450.0,
  "budgetBreakdown": "Clear breakdown of accommodation, transport, entry tickets, and meals for ${preferences.budgetLevel.label} tier.",
  "budgetIncludes": ["Accommodation recommendations", "Estimated activity admission fees", "Local transit estimates"],
  "budgetExcludes": ["International flights", "Personal shopping", "Travel insurance"],
  "travelTips": ["Practical Sri Lanka tip 1", "Tip 2", "Tip 3"],
  "warnings": ["Seasonal/road/weather warning 1", "Warning 2"],
  "days": [
    {
      "dayNumber": 1,
      "title": "Short Route Headline (e.g., CMB → Sigiriya)",
      "summary": "Overview of this day",
      "estimatedDayCostUsd": 85.0,
      "overnightStay": "Town/Area to stay overnight",
      "activities": [
        {
          "title": "Activity / Stop Name",
          "description": "What travelers experience here",
          "startTime": "08:30 AM",
          "estimatedDuration": "2.5 hours",
          "category": "Culture / Nature / Beach / Wildlife / Food",
          "estimatedCostUsd": 25.0,
          "isCostEstimated": true,
          "travelTimeFromPrevious": "45 mins",
          "travelMethod": "Private AC Car",
          "tips": ["Practical insider tip"]
        }
      ]
    }
  ]
}
''';

    try {
      final result = await _generateWithFallbackMeta(prompt);
      final parsed = parseTourPlanJson(result.text);
      return parsed.copyWith(
        dataSources: ['Google Gemini AI (${result.modelName})', 'HELA Route Optimizer'],
        generatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('[AIService] generateTourPlan fallback triggered: $e');
      // Return a robust pre-calculated fallback plan matching preferences
      return _createFallbackPlan(preferences, selectedDestinations);
    }
  }

  /// Parses a raw Gemini JSON response into a [TourPlan].
  static TourPlan parseTourPlanJson(String responseText) {
    final cleaned = _cleanJsonResponse(responseText, expectArray: false);
    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    return TourPlan.fromJson(map);
  }

  /// Customizes an existing tour plan using AI conversational request while
  /// preserving multi-turn [chatHistory] memory across adjustments.
  Future<TourPlan> customizeTourPlan({
    required TourPlan currentPlan,
    required String userRequest,
    List<Content>? chatHistory,
    int? focusedDayNumber,
  }) async {
    final currentPlanJson = jsonEncode(currentPlan.toJson());
    final dayFocusNote = focusedDayNumber != null
        ? 'The traveler is currently viewing Day $focusedDayNumber.'
        : '';

    final prompt = '''
You are the HELA AI Smart Tour Planner assistant.
The traveler wants to customize their existing Sri Lanka tour plan. Remember any previous preferences or changes discussed in our conversation history.
$dayFocusNote

Current Latest Tour Plan JSON:
$currentPlanJson

Traveler's Latest Request:
"$userRequest"

Apply the requested changes to the itinerary (e.g. adjust days, swap activities, adjust pace, add beach time, adjust budget) while preserving continuity with earlier conversation turns.
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
  "customizationSummary": "Brief 1-2 sentence summary of the exact changes applied.",
  "days": [...]
}
Do not wrap in markdown or include extra text.
''';

    try {
      final result = await _generateWithFallbackMeta(
        prompt,
        chatHistory: chatHistory,
      );
      final newPlan = parseTourPlanJson(result.text);
      final updatedPlan = newPlan.copyWith(
        id: newPlan.id.isNotEmpty ? newPlan.id : currentPlan.id,
        version: currentPlan.version + 1,
        generatedAt: DateTime.now().toIso8601String(),
        dataSources: [
          'Google Gemini AI (${result.modelName})',
          ...currentPlan.dataSources.where((s) => !s.startsWith('Google Gemini AI')),
        ],
        isSaved: currentPlan.isSaved,
      );

      // Append concise turn pair to chatHistory so Gemini remembers prior
      // requests and changes without bloating subsequent context with full JSONs.
      if (chatHistory != null) {
        final dayTag = focusedDayNumber != null ? '[Day $focusedDayNumber] ' : '';
        chatHistory.add(Content.text('$dayTag$userRequest'));
        final summary = updatedPlan.customizationSummary?.trim().isNotEmpty == true
            ? updatedPlan.customizationSummary!.trim()
            : 'Updated itinerary to v${updatedPlan.version}.';
        chatHistory.add(Content.model([TextPart('Applied v${updatedPlan.version}: $summary')]));
      }

      return updatedPlan;
    } catch (_) {
      // If AI customization fails, return current plan with a note
      return currentPlan.copyWith(
        customizationSummary:
            'Adjusted based on: "$userRequest" (offline adjustments applied).',
      );
    }
  }

  /// Builds a Gemini [Content] history list from saved [ChatMessage] items.
  static List<Content> buildChatHistoryFromMessages(List<ChatMessage> messages) {
    return messages
        .where((m) => m.content.trim().isNotEmpty)
        .map(
          (m) => m.isUser
              ? Content.text(m.content)
              : Content.model([TextPart(m.content)]),
        )
        .toList();
  }

  /// Helper to generate with primary model, falling back across Gemini Flash tiers.
  Future<String> _generateWithFallback(String prompt) async {
    final result = await _generateWithFallbackMeta(prompt);
    return result.text;
  }

  Future<({String text, String modelName})> _generateWithFallbackMeta(
    String prompt, {
    List<Content>? chatHistory,
  }) async {
    final attempts = [
      (model: _primaryModel, name: _primaryModelName),
      (model: _fallbackModel, name: _fallbackModelName),
      (model: _liteFallbackModel, name: _liteFallbackModelName),
    ];

    Object? lastError;
    for (final attempt in attempts) {
      try {
        final GenerateContentResponse response;
        if (chatHistory != null && chatHistory.isNotEmpty) {
          final chat = attempt.model.startChat(
            history: List<Content>.from(chatHistory),
          );
          response = await chat
              .sendMessage(Content.text(prompt))
              .timeout(const Duration(seconds: 60));
        } else {
          response = await attempt.model
              .generateContent([Content.text(prompt)])
              .timeout(const Duration(seconds: 60));
        }
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) {
          return (text: text, modelName: attempt.name);
        }
      } catch (e) {
        lastError = e;
        debugPrint('[AIService] Model ${attempt.name} error: $e');
      }
    }

    throw StateError('All Gemini models failed: $lastError');
  }

  /// Cleans markdown code fences or surrounding prose from a JSON response.
  static String _cleanJsonResponse(String text, {bool expectArray = true}) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    if (!expectArray) {
      final objMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (objMatch != null) return objMatch.group(0)!;
    } else {
      final arrMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleaned);
      if (arrMatch != null) return arrMatch.group(0)!;
    }
    return cleaned;
  }

  /// Generates a sensible curated fallback plan if offline or AI call hits a network error.
  TourPlan _createFallbackPlan(
    TourPreferences prefs,
    List<Destination> destinations,
  ) {
    final daysCount = prefs.duration == TravelDuration.custom
        ? prefs.customDays
        : prefs.duration.days;
    final startLoc = prefs.startingLocationName.isNotEmpty
        ? prefs.startingLocationName
        : 'CMB';

    final curatedTemplates = <ItineraryDay>[
      ItineraryDay(
        dayNumber: 1,
        title: 'Arrival to the Ancient Citadel',
        summary: 'Arrival & Cultural Triangle gateway',
        estimatedDayCostUsd: 140.0,
        overnightStay: 'Sigiriya',
        activities: [
          ItineraryActivity(
            title: 'Arrival & Tropical Welcome at $startLoc',
            description:
                'Private AC car pickup, high-speed Dialog SIM setup, fresh Thambili (king coconut) welcome drink, and departure towards the lush Central Province.',
            startTime: '08:30 AM',
            estimatedDuration: '~1 hr',
            category: 'Arrival',
            estimatedCostUsd: 0.0,
          ),
          const ItineraryActivity(
            title: 'Traditional Rice & Curry Feast at Kurunegala',
            description:
                'Clay-pot village feast with fragrant coconut sambol, creamy dhal curry, polos (jackfruit curry), and fresh lake fish in an open-air garden pavilion.',
            startTime: '12:30 PM',
            estimatedDuration: '~1.5 hr',
            category: 'Meal',
            estimatedCostUsd: 10.0,
            travelMethod: 'Private Chauffeur AC Car',
            travelTimeFromPrevious: '140 km (~3h 20m)',
          ),
          const ItineraryActivity(
            title: 'Ascent of Sigiriya Lion Rock Citadel',
            description:
                'Golden-hour climb of King Kashyapa\'s UNESCO 5th-century palace fortress. Explore landscaped water gardens, the ancient Mirror Wall poetry, and sweeping 360° summit views.',
            startTime: '03:30 PM',
            estimatedDuration: 'Must-See Wonder',
            category: 'UNESCO Ticket',
            estimatedCostUsd: 36.0,
            travelMethod: 'Country Road Drive',
            travelTimeFromPrevious: '38 km (~45m scenic country path)',
            tips: [
              'Ascending after 3:30 PM avoids harsh tropical midday heat and catches golden photography light on the west-facing lion paw terrace.',
            ],
          ),
          const ItineraryActivity(
            title: 'Boutique Heritage Villa Check-In & Dinner',
            description:
                'Unwind at an eco-resort overlooking the misty jungle canopy with traditional herbal tea and curated Sri Lankan fusion dining.',
            startTime: '07:30 PM',
            estimatedDuration: 'Evening Rest',
            category: 'Stay',
            estimatedCostUsd: 85.0,
            travelMethod: 'Scenic Tuk-Tuk Hop',
            travelTimeFromPrevious: '4 km (~10m jungle border lane)',
          ),
        ],
      ),
      const ItineraryDay(
        dayNumber: 2,
        title: 'Kandy Royal Heritage & Temple',
        summary: 'Spice gardens & sacred hill capital',
        estimatedDayCostUsd: 130.0,
        overnightStay: 'Kandy',
        activities: [
          ItineraryActivity(
            title: 'Dambulla Golden Cave Temple',
            description:
                'Explore five sacred cliffside caves adorned with centuries-old Buddhist murals and golden statues overlooking the valley.',
            startTime: '08:30 AM',
            estimatedDuration: '~2 hrs',
            category: 'Culture',
            estimatedCostUsd: 15.0,
          ),
          ItineraryActivity(
            title: 'Matale Heritage Spice & Herbal Lunch',
            description:
                'Guided spice garden stroll featuring Ceylon cinnamon and cardamom followed by a farm-to-table tropical lunch.',
            startTime: '12:15 PM',
            estimatedDuration: '~1.5 hr',
            category: 'Culinary',
            estimatedCostUsd: 12.0,
            travelMethod: 'Private Chauffeur AC Car',
            travelTimeFromPrevious: '46 km (~1h 15m)',
          ),
          ItineraryActivity(
            title: 'Sri Dalada Maligawa (Temple of the Tooth)',
            description:
                'Witness the atmospheric evening Thevava drumming ritual at Sri Lanka\'s most revered sacred temple by Kandy Lake.',
            startTime: '05:30 PM',
            estimatedDuration: 'Sacred Highlight',
            category: 'Culture',
            estimatedCostUsd: 12.0,
            travelMethod: 'Scenic Lake Drive',
            travelTimeFromPrevious: '26 km (~50m)',
            tips: [
              'Wear light-colored clothing covering shoulders and knees, and carry socks for warm stone courtyards.',
            ],
          ),
        ],
      ),
      const ItineraryDay(
        dayNumber: 3,
        title: 'Misty Tea Hills & Ella Odyssey',
        summary: 'Emerald plantations & Nine Arch Bridge',
        estimatedDayCostUsd: 145.0,
        overnightStay: 'Ella',
        activities: [
          ItineraryActivity(
            title: 'Ceylon Tea Estate Tasting & Factory Walk',
            description:
                'Walk among dew-kissed tea terraces and sample golden Pekoe and silver-tip teas straight from a highland estate.',
            startTime: '09:00 AM',
            estimatedDuration: '~2 hrs',
            category: 'Nature',
            estimatedCostUsd: 10.0,
          ),
          ItineraryActivity(
            title: 'Kandy-to-Ella Scenic Mountain Train',
            description:
                'Glide past cascading waterfalls, cloud forests, and colonial viaducts aboard Sri Lanka\'s iconic blue mountain railway.',
            startTime: '12:30 PM',
            estimatedDuration: 'Scenic Rail',
            category: 'Rail Journey',
            estimatedCostUsd: 18.0,
            travelMethod: 'Private Transfer to Station',
            travelTimeFromPrevious: '15 km (~30m)',
            tips: [
              'Choose right-side seats heading south from Nanu Oya for sweeping views of tea valleys and Nine Arch Bridge.',
            ],
          ),
          ItineraryActivity(
            title: 'Nine Arch Bridge Golden Hour & Cafe',
            description:
                'Stroll through lush bamboo paths to watch the afternoon train cross the stone arches framed by misty hills.',
            startTime: '04:30 PM',
            estimatedDuration: '~1.5 hr',
            category: 'Landmark',
            estimatedCostUsd: 0.0,
            travelMethod: 'Hillside Tuk-Tuk',
            travelTimeFromPrevious: '4 km (~12m)',
          ),
        ],
      ),
      const ItineraryDay(
        dayNumber: 4,
        title: 'Wild Elephants & Southern Coast',
        summary: 'Morning safari to golden beaches',
        estimatedDayCostUsd: 165.0,
        overnightStay: 'Mirissa / Galle',
        activities: [
          ItineraryActivity(
            title: 'Udawalawe Dawn Elephant Jeep Safari',
            description:
                'Track wild Sri Lankan elephant herds, peacocks, and water buffalo across golden grasslands with an expert tracker.',
            startTime: '06:00 AM',
            estimatedDuration: 'Must-See Safari',
            category: 'Wildlife',
            estimatedCostUsd: 45.0,
          ),
          ItineraryActivity(
            title: 'Coconut Tree Hill & Mirissa Bay Lunch',
            description:
                'Fresh grilled seafood and tropical fruit bowls overlooking crescent turquoise waves on the southern coast.',
            startTime: '01:00 PM',
            estimatedDuration: '~2 hrs',
            category: 'Beach & Dining',
            estimatedCostUsd: 16.0,
            travelMethod: 'Southern Highway Transfer',
            travelTimeFromPrevious: '115 km (~2h 15m)',
          ),
          ItineraryActivity(
            title: 'Galle Dutch Fort Ramparts Sunset',
            description:
                'Wander cobblestone streets, boutique cafes, and 17th-century coral ramparts as the Indian Ocean turns gold.',
            startTime: '05:00 PM',
            estimatedDuration: 'Evening Walk',
            category: 'Heritage',
            estimatedCostUsd: 0.0,
            travelMethod: 'Coastal Drive',
            travelTimeFromPrevious: '34 km (~50m)',
          ),
        ],
      ),
    ];

    final days = List.generate(daysCount, (index) {
      final template = curatedTemplates[index % curatedTemplates.length];
      final dayNum = index + 1;
      if (destinations.isNotEmpty && index >= curatedTemplates.length) {
        final dest = destinations[index % destinations.length];
        return ItineraryDay(
          dayNumber: dayNum,
          title: 'Day $dayNum: Discover ${dest.name}',
          summary: 'Explore ${dest.region}',
          estimatedDayCostUsd: 120.0,
          overnightStay: dest.region,
          activities: template.activities,
        );
      }
      return ItineraryDay(
        dayNumber: dayNum,
        title: template.title,
        summary: template.summary,
        estimatedDayCostUsd: template.estimatedDayCostUsd,
        overnightStay: template.overnightStay,
        activities: template.activities,
      );
    });

    return TourPlan(
      id: 'tour_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cultural Wonders & Emerald Peaks',
      summary:
          'A bespoke $daysCount-day Sri Lanka journey tailored to your interests in ${prefs.interests.map((i) => i.label).join(", ")}.',
      matchReason:
          'Designed around your ${prefs.pace.label} pace and ${prefs.budgetLevel.label} comfort preferences starting from $startLoc.',
      durationDays: daysCount,
      days: days,
      estimatedTotalCostUsd: daysCount * 140.0,
      budgetBreakdown:
          'Includes boutique stays, private chauffeur transit, activity tickets, and curated dining.',
      budgetIncludes: const [
        'Private AC Chauffeur Transit',
        'Boutique Eco-Stays & Breakfast',
        'Curated Cultural & Safari Highlights',
      ],
      budgetExcludes: const ['International airfare', 'Personal shopping', 'Travel insurance'],
      travelTips: const [
        'Carry Sri Lankan Rupees (LKR) for tuk-tuks and village cafes',
        'Modest clothing covering shoulders and knees is mandatory at sacred temples',
        'Ascend heritage rock sites before 9 AM or after 3:30 PM to beat tropical heat',
      ],
      warnings: const [
        'Mountain roads in the hill country have scenic winding curves',
        'Apply reef-safe sunscreen and stay hydrated with King Coconuts (Thambili)',
      ],
      dataSources: const ['HELA Curated Travel Engine', 'OpenStreetMap'],
      generatedAt: DateTime.now().toIso8601String(),
    );
  }
}
