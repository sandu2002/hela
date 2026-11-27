import 'dart:convert';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:flutter/foundation.dart';
import 'package:hela/config/api_config.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/models/destination.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Minimal chat-history types (replaces google_generative_ai dependency for
// the history we pass back to customizeTourPlan).
// ---------------------------------------------------------------------------

/// A single turn in the customization conversation history.
class ChatTurn {
  final bool isUser;
  final String text;
  const ChatTurn({required this.isUser, required this.text});
}

/// Response metadata returned by Ask HELA AI chat requests.
class AskHelaReply {
  final String text;
  final String provider;
  final String modelName;

  const AskHelaReply({
    required this.text,
    required this.provider,
    required this.modelName,
  });
}

/// Service for generating AI-powered tour recommendations, full day-by-day
/// itineraries, and conversational customizations via the HELA backend proxy
/// (plus direct DeepSeek / Gemini client fallbacks when offline from backend).
class AIService {
  /// HTTP client — injectable for tests.
  final http.Client _client;

  /// Backend AI proxy endpoint.
  final String _backendUrl;

  /// Backend Ask HELA chat endpoint (DeepSeek primary + Gemini fallback).
  final String _chatUrl;

  /// Optional DeepSeek / OpenRouter / NVIDIA NIM / OpenAI-compatible overrides
  /// (primarily for tests or local overrides).
  final String _deepseekApiKey;
  final String _deepseekBaseUrl;
  final String _deepseekModel;
  final String _geminiApiKey;

  AIService({
    http.Client? client,
    String? backendUrl,
    String? chatUrl,
    String? deepseekApiKey,
    String? deepseekBaseUrl,
    String? deepseekModel,
    String? geminiApiKey,
  }) : _client = client ?? http.Client(),
       _backendUrl = backendUrl ?? ApiConfig.tourGenerateUrl,
       _chatUrl = chatUrl ?? ApiConfig.askHelaChatUrl,
       _deepseekApiKey = (deepseekApiKey ?? ApiConfig.effectiveDeepseekApiKey)
           .trim(),
       _deepseekBaseUrl = (deepseekBaseUrl ?? ApiConfig.deepseekBaseUrl).trim(),
       _deepseekModel = (deepseekModel ?? ApiConfig.deepseekModel).trim(),
       _geminiApiKey = (geminiApiKey ?? ApiConfig.geminiApiKey).trim();

  // ── Public API ────────────────────────────────────────────────────────────

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

    final candidatesSummary = candidateDestinations
        .take(10)
        .map((d) {
          return '- ${d.name} (${d.region}): ${d.description}';
        })
        .join('\n');

