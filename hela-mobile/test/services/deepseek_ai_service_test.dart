import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/services/ai_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AIService DeepSeek Ask HELA integration', () {
    test('stripReasoningTags removes DeepSeek-R1 <think> blocks cleanly', () {
      const raw =
          '<think>Thinking about Kandy train timings...\nStep 2...</think>\n\nThe scenic blue train departs Kandy at 08:47 AM daily.';
      expect(
        AIService.stripReasoningTags(raw),
        'The scenic blue train departs Kandy at 08:47 AM daily.',
      );
    });

    test(
      'chatWithHelaWithMeta prioritizes backend /api/tours/chat with preferredProvider=deepseek',
      () async {
        final capturedBodies = <Map<String, dynamic>>[];
        final mockClient = MockClient((request) async {
          expect(request.url.toString(), 'https://example.test/api/tours/chat');
          capturedBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response(
            jsonEncode({
              'success': true,
              'text':
                  'Tuk-tuk metered fares start at LKR 100-120 for the first km.',
              'modelName': 'deepseek/deepseek-v4.1-flash',
              'provider': 'deepseek',
            }),
            200,
          );
        });

        final service = AIService(
          client: mockClient,
          chatUrl: 'https://example.test/api/tours/chat',
        );
        final history = <ChatTurn>[];

        final reply = await service.chatWithHelaWithMeta(
          systemInstruction: 'You are HELA.',
          history: history,
          prompt: 'What is the Colombo tuk-tuk meter rate?',
        );

        expect(reply, isNotNull);
        expect(reply!.provider, 'deepseek');
        expect(reply.modelName, 'deepseek/deepseek-v4.1-flash');
        expect(reply.text, contains('LKR 100-120'));
        expect(capturedBodies.single['preferredProvider'], 'deepseek');
        expect(history.length, 2);
        expect(history[0].isUser, isTrue);
        expect(history[1].isUser, isFalse);
      },
    );

    test(
      'falls back from failed backend to OpenRouter DeepSeek and retries openrouter/free on quota error',
      () async {
        final requestedModels = <String>[];
        Uri? openRouterUri;
        Map<String, String>? openRouterHeaders;

        final mockClient = MockClient((request) async {
          if (request.url.path.endsWith('/api/tours/chat')) {
            return http.Response('Backend offline', 503);
          }
          openRouterUri = request.url;
          openRouterHeaders = request.headers;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final model = body['model'] as String;
          requestedModels.add(model);

          if (model == 'openrouter/free') {
            return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {
                      'content':
                          '<think>Check Sigiriya entry hours.</think>Arrive at Sigiriya by 06:30 AM.',
                    },
                  },
                ],
              }),
              200,
            );
          }
          return http.Response(
            '{"error":{"message":"Insufficient credits"}}',
            402,
          );
        });

        final service = AIService(
          client: mockClient,
          chatUrl: 'https://example.test/api/tours/chat',
          deepseekApiKey: 'sk-or-v1-test-free-key',
        );

        final history = <ChatTurn>[];
        final reply = await service.chatWithHelaWithMeta(
          systemInstruction: 'Be helpful.',
          history: history,
          prompt: 'Best time for Sigiriya?',
        );

        expect(
          openRouterUri.toString(),
          'https://openrouter.ai/api/v1/chat/completions',
        );
        expect(
          openRouterHeaders?['Authorization'],
          'Bearer sk-or-v1-test-free-key',
        );
        expect(openRouterHeaders?['HTTP-Referer'], 'https://hela.travel');
        expect(
          requestedModels,
          containsAllInOrder([
            'deepseek/deepseek-v4.1-flash',
            'deepseek/deepseek-chat',
            'openrouter/free',
          ]),
        );
        expect(reply, isNotNull);
        expect(reply!.provider, 'deepseek');
        expect(reply.modelName, 'openrouter/free');
        expect(reply.text, 'Arrive at Sigiriya by 06:30 AM.');
      },
    );

    test('auto-detects NVIDIA NIM endpoint from nvapi- key prefix', () async {
      Uri? capturedUri;
      final requestedModels = <String>[];
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/tours/chat')) {
          return http.Response('offline', 500);
        }
        capturedUri = request.url;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requestedModels.add(body['model'] as String);
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content':
                      'Wear modest white clothing covering shoulders and knees.',
                },
              },
            ],
          }),
          200,
        );
      });

      final service = AIService(
        client: mockClient,
        chatUrl: 'https://example.test/api/tours/chat',
        deepseekApiKey: 'nvapi-test-token-123',
      );

      final reply = await service.chatWithHelaWithMeta(
        systemInstruction: 'Guide',
        history: [],
        prompt: 'Temple etiquette?',
      );

      expect(
        capturedUri.toString(),
        'https://integrate.api.nvidia.com/v1/chat/completions',
      );
      expect(requestedModels.first, 'deepseek-ai/deepseek-v3.2');
      expect(reply?.provider, 'deepseek');
      expect(reply?.text, contains('modest white clothing'));
    });

    test('falls back to Gemini when both backend and DeepSeek fail', () async {
      final callOrder = <String>[];
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/tours/chat')) {
          callOrder.add('backend');
          return http.Response('unavailable', 503);
        }
        if (request.url.host == 'api.deepseek.com') {
          callOrder.add('deepseek');
          return http.Response('rate limit', 429);
        }
        if (request.url.host == 'generativelanguage.googleapis.com') {
          callOrder.add('gemini');
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text':
                            'Gemini fallback answered with Nine Arch Bridge train timings.',
                      },
                    ],
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response('unexpected', 404);
      });

      final service = AIService(
        client: mockClient,
        chatUrl: 'https://example.test/api/tours/chat',
        deepseekApiKey: 'sk-deepseek-test',
        geminiApiKey: 'AIzaTestGeminiKey',
      );

      final reply = await service.chatWithHelaWithMeta(
        systemInstruction: 'You are HELA.',
        history: [],
        prompt: 'Ella train times?',
      );

      expect(callOrder.first, 'backend');
      expect(callOrder, contains('deepseek'));
      expect(callOrder.last, 'gemini');
      expect(reply, isNotNull);
      expect(reply!.provider, 'gemini');
      expect(reply.text, contains('Gemini fallback answered'));
    });
  });

  group('AIService DeepSeek Trip Planner integration', () {
    test(
      'generateTourPlan sends preferredProvider=deepseek and tags DeepSeek AI source',
      () async {
        Map<String, dynamic>? capturedRequest;
        final mockClient = MockClient((request) async {
          expect(
            request.url.toString(),
            'https://example.test/api/tours/generate',
          );
          capturedRequest = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'success': true,
              'provider': 'deepseek',
              'modelName': 'deepseek/deepseek-v4.1-flash',
              'text': jsonEncode({
                'id': 'tour_ds_1',
                'title': 'Ceylon Tea & Hillscapes',
                'summary': 'A custom 2-day highland journey.',
                'matchReason':
                    'Matched to your scenic rail & nature interests.',
                'durationDays': 2,
                'estimatedTotalCostUsd': 240.0,
                'days': [
                  {
                    'dayNumber': 1,
                    'title': 'Kandy to Nuwara Eliya',
                    'summary': 'Lush tea plantations',
                    'estimatedDayCostUsd': 120.0,
                    'overnightStay': 'Nuwara Eliya',
                    'activities': [
                      {
                        'title': 'Tea Factory Tasting',
                        'description': 'Morning Ceylon BOP tasting',
                        'startTime': '09:00 AM',
                        'estimatedDuration': '2h',
                        'category': 'Nature',
                        'estimatedCostUsd': 10.0,
                      },
                    ],
                  },
                ],
              }),
            }),
            200,
          );
        });

        final service = AIService(
          client: mockClient,
          backendUrl: 'https://example.test/api/tours/generate',
        );
        final plan = await service.generateTourPlan(
          preferences: const TourPreferences(
            duration: TravelDuration.twoDays,
            startingLocationName: 'Kandy',
            interests: {TravelInterest.nature},
          ),
          selectedDestinations: const [],
        );

        expect(capturedRequest?['preferredProvider'], 'deepseek');
        expect(plan.title, 'Ceylon Tea & Hillscapes');
        expect(
          plan.dataSources.first,
          'DeepSeek AI (deepseek/deepseek-v4.1-flash)',
        );
      },
    );

    test(
      'generateTourPlan falls back directly to OpenRouter DeepSeek when backend is unreachable',
      () async {
        Uri? openRouterUri;
        final directPlanJson = jsonEncode({
          'id': 'tour_ds_direct',
          'title': 'Direct DeepSeek Ella Escape',
          'summary': 'Seamless direct fallback itinerary.',
          'durationDays': 2,
          'estimatedTotalCostUsd': 190.0,
          'days': [
            {
              'dayNumber': 1,
              'title': 'Ella Ridge Walk',
              'summary': 'Hike Little Adams Peak',
              'estimatedDayCostUsd': 95.0,
              'overnightStay': 'Ella',
              'activities': [],
            },
          ],
        });

        final mockClient = MockClient((request) async {
          if (request.url.path.endsWith('/api/tours/generate')) {
            return http.Response('offline', 503);
          }
          openRouterUri = request.url;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content':
                        '<think>Plan Ella highlights.</think>\n```json\n$directPlanJson\n```',
                  },
                },
              ],
            }),
            200,
          );
        });

        final service = AIService(
          client: mockClient,
          backendUrl: 'https://example.test/api/tours/generate',
          deepseekApiKey: 'sk-or-v1-test-trip-planner',
        );

        final plan = await service.generateTourPlan(
          preferences: const TourPreferences(
            duration: TravelDuration.twoDays,
            startingLocationName: 'Colombo',
            interests: {TravelInterest.hiking},
          ),
          selectedDestinations: const [],
        );

        expect(
          openRouterUri.toString(),
          'https://openrouter.ai/api/v1/chat/completions',
        );
        expect(plan.title, 'Direct DeepSeek Ella Escape');
        expect(plan.dataSources.first, startsWith('DeepSeek AI ('));

        final customized = await service.customizeTourPlan(
          currentPlan: plan,
          userRequest: 'Add sunset train bridge stop',
          focusedDayNumber: 1,
        );
        expect(customized.dataSources.first, startsWith('DeepSeek AI ('));
        expect(customized.version, 2);
      },
    );

    test(
      'discoverDestinations parses object-wrapped arrays from DeepSeek JSON responses',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'provider': 'deepseek',
              'modelName': 'deepseek/deepseek-v4.1-flash',
              'text': jsonEncode({
                'destinations': [
                  {
                    'sourceId': 'dest_galle',
                    'name': 'Galle Dutch Fort',
                    'description':
                        'Historic coastal ramparts and oceanfront cafes.',
                    'region': 'Southern Province',
                    'categories': ['Culture', 'Beaches'],
                    'latitude': 6.0269,
                    'longitude': 80.2170,
                    'relevanceScore': 0.96,
                  },
                ],
              }),
            }),
            200,
          );
        });

        final service = AIService(
          client: mockClient,
          backendUrl: 'https://example.test/api/tours/generate',
        );
        final results = await service.discoverDestinations(
          preferences: const TourPreferences(
            interests: {TravelInterest.culture, TravelInterest.beaches},
          ),
          candidateDestinations: const [
            Destination(
              sourceId: 'dest_galle',
              name: 'Galle Dutch Fort',
              latitude: 6.0269,
              longitude: 80.2170,
            ),
          ],
        );

        expect(results.length, 1);
        expect(results.first.name, 'Galle Dutch Fort');
        expect(
          results.first.attribution,
          'Curated by DeepSeek AI & OpenStreetMap',
        );
      },
    );
  });
}