    final prompt =
        '''
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
      final result = await _callAiWithFallbackMeta(
        prompt,
        expectJsonArray: true,
      );
      final list = _decodeJsonListResponse(result.text);

      final results = list.map((item) {
        final map = item as Map<String, dynamic>;
        final matchedCandidate = candidateDestinations.firstWhere(
          (c) => c.name.toLowerCase().contains(
            (map['name'] as String? ?? '').toLowerCase(),
          ),
          orElse: () => const Destination(
            sourceId: 'ai_dest',
            name: '',
            latitude: 7.8731,
            longitude: 80.7718,
          ),
        );

        return Destination(
          sourceId:
              map['sourceId']?.toString() ??
              'ai_${DateTime.now().millisecondsSinceEpoch}',
          name: map['name']?.toString() ?? 'Sri Lanka Destination',
          description: map['description']?.toString() ?? '',
          isDescriptionAIGenerated: true,
          latitude:
              (map['latitude'] as num?)?.toDouble() ??
              matchedCandidate.latitude,
          longitude:
              (map['longitude'] as num?)?.toDouble() ??
              matchedCandidate.longitude,
          region: map['region']?.toString() ?? matchedCandidate.region,
          categories:
              (map['categories'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              matchedCandidate.categories,
          imageUrl: matchedCandidate.imageUrl.isNotEmpty
              ? matchedCandidate.imageUrl
              : SriLankaImages.sigiriya,
          sourceUrl: matchedCandidate.sourceUrl,
          retrievedAt: DateTime.now().toIso8601String(),
          attribution: _formatProviderLabel(result.provider) == 'DeepSeek AI'
              ? 'Curated by DeepSeek AI & OpenStreetMap'
              : 'Curated by Gemini AI & OpenStreetMap',
          relevanceScore: (map['relevanceScore'] as num?)?.toDouble() ?? 0.90,
        );
      }).toList();

      return results.isNotEmpty
          ? results
          : candidateDestinations.take(6).toList();
    } catch (_) {
      return candidateDestinations.take(6).toList();
    }
  }

  /// Generates a comprehensive day-by-day tour plan via the HELA backend.
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
    final endLoc = preferences.endLocationName.trim().isNotEmpty
        ? preferences.endLocationName.trim()
        : startLoc;
    final partyDetails = (adults != null || children != null)
        ? '${adults ?? preferences.numberOfTravelers} adult(s), ${children ?? 0} child(ren)'
        : '${preferences.numberOfTravelers} person(s)';
    final dateWindow = (startDate != null && endDate != null)
        ? '${startDate.toIso8601String().split('T').first} to ${endDate.toIso8601String().split('T').first}'
        : '$daysCount flexible days';
    final dietaryStr = preferences.dietaryPreferences.isNotEmpty
        ? preferences.dietaryPreferences.join(', ')
        : 'No specific restrictions';
    final mobilityStr = preferences.accessibilityNeeds.isNotEmpty
        ? preferences.accessibilityNeeds.join(', ')
        : 'Standard walking & climbing tolerance';
    final langInstruction =
        (preferredLanguage != null && preferredLanguage.toUpperCase() != 'EN')
        ? 'Write titles, summaries, activity descriptions, and tips in language code "$preferredLanguage" where natural (keep JSON keys strictly in English).'
        : '';

    final prompt =
        '''
You are HELA, an expert Sri Lanka Travel Planner AI. Create a realistic, personalized $daysCount-day Sri Lanka itinerary tailored specifically to every preference below.

Traveler Profile:
- Trip Duration: $daysCount day(s)
- Travel Dates: $dateWindow
- Starting Location: $startLoc
- Ending / Drop-off Location: $endLoc
- Must-Visit / Preferred Places: $destinationsStr
- Selected Interests: $interestsStr
- Budget Tier: ${preferences.budgetLevel.label} (${preferences.budgetLevel.description})${preferences.budgetAmount != null ? ' • Target Budget: \$${preferences.budgetAmount}' : ''}
- Travelers: $partyDetails
- Travel Pace: ${preferences.pace.label} (${preferences.pace.description})
- Preferred Transport Mode: ${preferences.transportMode}
- Accommodation Style: ${preferences.accommodationType.label}
- Dietary Requirements: $dietaryStr
- Mobility & Comfort Constraints: $mobilityStr
${preferences.additionalNotes.isNotEmpty ? '- Special Requests / Must-Dos & Avoids: ${preferences.additionalNotes}' : ''}
${langInstruction.isNotEmpty ? '- Language: $langInstruction' : ''}

Requirements:
1. Generate ALL $daysCount days (dayNumber 1 through $daysCount) progressing geographically logically across Sri Lanka starting from "$startLoc" and concluding smoothly at "$endLoc".
2. Respect the traveler's "${preferences.pace.label}" pace: include 2-3 stops/activities for Relaxed, 3-4 for Moderate/Balanced, and 4-5 for Active per day.
3. Tailor stays (${preferences.accommodationType.label}), dining (strictly respecting: $dietaryStr), and transport (${preferences.transportMode}) to the "${preferences.budgetLevel.label}" budget tier and selected interests ($interestsStr). Respect mobility constraints ($mobilityStr) when selecting climbs, stairs, or drive lengths. Keep descriptions crisp (1-2 vivid sentences) and include 1 practical insider tip on key stops.
4. Include realistic Sri Lanka transit times & methods matching "${preferences.transportMode}" between consecutive activities.
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
      "title": "Short Route Headline",
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
      final result = await _callAiWithFallbackMeta(prompt);
      final parsed = parseTourPlanJson(result.text);
      final providerLabel = _formatProviderLabel(result.provider);
      return parsed.copyWith(
        dataSources: [
          '$providerLabel (${result.modelName})',
          'HELA Route Optimizer',
        ],
        generatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('[AIService] generateTourPlan fallback triggered: $e');
      return _createFallbackPlan(preferences, selectedDestinations);
    }
  }

  /// Parses a raw Gemini JSON response into a [TourPlan].
  static TourPlan parseTourPlanJson(String responseText) {
    final cleaned = _cleanJsonResponse(responseText, expectArray: false);
    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    return TourPlan.fromJson(map);
  }

  /// Customizes an existing tour plan using conversational [chatHistory].
  /// Only the **summary** of the current plan and the focused day (if any)
  /// are sent — not the entire plan JSON — to keep token usage bounded.
  Future<TourPlan> customizeTourPlan({
    required TourPlan currentPlan,
    required String userRequest,
    List<ChatTurn>? chatHistory,
    int? focusedDayNumber,
  }) async {
    // Build a compact context: plan header + only the relevant day
    final dayFocusNote = focusedDayNumber != null
        ? 'The traveler is currently viewing Day $focusedDayNumber.'
        : '';

    // Send a lightweight plan summary instead of full JSON
    final planSummary = _buildPlanSummary(currentPlan, focusedDayNumber);

    // Append a brief conversation history (last 6 turns max to bound tokens)
    final historyStr = (chatHistory ?? []).reversed
        .take(6)
        .toList()
        .reversed
        .map((t) => '${t.isUser ? "Traveler" : "HELA"}: ${t.text}')
        .join('\n');

    final prompt =
        '''
You are the HELA AI Smart Tour Planner assistant.
The traveler wants to customize their existing Sri Lanka tour plan.
$dayFocusNote
${historyStr.isNotEmpty ? '\nConversation so far:\n$historyStr\n' : ''}
Current Tour Plan Summary:
$planSummary

Traveler's Latest Request:
"$userRequest"

Apply the requested changes while preserving realistic Sri Lanka routing.
Respond ONLY with a valid JSON object matching the full TourPlan schema, plus "customizationSummary" field:
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
  "customizationSummary": "Brief 1-2 sentence summary of changes applied.",
  "days": [...]
}
No markdown or extra text.
''';

    try {
      final result = await _callAiWithFallbackMeta(prompt);
      final newPlan = parseTourPlanJson(result.text);
      final providerLabel = _formatProviderLabel(result.provider);
      final updatedPlan = newPlan.copyWith(
        id: newPlan.id.isNotEmpty ? newPlan.id : currentPlan.id,
        version: currentPlan.version + 1,
        generatedAt: DateTime.now().toIso8601String(),
        dataSources: [
          '$providerLabel (${result.modelName})',
          ...currentPlan.dataSources.where(
            (s) =>
                !s.startsWith('Google Gemini AI') &&
                !s.startsWith('DeepSeek AI'),
          ),
        ],
        isSaved: currentPlan.isSaved,
      );

      // Record compact turn so the next call has context
      chatHistory?.add(ChatTurn(isUser: true, text: userRequest));
      final summary =
          updatedPlan.customizationSummary?.trim().isNotEmpty == true
          ? updatedPlan.customizationSummary!.trim()
          : 'Updated itinerary to v${updatedPlan.version}.';
      chatHistory?.add(
        ChatTurn(
          isUser: false,
          text: 'Applied v${updatedPlan.version}: $summary',
        ),
      );

      return updatedPlan;
    } catch (_) {
      return currentPlan.copyWith(
        customizationSummary:
            'Adjusted based on: "$userRequest" (offline adjustments applied).',
      );
    }
  }

  /// Builds a [ChatTurn] history list from saved [ChatMessage] items.
  static List<ChatTurn> buildChatHistoryFromMessages(
    List<ChatMessage> messages,
  ) {
    return messages
        .where((m) => m.content.trim().isNotEmpty)
        .map((m) => ChatTurn(isUser: m.isUser, text: m.content))
        .toList();
  }

  /// Sends a conversational Ask HELA query using DeepSeek as primary AI
  /// with automatic fallback to Gemini.
  Future<String?> chatWithHela({
    required String systemInstruction,
    required List<ChatTurn> history,
    required String prompt,
  }) async {
    final reply = await chatWithHelaWithMeta(
      systemInstruction: systemInstruction,
      history: history,
      prompt: prompt,
    );
    return reply?.text;
  }

  /// Sends a conversational Ask HELA query and returns reply text along with
  /// the resolved AI provider (`deepseek` or `gemini`) and model identifier.
  ///
  /// Order of execution:
  /// 1. HELA backend `/api/tours/chat` (tries DeepSeek first, falls back to Gemini).
  /// 2. Direct OpenAI-compatible DeepSeek / OpenRouter / NVIDIA NIM / Ollama client fallback.
  /// 3. Direct Google Gemini REST fallback.
  Future<AskHelaReply?> chatWithHelaWithMeta({
    required String systemInstruction,
    required List<ChatTurn> history,
    required String prompt,
  }) async {
    final recentHistory = history.reversed.take(10).toList().reversed.toList();
    final historyStr = recentHistory
        .map((t) => '${t.isUser ? "Traveler" : "HELA"}: ${t.text}')
        .join('\n');

    final fullPrompt =
        '''
$systemInstruction

${historyStr.isNotEmpty ? 'Conversation history:\n$historyStr\n\n' : ''}Traveler: $prompt
HELA:''';

    // 1. Primary path: HELA backend proxy (DeepSeek primary -> Gemini fallback)
    try {
      final response = await _client
          .post(
            Uri.parse(_chatUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'preferredProvider': 'deepseek',
              'systemInstruction': systemInstruction,
              'history': recentHistory
                  .map((t) => {'isUser': t.isUser, 'text': t.text})
                  .toList(),
              'prompt': prompt,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final text = stripReasoningTags(body['text']?.toString() ?? '');
        if (text.isNotEmpty) {
          history.add(ChatTurn(isUser: true, text: prompt));
          history.add(ChatTurn(isUser: false, text: text));
          return AskHelaReply(
            text: text,
            provider: body['provider']?.toString() ?? 'deepseek',
            modelName: body['modelName']?.toString() ?? 'deepseek',
          );
        }
      } else {
        debugPrint(
          '[AIService] chatWithHela backend proxy HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[AIService] chatWithHela backend proxy error: $e');
    }

    // 2. Direct fallback #1: DeepSeek (OpenRouter / NVIDIA NIM / DeepSeek API / Ollama)
    final deepSeekResult = await _callDeepSeekDirect(
      messages: [
        if (systemInstruction.trim().isNotEmpty)
          {'role': 'system', 'content': systemInstruction.trim()},
        ...recentHistory.map(
          (t) => {'role': t.isUser ? 'user' : 'assistant', 'content': t.text},
        ),
        {'role': 'user', 'content': prompt},
      ],
      timeout: const Duration(seconds: 15),
    );
    if (deepSeekResult != null) {
      history.add(ChatTurn(isUser: true, text: prompt));
      history.add(ChatTurn(isUser: false, text: deepSeekResult.text));
      return deepSeekResult;
    }

    // 3. Direct fallback #2: Google Gemini
    if (_geminiApiKey.isNotEmpty) {
      final geminiResult = await _callGeminiDirect(
        fullPrompt,
        responseMimeType: 'text/plain',
        timeout: const Duration(seconds: 15),
      );
      if (geminiResult != null) {
        history.add(ChatTurn(isUser: true, text: prompt));
        history.add(ChatTurn(isUser: false, text: geminiResult.text));
        return geminiResult;
      }
    }

    return null;
  }

  /// Strips `<think>...</think>` reasoning traces from DeepSeek-R1 style responses.
  static String stripReasoningTags(String text) {
    return text
        .replaceAll(
          RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false),
          '',
        )
        .trim();
  }

  ({String baseUrl, List<String> models})? _resolveDeepSeekProviderConfig() {
    final normalizedBase = _deepseekBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final isLocalEndpoint = RegExp(
      r'^https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?',
      caseSensitive: false,
    ).hasMatch(normalizedBase);

    if (_deepseekApiKey.isEmpty && !isLocalEndpoint) {
      return null;
    }

    String resolvedBase = normalizedBase;
    List<String> defaultModels;

    if (_deepseekApiKey.startsWith('sk-or-')) {
      if (resolvedBase.isEmpty) resolvedBase = 'https://openrouter.ai/api/v1';
      defaultModels = [
        'deepseek/deepseek-v4.1-flash',
        'deepseek/deepseek-chat',
        ApiConfig.deepseekFallbackModel,
      ];
    } else if (_deepseekApiKey.startsWith('nvapi-')) {
      if (resolvedBase.isEmpty) {
        resolvedBase = 'https://integrate.api.nvidia.com/v1';
      }
      defaultModels = ['deepseek-ai/deepseek-v3.2', 'deepseek-ai/deepseek-r1'];
    } else if (isLocalEndpoint) {
      defaultModels = ['deepseek-r1', 'deepseek-chat'];
    } else {
      if (resolvedBase.isEmpty) resolvedBase = 'https://api.deepseek.com/v1';
      defaultModels = ['deepseek-chat', 'deepseek-reasoner'];
    }

    final models = <String>{
      if (_deepseekModel.isNotEmpty) _deepseekModel,
      ...defaultModels.where((m) => m.trim().isNotEmpty),
    }.toList();

    return (baseUrl: resolvedBase, models: models);
  }

  /// Direct OpenAI-compatible DeepSeek request (used for Ask HELA & Trip Planner fallbacks).
  Future<AskHelaReply?> _callDeepSeekDirect({
    required List<Map<String, String>> messages,
    bool expectJson = false,
    bool expectJsonArray = false,
    Duration timeout = const Duration(seconds: 35),
  }) async {
    final config = _resolveDeepSeekProviderConfig();
    if (config == null) return null;

    final uri = Uri.parse('${config.baseUrl}/chat/completions');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_deepseekApiKey.isNotEmpty)
        'Authorization': 'Bearer $_deepseekApiKey',
      if (config.baseUrl.contains('openrouter.ai')) ...{
        'HTTP-Referer': 'https://hela.travel',
        'X-Title': 'HELA Sri Lanka Travel Companion',
      },
    };

    for (final model in config.models) {
      try {
        final payload = <String, dynamic>{
          'model': model,
          'messages': messages,
          'temperature': expectJson ? 0.5 : 0.7,
        };
        final supportsJsonObject =
            expectJson &&
            !expectJsonArray &&
            !config.baseUrl.contains('integrate.api.nvidia.com') &&
            !model.contains('v4') &&
            !model.contains('free');
        if (supportsJsonObject) {
          payload['response_format'] = {'type': 'json_object'};
        }

        final res = await _client
            .post(uri, headers: headers, body: jsonEncode(payload))
            .timeout(timeout);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final choices = data['choices'] as List?;
          final firstChoice = choices != null && choices.isNotEmpty
              ? choices.first as Map<String, dynamic>?
              : null;
          final message = firstChoice?['message'] as Map<String, dynamic>?;
          final rawContent = message?['content']?.toString() ?? '';
          final cleaned = stripReasoningTags(rawContent);
          if (cleaned.isNotEmpty) {
            return AskHelaReply(
              text: cleaned,
              provider: 'deepseek',
              modelName: model,
            );
          }
        } else {
          debugPrint(
            '[AIService] DeepSeek ($model) HTTP ${res.statusCode}: ${res.body}',
          );
        }
      } catch (e) {
        debugPrint('[AIService] DeepSeek ($model) error: $e');
      }
    }
    return null;
  }

  /// Direct Gemini client fallback for both text and JSON generation.
  Future<AskHelaReply?> _callGeminiDirect(
    String prompt, {
    String responseMimeType = 'text/plain',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final models = [
      ApiConfig.geminiModel,
      ApiConfig.geminiFallbackModel,
      ApiConfig.geminiLiteFallbackModel,
    ];
    for (final model in models) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_geminiApiKey',
        );
        final res = await _client
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
                'generationConfig': {'responseMimeType': responseMimeType},
              }),
            )
            .timeout(timeout);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List?;
          final firstCandidate = candidates != null && candidates.isNotEmpty
              ? candidates.first as Map<String, dynamic>?
              : null;
          final content = firstCandidate?['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          final firstPart = parts != null && parts.isNotEmpty
              ? parts.first as Map<String, dynamic>?
              : null;
          final text = firstPart?['text']?.toString().trim();
          if (text != null && text.isNotEmpty) {
            return AskHelaReply(
              text: text,
              provider: 'gemini',
              modelName: model,
            );
          }
        } else {
          debugPrint(
            '[AIService] Gemini ($model) HTTP ${res.statusCode}: ${res.body}',
          );
        }
      } catch (e) {
        debugPrint('[AIService] Gemini ($model) error: $e');
      }
    }
    return null;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Calls HELA backend first (preferring DeepSeek), then falls back to direct
  /// DeepSeek and direct Gemini endpoints when backend is unreachable.
  Future<AskHelaReply> _callAiWithFallbackMeta(
    String prompt, {
    String responseMimeType = 'application/json',
    bool preferDeepseek = true,
    bool expectJsonArray = false,
  }) async {
    Object? backendError;
    try {
      return await _callBackendMeta(
        prompt,
        responseMimeType: responseMimeType,
        preferredProvider: preferDeepseek ? 'deepseek' : 'gemini',
        expectArray: expectJsonArray,
      );
    } catch (e) {
      backendError = e;
      debugPrint(
        '[AIService] Structured AI backend unavailable, trying direct fallback: $e',
      );
    }

    if (preferDeepseek) {
      final deepSeekResult = await _callDeepSeekDirect(
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        expectJson: responseMimeType == 'application/json',
        expectJsonArray: expectJsonArray,
        timeout: const Duration(seconds: 40),
      );
      if (deepSeekResult != null) {
        return deepSeekResult;
      }
    }

    if (_geminiApiKey.isNotEmpty) {
      final geminiResult = await _callGeminiDirect(
        prompt,
        responseMimeType: responseMimeType,
        timeout: const Duration(seconds: 30),
      );
      if (geminiResult != null) {
        return geminiResult;
      }
    }

    if (backendError is Error) throw backendError;
    throw StateError('All AI providers failed: $backendError');
  }

  Future<AskHelaReply> _callBackendMeta(
    String prompt, {
    String responseMimeType = 'application/json',
    String preferredProvider = 'deepseek',
    bool expectArray = false,
  }) async {
    final response = await _client
        .post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prompt': prompt,
            'responseMimeType': responseMimeType,
            'preferredProvider': preferredProvider,
            'expectArray': expectArray,
          }),
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode != 200) {
      throw StateError(
        'Backend AI proxy returned ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = stripReasoningTags(body['text']?.toString() ?? '');
    if (text.isEmpty) {
      throw StateError('Backend returned empty AI response');
    }
    return AskHelaReply(
      text: text,
      provider: body['provider']?.toString() ?? 'gemini',
      modelName:
          body['modelName']?.toString() ??
          body['model']?.toString() ??
          'gemini',
    );
  }

  static String _formatProviderLabel(String provider) {
    return provider.toLowerCase().contains('deepseek')
        ? 'DeepSeek AI'
        : 'Google Gemini AI';
  }

  static List<dynamic> _decodeJsonListResponse(String responseText) {
    final cleaned = _cleanJsonResponse(responseText, expectArray: true);
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is List<dynamic>) return decoded;
      if (decoded is Map<String, dynamic>) {
        for (final val in decoded.values) {
          if (val is List<dynamic>) return val;
        }
      }
    } catch (_) {
      final fallbackObj = jsonDecode(
        _cleanJsonResponse(responseText, expectArray: false),
      );
      if (fallbackObj is Map<String, dynamic>) {
        for (final val in fallbackObj.values) {
          if (val is List<dynamic>) return val;
        }
      }
    }
    throw const FormatException('Expected JSON array response from AI');
  }

  /// Builds a compact plan summary to reduce token usage in customization.
  static String _buildPlanSummary(TourPlan plan, int? focusedDay) {
    final buf = StringBuffer();
    buf.writeln('Title: ${plan.title}');
    buf.writeln('Duration: ${plan.durationDays} days');
    buf.writeln('Summary: ${plan.summary}');
    if (focusedDay != null) {
      final day = plan.days.firstWhere(
        (d) => d.dayNumber == focusedDay,
        orElse: () => plan.days.first,
      );
      buf.writeln('\nFocused Day $focusedDay: ${day.title}');
      buf.writeln(
        'Activities: ${day.activities.map((a) => a.title).join(', ')}',
      );
    } else {
      buf.writeln('\nDays overview:');
      for (final d in plan.days) {
        buf.writeln(
          '  Day ${d.dayNumber}: ${d.title} (${d.activities.length} activities)',
        );
      }
    }
    return buf.toString();
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

  /// Generates a sensible curated fallback plan if the backend is unreachable.
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
    final endLoc = prefs.endLocationName.trim().isNotEmpty
        ? prefs.endLocationName.trim()
        : startLoc;
    final transportHint = prefs.transportMode.isNotEmpty
        ? prefs.transportMode
        : 'Private Chauffeur AC Car';

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
          'A bespoke $daysCount-day Sri Lanka journey from $startLoc to $endLoc via $transportHint, tailored to your interests in ${prefs.interests.map((i) => i.label).join(", ")}.',
      matchReason:
          'Designed around your ${prefs.pace.label} pace, ${prefs.budgetLevel.label} budget, ${prefs.accommodationType.label} stays, and $transportHint${prefs.dietaryPreferences.isNotEmpty ? ' (${prefs.dietaryPreferences.join(", ")} dining)' : ''}.',
      durationDays: daysCount,
      days: days,
      estimatedTotalCostUsd: daysCount * 140.0,
      budgetBreakdown:
          'Includes ${prefs.accommodationType.label} stays, $transportHint transit, activity tickets, and curated dining.',
      budgetIncludes: const [
        'Private AC Chauffeur Transit',
        'Boutique Eco-Stays & Breakfast',
        'Curated Cultural & Safari Highlights',
      ],
      budgetExcludes: const [
        'International airfare',
        'Personal shopping',
        'Travel insurance',
      ],
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
